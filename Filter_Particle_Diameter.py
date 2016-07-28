#!/usr/bin/env python3 
import sys

import glob

#Variables
SevenZ_dir = r"C:\Program Files\7-Zip\7z.exe" # This is the default install location.
Diameter_filter = 50 # in pixels. Size filter to select for particles equal to or larger than the specified diameter.

directory = input("Please enter folder directory containing ROI set .zip and Results table: ")

roi_directory = directory + '\particle_roi'

Number_squares = len(glob.glob1(directory, "*.tif"))

from subprocess import call
for i in range (1,Number_squares+1):
    call([SevenZ_dir,'e',roi_directory+'\particle_roi_'+str(i)+'.zip','-o'+roi_directory+'\*'])
    
    # read roi list 
    roi_list=glob.glob(roi_directory+'\particle_roi_'+str(i)+'\*.roi')
    
    # read the diameter table 
    glob_file_names=glob.glob(directory+'\HC\*_'+str(i)+'*.txt')
    
    ifile=open(glob_file_names[0])
    ifile.readline()
    for j in range(len(roi_list)):
        cols=ifile.readline()[:-1].split('\t')
        if len(cols) < 2:
            continue 
        if float(cols[13]) < Diameter_filter:
            call(['del', roi_list[j]],shell=True)
    ifile.close()
    
    call([SevenZ_dir,'a','-tzip',roi_directory+'_filtered\particle_roi_filtered_'+str(i)+'.zip',roi_directory+'\particle_roi_'+str(i)+'\*.roi'])
    call(['rmdir',roi_directory+'\particle_roi_'+str(i),'/S','/Q'],shell=True)