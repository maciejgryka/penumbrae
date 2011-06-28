import os
from subprocess import call
from pymel.core import *

folder = os.path.dirname(os.path.abspath(__file__))
in_path = os.path.join('/', folder, 'base.mb')
out_path = os.path.join('/', folder, 'scene.mb')

print in_path
if os.path.exists(in_path):
    f = openFile(in_path, f=1)
else:
    f = newFile(f=1)

# create shaders and shading groups
texfiles =  os.listdir(os.path.join('/', folder, 'textures'))

shaders_groups = {}

for tex in texfiles:
    tex_name = tex.split('.')[0]
    shdr, sg = createSurfaceShader('lambert', 'plain')
    shaders_groups[tex_name + 'Sh'] = shdr
    shaders_groups[tex_name + 'SG'] = sg

print shaders_groups.keys()

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

saveAs(out_path, f=1)

call("render -r mr -cam renderCam " + out_path)
