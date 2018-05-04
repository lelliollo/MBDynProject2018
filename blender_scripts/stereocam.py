# stereocam.py
# The script creates a stereo vision rig in blender
#
#
#
#
# Copyright (C) 2018 Andrea Zanoni <andrea.zanoni@polimi.it>
#                    Alberto Lavatelli <alberto.lavatelli@polimi.it>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

import bpy
from mathutils import *
from math import *

#Stereo rig extrinsics: to be parsed from file
baseline=0.35;
attitude=12;

# Camera intrisics: to be imported from external file
# rember that camera has fov oriented towards z -global
or_axis = Vector((0.0, 1.0, 0.0))
focal = 8   # mm
res_x = 2592
res_y = 1944
sensor_size = 1/2.5*25.4

#Create the stereo rig central node
bpy.ops.object.empty_add(type='PLAIN_AXES', radius=1, view_align=False, location=(0,0,0))
StereoCenterObj=bpy.context.scene.objects.active
StereoCenterObj.name='StereoRigOrig'
StereoCenter=bpy.data.objects[StereoCenterObj.name]

# Create the camera 0 and set extrinsics
pos = Vector((-baseline*0.5, 0.0, 0.0))
or_angle = attitude*0.5
bpy.ops.object.camera_add(location = pos)

camobj_0 = bpy.context.scene.objects.active
cam0 = bpy.data.cameras[camobj_0.name]
camobj_0.name = 'cam_0'
cam0.name = 'cam_0'

camobj_0.rotation_mode = 'AXIS_ANGLE'
camobj_0.rotation_axis_angle = Vector(( or_angle,or_axis[0], or_axis[1], or_axis[2]))

# Set camera 0 intrinsics
cam0.lens = focal
cam0.dof_distance = 3.00
cam0.gpu_dof.fstop = 7.1
cam0.sensor_width = sensor_size*cos(atan(res_y/res_x))
bpy.context.scene.render.resolution_x = res_x
bpy.context.scene.render.resolution_y = res_y
bpy.context.scene.render.resolution_percentage = 100

# Create the camera 1 and set extrinsics
pos = Vector((baseline*0.5, 0.0, 0.0))
or_angle = -attitude*0.5
bpy.ops.object.camera_add(location = pos)

camobj_1 = bpy.context.scene.objects.active
cam1 = bpy.data.cameras[camobj_1.name]
camobj_1.name = 'cam_1'
cam1.name = 'cam_1'

camobj_1.rotation_mode = 'AXIS_ANGLE'
camobj_1.rotation_axis_angle = Vector(( or_angle,or_axis[0], or_axis[1], or_axis[2]))

# Set camera 1 intrinsics
cam1.lens = focal
cam1.dof_distance = 3.00
cam1.gpu_dof.fstop = 7.1
cam1.sensor_width = sensor_size*cos(atan(res_y/res_x))
bpy.context.scene.render.resolution_x = res_x
bpy.context.scene.render.resolution_y = res_y
bpy.context.scene.render.resolution_percentage = 100

#lock position with parenting

camobj_0.select= True
camobj_1.select= True
bpy.context.scene.objects.active = camobj_0 #the active object is the parent of it all
bpy.ops.object.parent_set()
camobj_0.select= False
camobj_1.select= False

camobj_0.select= True
StereoCenterObj.select= True
bpy.context.scene.objects.active = StereoCenterObj #the active object is the parent of it all
bpy.ops.object.parent_set()
camobj_0.select= False
StereoCenterObj.select= False
