//Global variables
var Parent_folder = "C:\\Users\\yaumu\\Desktop\\test"; //Use double backslash (\\) for Windows directory tree
var No_squares = 5
var Square_size = 1000 //in pixels

macro "ROI selection from coordinates [f1]" {

//Variables
FileName_ext = getInfo("image.filename");
FileName = replace(FileName_ext, "\\.(.*)", "");
CaseID = replace(FileName, "_(.*)_(.*)", "");
Antibody = replace(FileName, "(.*)_(.*)_", "");
Reg_1 = replace(FileName, CaseID+"_", "");
Reg = replace(Reg_1, "_"+Antibody, "");
Save_folder = Parent_folder + "\\" + Antibody + "\\" + Reg + "\\" + CaseID + "\\";

//Create folder tree if not already present
	if(!File.exists(Parent_folder + "\\" + Antibody + "\\")) {
		File.makeDirectory(Parent_folder + "\\" + Antibody + "\\");
	}
	if(!File.exists(Parent_folder + "\\" + Antibody + "\\" + Reg + "\\")) {
		File.makeDirectory(Parent_folder + "\\" + Antibody + "\\" + Reg + "\\");
	}
	if(!File.exists(Save_folder)) {
		File.makeDirectory(Save_folder);
	}

//Launch Recorder and set cursor to Polygon Selection
run("Record...");
setTool("polygon");
waitForUser("Select region of interest.", "Outline the region of interest.\nCopy the ROI coordinates, starting from makePolygon(...),\nfrom the Recorder into an empty text file for reference.\nLaunch the Random Coordinate generator (Python) and\npaste the makePolygon coordinates to generate random coordinates.\nClick OK after generating the random coordinates.");

//Adds created ROI to ROI Manager
selectWindow(FileName_ext);
	roiManager("Add");
	SelectLastROI = roiManager("count") - 1;
	roiManager("Select", SelectLastROI);
	roiManager("Rename", FileName + " Region Threshold");

//Create internal variables for input coordinates
Dialog.create("Select " + No_squares + " squares from coordinates.");
	Dialog.addMessage("Input the " + No_squares + " coordinates in the format of 'x y' (without the quotes).");
		for (a=1; a<No_squares+1; a++) {
		Dialog.addString("Square " + a, "");
	}
	Dialog.show();
	
	square_coor_array = newArray(No_squares);

	for (b=0; b < No_squares; b++) {
		square_coor_array[b] = Dialog.getString();
	}

//Creates 5 square ROIs from given coordinates, rename the ROIs and create new cropped images from the ROIs
for (c=0; c<No_squares; c++) {
	Square_x = replace(square_coor_array[c], " (.*)", "");
	Square_y = replace(square_coor_array[c], "(.*) ", "");
	run("Specify...", "width=Square_size height=Square_size x=Square_x y=Square_y centered");
	roiManager("Add");
	SelectLastROI = roiManager("count") - 1;
	FileName_ext = getInfo("image.filename");
	FileName = replace(FileName_ext, "\\.(.*)", "");
	roiManager("Select", SelectLastROI);
	roiManager("Rename", FileName + "_" + c+1);
	run("Duplicate...", "title=" + FileName + "_" + c+1);
	selectWindow(FileName_ext);
}

//Save cropped square images and append numbers at the end
for (d=1; d<No_squares+1; d++) {
	Sample_name = FileName + "_" + d;
	selectWindow(Sample_name);
	saveAs("Tiff", Save_folder + Sample_name);
}

//Save the square ROIs
roiManager("Save", Save_folder + "RoiSet.zip");

selectWindow("Recorder");
	run("Close");
selectWindow(FileName_ext);
selectWindow("ROI Manager");

}

//////////////////////////////////////////////////////////////////////////

macro "%area by Color Threshold [f2]" {

//Variables
FileName_ext = getInfo("image.filename");
FileName_nonum = replace(FileName_ext, "_(.?)(.?)\\.(.*)", "_");

//Perform macro for specified number of images
for (e=1; e<No_squares+1; e++) {

	//Selects the image in the appropriate order
	selectWindow(FileName_nonum + e + ".tif");
	
	//Color threshold to select DAB-only particles
	run("Color Threshold...");
		selectWindow("Threshold Color");
		waitForUser("Please adjust threshold.", "Adjust threshold according to antibody used.\nHue: 0-30 (DAB)\nSaturation: 0-255 (Adjust according to background)\nBrightness: Mean thresholding method.\nClick Filtered and Select after setting threshold.");
        
    //Create a binary image of the DAB-thresholded particles
	run("Create Mask");
		selectWindow("Mask");
	
	//Using ImageJ Measure function to determine %area coverage of thresholded particles
	run("Set Measurements...", "area_fraction limit redirect=None decimal=3");
	run("Measure");
		close("Mask");

}
		
//Brings Results window forward and saves it as a tab delimited text file in the folder containing the image
selectWindow(FileName_ext);
save_folder = getDirectory("image");
selectWindow("Results");
	saveAs("results", save_folder + "%area.xls");
	run("Close");

//Closes all windows in ImageJ
run("Close All");

//Open the saved results file in Excel to view
}

//////////////////////////////////////////////////////////////////////////

macro "Particle count using Hull & Circle [f3]" {

//Variables
image_dir = getDirectory("image");
FileName_ext = getInfo("image.filename");
FileName = replace(FileName_ext, "\\.(.*)", "");
FileName_nonum = replace(FileName_ext, "_(.?)(.?)\\.(.*)", "_");
ImageNumber = replace(FileName, "(.*)_", "");

//Color threshold to select DAB-only particles
run("Color Threshold...");
	selectWindow("Threshold Color");
	waitForUser("Please adjust threshold.", "Adjust threshold according to antibody used.\nHue: 0-30 (DAB)\nSaturation: 0-255 (Adjust according to background)\nBrightness: Mean thresholding method.\nClick Filtered and Select after setting threshold.");

//Create a binary image of the DAB-thresholded particles
run("Create Mask");
	selectWindow("Mask");
	rename("Hull and Circle Threshold");

//Removes particles smaller than 50 px (inclusive) to reduce excess small non-specific particles from being added to ROI Manager
run("Analyze Particles...", "size=50-Infinity exclude clear add");

//Launches the Hull and Circle plugin to analyse particles passing the size filter. Saves the results as a tab delimited file in the folder containing the image
run("Hull And Circle");
	waitForUser("Action required in Hull and Circle window.", "Untick Draw Circle & Draw Hull in Settings.\nClick Scan Roi Manager.\nAfter the Hull and Circle Results window appears, click OK on this window.");
	selectWindow(FileName_ext);
	save_folder = image_dir + "HC\\";
	File.makeDirectory(save_folder);
	selectWindow("Hull and Circle Results");
	saveAs("Text", save_folder + FileName + " Hull and Circle Results");
	run("Close");

//Saves ROI set
roi_folder = image_dir + "particle_roi\\";
File.makeDirectory(roi_folder);
roiManager("Save", roi_folder + "particle_roi_" + ImageNumber + ".zip");
selectWindow("ROI Manager");
run("Close");

//Closes all windows in ImageJ
run("Close All");

//Repeat for the remaining images
for (f=2; f<No_squares+1; f++) {

	//Open next image
	open(image_dir + FileName_nonum + f + ".tif");
	
	//Color threshold to select DAB-only particles
	run("Color Threshold...");
		selectWindow("Threshold Color");
		waitForUser("Please adjust threshold.", "Adjust threshold according to antibody used.\nHue: 0-30 (DAB)\nSaturation: 0-255 (Adjust according to background)\nBrightness: Mean thresholding method.\nClick Filtered and Select after setting threshold.");
	
	//Create a binary image of the DAB-thresholded particles
	run("Create Mask");
		selectWindow("Mask");
		rename("Hull and Circle Threshold");

	//Adds particles that are larger than 50 px (inclusive) to the ROI for downstream analysis
	run("Analyze Particles...", "size=50-Infinity exclude clear add");

	//Use Hull and Circle plugin opened from first image
	waitForUser("Action required in Hull and Circle window.", "Click Scan Roi Manager.\nAfter the Hull and Circle Results window appears, click OK on this window.");
	selectWindow(FileName_nonum + f + ".tif");
	selectWindow("Hull and Circle Results");
	saveAs("Text", save_folder + FileName_nonum + f + " Hull and Circle Results");
	run("Close");
	
	//Saves ROI set
	roiManager("Save", roi_folder + "particle_roi_" + f + ".zip");
	selectWindow("ROI Manager");
	run("Close");

	//Closes all windows in ImageJ
	run("Close All");

}
	
}

//////////////////////////////////////////////////////////////////////////

macro "Analyze microglia from filtered ROI set [f4]" {

//Variables
FileName_ext = getInfo("image.filename");
FileName = replace(FileName_ext, "\\.(.*)", "");
FileName_nonum = replace(FileName_ext, "_(.?)(.?)\\.(.*)", "_");

//Drag and drop all the square images into ImageJ

for (g=1; g<No_squares+1; g++) {
	
    //Import filtered ROI set for each image
    roiManager("Open", getDirectory("image") + "particle_roi_filtered\\particle_roi_filtered_" + g + ".zip");
	selectWindow(FileName_nonum + g + ".tif");
	roiManager("Show All");
	
    //Measure the ROI set for area, perimeter and shape descriptors (with circularity)
    run("Set Measurements...", "area perimeter shape redirect=None decimal=3");
	roiManager("Measure");
	
    //Save Measure Results table
    selectWindow("Results");
	save_folder = getDirectory("image") + "Circularity Results\\";
	File.makeDirectory(save_folder);
	saveAs("Text", save_folder + FileName_nonum + g + " Circularity Results");
	
    //Close open windows
    run("Close");
	selectWindow("ROI Manager");
	run("Close");
	
}

run("Close All");

}

//////////////////////////////////////////////////////////////////////////

macro "Analyze microglia from filtered ROI set (single image) [f5]" {

//Variables
FileName_ext = getInfo("image.filename");
FileName = replace(FileName_ext, "\\.(.*)", "");
FileName_nonum = replace(FileName_ext, "_(.?)(.?)\\.(.*)", "_");
FileNum = replace(FileName, FileName_nonum, "");

//Drag and drop single images into ImageJ

//Import new ROI set for the image
    roiManager("Open", getDirectory("image") + "particle_roi_filtered\\particle_roi_filtered_" + FileNum + ".zip");
	selectWindow(FileName_ext);
	roiManager("Show All");
	
    //Measure the ROI set for area, perimeter and shape descriptors (with circularity)
    run("Set Measurements...", "area perimeter shape redirect=None decimal=3");
	roiManager("Measure");
	
    //Save Measure Results table
    selectWindow("Results");
	save_folder = getDirectory("image") + "Circularity Results\\";
	File.makeDirectory(save_folder);
	saveAs("Text", save_folder + FileName + " Circularity Results");
	
    //Close open windows
    run("Close");
	selectWindow("ROI Manager");
	run("Close");
    run("Close All");

}