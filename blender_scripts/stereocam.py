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
import csv

# Camera intrisics: to be imported from external file
# rember that camera has fov oriented towards z -global

#===============================================================
#                   PARSE DATA FROM INPUT FILE
WorkFolder='/home/alberto/Documenti/progetti_MBDYN/MBDynProject2018/blender_scripts/'
file_path=WorkFolder+'rig_data.csv'
with open(file_path, 'rt') as csvfile:
    datareader=csv.reader(csvfile,delimiter=';')
    str=next(datareader)
    baseline=float(str[1])*1e-3
    str=next(datareader)
    attitude=float(str[1])
    str=next(datareader)
    camDesign_focal=float(str[1])
    str=next(datareader)
    camDesign_pxsize=float(str[1])
    str=next(datareader)
    camDesign_W=float(str[1])
    str=next(datareader)
    camDesign_H=float(str[1])

#processing inputs
camDesign_W_metric=camDesign_W*camDesign_pxsize;
camDesign_H_metric=camDesign_H*camDesign_pxsize;

or_axis = Vector((0.0, 1.0, 0.0))
#===============================================================
#                   STEREO RIG HANDLE
#Create the stereo rig central node
bpy.ops.object.empty_add(type='PLAIN_AXES', radius=1, view_align=False, location=(0,0,0))
StereoCenterObj=bpy.context.scene.objects.active
StereoCenterObj.name='StereoRigOrig'
StereoCenter=bpy.data.objects[StereoCenterObj.name]

#===============================================================
#                   CAM_0
# Create the camera 0 and set extrinsics
pos = Vector((-baseline*0.5, 0.0, 0.0))
or_angle =- radians( attitude)
bpy.ops.object.camera_add(location = pos)

camobj_0 = bpy.context.scene.objects.active
cam0 = bpy.data.cameras[camobj_0.name]
camobj_0.name = 'cam_0'
cam0.name = 'cam_0'

camobj_0.rotation_mode = 'AXIS_ANGLE'
camobj_0.rotation_axis_angle = Vector(( or_angle,or_axis[0], or_axis[1], or_axis[2]))

# Set camera 0 intrinsics
cam0.lens = camDesign_focal
cam0.dof_distance = 3.00
cam0.gpu_dof.fstop = 7.1
cam0.sensor_width = camDesign_W_metric
cam0.sensor_height = camDesign_H_metric
#===============================================================
#                   CAM_1
# Create the camera 1 and set extrinsics
pos = Vector((baseline*0.5, 0.0, 0.0))
or_angle = radians( attitude)
bpy.ops.object.camera_add(location = pos)

camobj_1 = bpy.context.scene.objects.active
cam1 = bpy.data.cameras[camobj_1.name]
camobj_1.name = 'cam_1'
cam1.name = 'cam_1'

camobj_1.rotation_mode = 'AXIS_ANGLE'
camobj_1.rotation_axis_angle = Vector(( or_angle,or_axis[0], or_axis[1], or_axis[2]))

# Set camera 1 intrinsics
cam1.lens = camDesign_focal
cam1.dof_distance = 3.00
cam1.gpu_dof.fstop = 7.1
cam1.sensor_width = camDesign_W_metric
cam1.sensor_height = camDesign_H_metric
#===============================================================
#                   SET RENDER RESOLUTION
bpy.context.scene.render.resolution_x = camDesign_W
bpy.context.scene.render.resolution_y = camDesign_H
bpy.context.scene.render.resolution_percentage = 100
#===============================================================
#                   FIX GEOMETRY
# lock position with parenting

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
#===============================================================
#                   GENERATE CAMERA CALIB extrinsics
WorldR_1=camobj_1.matrix_local #since the two are parented, the local framework is the one of cam_0. So it contains the extrinsics
print(WorldR_1)
T_ext=Vector(( 1e3*WorldR_1[0][3],1e3*WorldR_1[1][3], 1e3*WorldR_1[2][3]))
print(T_ext)
EulWorldR_1=camobj_1.matrix_local.to_euler()
R_ext=Vector((degrees(EulWorldR_1[0]),degrees(EulWorldR_1[1]),degrees(EulWorldR_1[2]))) #default is XYZ, according to zhang
print(R_ext)

#===============================================================
#                   GENERATE CAMERA CALIB intrinsics
cc_x=camDesign_W*0.5;
cc_y=camDesign_H*0.5;
Fx=camDesign_focal/camDesign_pxsize;
Fy=Fx;

#===============================================================
#                   Write calib file
calib_filename=WorkFolder+'camera_calib.csv'

with open(calib_filename,'w') as csvfile:
    calib_file_writer=csv.writer(csvfile,delimiter=';')
    #intrinsics cam 0
    calib_file_writer.writerow(['Cam0_Fx',Fx])
    calib_file_writer.writerow(['Cam0_Fy',Fy])
    calib_file_writer.writerow(['Cam0_Fs',0.0])
    calib_file_writer.writerow(['Cam0_Kappa 1',0.0])
    calib_file_writer.writerow(['Cam0_Kappa 2',0.0])
    calib_file_writer.writerow(['Cam0_Kappa 3',0.0])
    calib_file_writer.writerow(['Cam0_P1',0.0])
    calib_file_writer.writerow(['Cam0_P2',0.0])
    calib_file_writer.writerow(['Cam0_Cx',cc_x])
    calib_file_writer.writerow(['Cam0_Cy',cc_y])
    #intrinsics cam 1
    calib_file_writer.writerow(['cam1_Fx',Fx])
    calib_file_writer.writerow(['cam1_Fy',Fy])
    calib_file_writer.writerow(['cam1_Fs',0.0])
    calib_file_writer.writerow(['cam1_Kappa 1',0.0])
    calib_file_writer.writerow(['cam1_Kappa 2',0.0])
    calib_file_writer.writerow(['cam1_Kappa 3',0.0])
    calib_file_writer.writerow(['cam1_P1',0.0])
    calib_file_writer.writerow(['cam1_P2',0.0])
    calib_file_writer.writerow(['cam1_Cx',cc_x])
    calib_file_writer.writerow(['cam1_Cy',cc_y])
    #extrinsics
    calib_file_writer.writerow(['Tx [mm]',T_ext[0]])
    calib_file_writer.writerow(['Ty [mm]',T_ext[1]])
    calib_file_writer.writerow(['Tz [mm]',T_ext[2]])
    calib_file_writer.writerow(['Theta [deg]',R_ext[0]])
    calib_file_writer.writerow(['Phi [deg]',R_ext[1]])
    calib_file_writer.writerow(['Psi [deg]',R_ext[2]])
