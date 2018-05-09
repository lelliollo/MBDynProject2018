import csv

#file_path = filedialog.askopenfilename(title = "Select stereo rig file",filetypes = (("CSV","*.csv"),("all files","*.*")))
file_path='rig_data.csv'
with open(file_path, 'rt') as csvfile:
    datareader=csv.reader(csvfile,delimiter=';')
    str=next(datareader)
    baseline=float(str[1])
    str=next(datareader)
    attitude=float(str[1])
    str=next(datareader)
    cam0_focal=float(str[1])
    str=next(datareader)
    cam0_pxsize=float(str[1])
    str=next(datareader)
    cam0_W=float(str[1])
    str=next(datareader)
    cam0_H=float(str[1])


calib_filename='camera_calib.csv'
dummy=1.234;
dummy2=2.444;

with open(calib_filename,'w') as csvfile:
    calib_file_writer=csv.writer(csvfile,delimiter=';')
    calib_file_writer.writerow(['Cam 0 cc X',dummy])
    calib_file_writer.writerow(['Cam 0 cc Y',dummy2])
