# imagej-particle-analysis

Particle analysis using ImageJ macros and Python scripts

Written by Yau Mun LIM

Email: yau.m.lim@kcl.ac.uk

Acknowledgements:

Many thanks to Kuang Lin for helping me write the Python scripts which I was not familiar with. I have since then modified the Python scripts to be more user-friendly.

Notes:

Currently developed for Windows devices only due to differences in directory tree format between OS.

Tested to be working with ImageJ v1.50i as of 27/07/2016.

Installation instructions:
	
	Required software:
		ImageJ for Windows
		Python for Windows
		7-Zip for Windows
		Hull And Circle (3rd party plugin for ImageJ, https://imagej.nih.gov/ij/plugins/hull-circle.html; included)
		
	Adjust the global variables within each macro/Python script as necessary:
		ImageJ macro (Particle_analyses_macro.ijm):
			Under the //Global variables heading,
			
			Parent_folder: Change the directory to where you want the generated random squares to be saved. I recommend this to be a dedicated folder for your analysis. You can also change this to your 'test' folder for optimisation of parameters.
			
			No_squares: Adjust the number of squares intended to be generated and analysed accordingly. May need to be optimised based on the amount of total area available for analysis.
			
			Square_size: Adjust the size of the squares to be generated and analysed. Again, this needs to be optimised depending on the amount of total area available for analysis.
			
		Random coordinate generator Python script (Random_Coordinates.py):
			NUMBER_OF_POINTS and SQUARE_WIDTH: Adjust to correspond with No_squares and Square_size in Particle_analyses_macro.ijm
			
		Filter Particle Diameter Python script (Filter_Particle_Diameter.py):
			Under the #Variables heading, change the Installation location of 7-Zip if necessary.
			
	To use the ImageJ macros and scripts, a prerequisite is that your 'Whole region' .tif/tiff images MUST* be named in this format (without the brackets):
	
		<Case ID>_<Anatomical region>_<Stain>
	
		*This can of course be adjusted to your preference, but that also means changing the the folder tree format in all macros according to your preference too.
	
	To install the ImageJ macro, just drag and drop the .ijm file and the Hull And Circle.jar file into ImageJ and it should install itself.
	
	The Python scripts should be usable once Python for Windows is installed.
			

Changelog:

v1.2 - 24/08/2016

	Changed the Python scripts 'Random_Coordinates' and 'Filter_Particle_Diameter' so that the Number of squares, Size of squares, and Diameter size filter can be defined without editing the Python script.

v1.1 - 27/07/2016

	Added new input variable in Random Coordinates Python script to reflect actual size of square (width/height) in pixels.


v1.0 - 26/07/2016

	Compared to previous version, added global variables for ImageJ macros to easily change Parent directory, number of random squares analysed and size of the squares across the various ImageJ macros.

	Changed repeating macro variables to be able to handle 10 or more squares.

	'ROI selection from coordinates' ImageJ macro
		Added function to create the folder tree if not already present.
	
		Added function to launch Recorder and change cursor to Polygon Selection. Macro waits for user to copy and save the ROI coordinates, and generate the random square coordinates. User has to click OK to allow macro to progress to window for coordinate input.
	
		Changed the way the macro handles the random square coordinates. The number of fields for coordinate input dynamically scales based on the global variable indicating the number of squares to be analysed. The macro then adds these coordinates into an array which can be called based on the location of the coordinate in the array. This means that the user no longer needs to manually add/remove the "SquareX" variables that was used previously.
	
	'%area by Color Threshold' ImageJ macro
		Removed the 10 px^2 size filter to remove background. Background can be effectively removed by adjusting Saturation in the Color Threshold with Hue and Brightness fixed.
		Also removed the merging of individual particle ROIs accordingly that was required when applying the size filter. This allows for much quicker processing.
	
	'Particle count using Hull & Circle' ImageJ macro
		Changed the ROI set directory so that it now is saved into a folder in the same location where the squares are saved.
	
		Cleaned up a few repeating lines of code where it would recreate an existing folder.
	
	'Analyze microglia from filtered ROI set' ImageJ macro
		Changed the directory where the macro would call for the filtered ROI set, in line with the change in ROI set directory mentioned above.
	
	'Random Coordinates' python script
		No changes.
	
	'Filter Particle Diameter' python script
		Added a variable for diameter filter so that it can easily be adjusted by the user.
	
		The script now counts the number of images present in the image folder to determine the number of times to loop the script. This means that the number of squares is dynamically determined with no need to adjust.
