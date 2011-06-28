import os
from pymel.core import *

folder = os.path.dirname(os.path.abspath(__file__))
in_path = os.path.join('/', folder, 'base.mb')
out_path = os.path.join('/', folder, 'scene.mb')

print in_path
if os.path.exists(in_path):
    f = openFile(in_path, f=1)
else:
    f = newFile(f=1)

# setup scene attributes


# setup scene geometry
if not objExists('renderCam'):
    renderCam = nt.Camera(name='renderCam')
    renderCam.getParent().translateY.set(10.0)
    renderCam.getParent().rotateX.set(-90.0)    

if not objExists('groundPlane'):
    groundPlane = polyPlane(name='groundPlane')
    groundPlane[0].scaleX.set(100.0)
    groundPlane[0].scaleZ.set(100.0) 

if not objExists('occluder'):
    occluder = polyPlane(name='occluder')
    occluder[0].translateY.set(5.0)
    occluder[0].translateX.set(-5.0)
    occluder[0].scaleX.set(10.0)
    occluder[0].scaleZ.set(100.0)
    occluder[0].setAttr('primaryVisibility', False)

if not objExists('light1'):
    light1 = nt.AreaLight(name='light1')
    light1.getParent().translateY.set(7.5)
    light1.getParent().rotateX.set(-90.0)
    light1.setAttr('decayRate', 2)
    light1.setAttr('intensity', 100)
    light1.setAttr('useRayTraceShadows', True)
    light1.setAttr('shadowRays', 100)
    light1.setAttr('areaLight', True)
    light1.setAttr('areaType', 0)
    light1.setAttr('areaHiSamples', 100)
    connectAttr(light1.instObjGroups[0], SCENE.defaultLightSet.dagSetMembers[0])

print out_path
saveAs(out_path, f=1)
