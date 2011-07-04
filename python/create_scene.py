import os, re
from subprocess import call
from pymel.core import *

from IPython.Debugger import Tracer; debug_here = Tracer()

def connectGroundPlaneToShader(shader_name):
    connectAttr(groundPlane[0].getShape().instObjGroups[0], 
                shaders_groups[shader_name+'SG'].dagSetMembers[1], f=1)

def disconnectGroundPlaneFromShader(shader_name):
    disconnectAttr(groundPlane[0].getShape().instObjGroups[0], 
                   shaders_groups[tex_name+'SG'].dagSetMembers[1])    

def renderScene(out_im, scene_path):
    # render shadow image
    saveAs(scene_path, f=1)
    call("render -r mr -cam renderCam -im %s -v 0 %s" %(out_im, scene_path))

def castShadow(cast):
    occluder[0].getShape().setAttr('castsShadows', cast);
    PyNode('occluder_sphereShape').setAttr('castsShadows', cast); 

current_folder = os.path.dirname(os.path.abspath(__file__))
base_path = os.path.join('/', current_folder, 'base-2011-07-04.mb')
scene_path = os.path.join('/', current_folder, 'scene.mb')

# open base file if exists, otherwise create a new one
if os.path.exists(base_path):
    f = openFile(base_path, f=1)
else:
    f = newFile(f=1)

# shaders and shading groups
shaders_groups = {}

# get absolute paths to texture files
tex_folder = os.path.join('/', current_folder, 'textures')
tex_files = [os.path.join('/', tex_folder, tex_file) 
             for tex_file in os.listdir(tex_folder) 
             if os.path.isfile(os.path.join(tex_folder, tex_file))]

# get texture names
tex_names = [tf.split('\\')[-1].split('.')[0].lower() for tf in tex_files]

for tex in zip(tex_names, tex_files):
    shader, shading_group = createSurfaceShader('lambert', tex[0])
    shaders_groups[tex[0] + 'Sh'] = shader
    shaders_groups[tex[0] + 'SG'] = shading_group
    shaders_groups[tex[0] + 'SN'] = shadingNode('file', at=True, 
                                                name=tex[0]+'_file')

    shaders_groups[tex[0] + 'SN'].setAttr('fileTextureName', tex[1])

    connectAttr(shaders_groups[tex[0] + 'SN'].outColor, shader.color)

# setup scene geometry
renderCam = nt.Camera()
renderCamParent = renderCam.getParent()
renderCamParent.rename('renderCam')
renderCamParent.translateY.set(10.0)
renderCamParent.rotateX.set(-90.0)    

groundPlane = polyPlane(name='groundPlane')
groundPlane[0].scaleX.set(30.0)
groundPlane[0].scaleZ.set(30.0)

occluder = polyPlane(name='occluder')
occluder[0].translateY.set(5.0)
occluder[0].translateX.set(-5.0)
occluder[0].scaleX.set(10.0)
occluder[0].scaleZ.set(30.0)
occluder[0].setAttr('primaryVisibility', False)

light1 = nt.AreaLight(name='light1')
light1Parent = light1.getParent()
# set light position
light1Parent.translateY.set(7.5)
light1Parent.translateX.set(2.0)
light1Parent.rotateX.set(-90.0)
light1Parent.scaleX.set(2.0);
light1Parent.scaleZ.set(10.0);

# set light attributes
light1.setAttr('decayRate', 2)
light1.setAttr('intensity', 50)
light1.setAttr('useRayTraceShadows', True)
light1.setAttr('shadowRays', 100)
light1.setAttr('areaLight', True)
light1.setAttr('areaType', 0)
light1.setAttr('areaHiSamples', 100)
# make sure the light illuminates everything
connectAttr(light1.instObjGroups[0], SCENE.defaultLightSet.dagSetMembers[0])



# disconnect groundPlaneShape from default shader
dest = connectionInfo(groundPlane[0].getShape().instObjGroups[0], dfs=True)[0]
dsmn = re.search(r'([0-9])', dest).groups(0)[0];

#debug_here()

disconnectAttr(groundPlane[0].getShape().instObjGroups[0], 
               PyNode(dest.split('.')[0]).dagSetMembers[int(dsmn)])

for tex_name in tex_names:
    connectGroundPlaneToShader(tex_name)
    out_im = os.path.join('/', current_folder, 'output', tex_name)

    # render shadow image
    castShadow(True)
    saveAs(scene_path, f=1)
    renderScene(out_im+'_shad', scene_path)

    # render noshadow image
    castShadow(False)
    saveAs(scene_path, f=1)
    renderScene(out_im+'_noshad', scene_path)

    disconnectGroundPlaneFromShader(tex_name)
