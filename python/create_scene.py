import os
from subprocess import call
from pymel.core import *

from IPython.Debugger import Tracer; debug_here = Tracer()

current_folder = os.path.dirname(os.path.abspath(__file__))
base_path = os.path.join('/', current_folder, 'base.mb')
scene_path = os.path.join('/', current_folder, 'scene.mb')

print base_path
if os.path.exists(base_path):
    f = openFile(base_path, f=1)
else:
    f = newFile(f=1)

# shaders and shading groups
shaders_groups = {}

# get absolute paths to texture files
tex_folder = os.path.join('/', current_folder, 'tex')
tex_files = [os.path.join('/', tex_folder, tex_file) 
             for tex_file in os.listdir(tex_folder)]

# get texture names
tex_names = [tf.split('\\')[-1].replace('.', '_').lower() for tf in tex_files]

for tex in zip(tex_names, tex_files):
    shader, shading_group = createSurfaceShader('lambert', tex[0])
    shaders_groups[tex[0] + 'Sh'] = shader
    shaders_groups[tex[0] + 'SG'] = shading_group
    shaders_groups[tex[0] + 'SN'] = shadingNode('file', at=True, name=tex[0])
    shaders_groups[tex[0] + 'SN'].setAttr('fileTextureName', tex[1])

# setup scene geometry
renderCam = nt.Camera()
renderCam.getParent().rename('renderCam')
renderCam.getParent().translateY.set(10.0)
renderCam.getParent().rotateX.set(-90.0)    

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
light1.getParent().translateY.set(7.5)
light1.getParent().rotateX.set(-90.0)
light1.getParent().scaleX.set(0.5);
light1.getParent().scaleZ.set(0.5);
light1.setAttr('decayRate', 2)
light1.setAttr('intensity', 100)
light1.setAttr('useRayTraceShadows', True)
light1.setAttr('shadowRays', 100)
light1.setAttr('areaLight', True)
light1.setAttr('areaType', 0)
light1.setAttr('areaHiSamples', 100)
# make sure the light illuminates everything
connectAttr(light1.instObjGroups[0], SCENE.defaultLightSet.dagSetMembers[0])

saveAs(scene_path, f=1)

for tex_name in tex_names:
    sets(shaders_groups[tex_name+'SG'], forceElement=shaders_groups[tex_name+'Sh'])
    out_im = os.path.join('/', current_folder, tex_name)
    call("render -r mr -cam renderCam -im %s %s" %(out_im, scene_path))
