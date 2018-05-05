import csv
import tkinter as tk
from tkinter import filedialog

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
    cam1_focal=float(str[1])
    str=next(datareader)
    cam1_pxsize=float(str[1])
    str=next(datareader)
    cam1_W=float(str[1])
    str=next(datareader)
    cam1_H=float(str[1])
