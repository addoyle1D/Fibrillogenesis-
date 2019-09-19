inputFolder = getDirectory("Input directory");
//output = getDirectory("Output directory");
//Dialog.create("Naming");
//Dialog.addString("File suffix: ", ".tif", 5);
//Dialog.addString("Date", "01-11-11_");
//Dialog.show();
//suffix = Dialog.getString();
//Date = Dialog.getString();; 
//parentFolder = getPath(inputFolder); //inputFolderPrefix = getPathFilenamePrefix(inputFolder);
outputData = inputFolder + "Output-Data" + File.separator;
if ( !(File.exists(outputData)) ) { File.makeDirectory(outputData); }
outputImages = inputFolder + "Output-Images" + File.separator;
if ( !(File.exists(outputImages)) ) { File.makeDirectory(outputImages); }


roiManager("Reset");
run("Close All");
processFolder(inputFolder);

function processFolder(input) {
    list = getFileList(input);
    for (i = 0; i < list.length; i++) {
    //for (i = 0; i < 3; i++) {
        if(File.isDirectory(list[i]))
            processFolder("" + input + list[i]);
        if(endsWith(list[i], ".tif"))
            processFile(input, list[i]);
    }
}
 
function processFile(input, file) {
    // do the processing here by replacing
    // the following two lines by your own code
          print("Processing: " + input + file);
    //run("Bio-Formats Importer", "open=" + input + file + " color_mode=Default view=Hyperstack stack_order=XYCZT");
    open(inputFolder + file);
    SaveName2=getTitle();SaveName=replace(SaveName2,".tif","");rename(SaveName);
//run("Make Composite");
//Stack.setChannel(1); run("Enhance Contrast", "saturated=0.2");run("Green");
//Stack.setChannel(2); run("Enhance Contrast", "saturated=0.2");run("Red");
//Stack.setChannel(3); run("Enhance Contrast", "saturated=0.2");run("Blue");  

//run("Split Channels"); 
//selectWindow("C1-"+SaveName);
rename("Pax");
selectWindow("Pax");run("Duplicate...", "duplicate");selectWindow("Pax-1"); rename("Pax-dup");
selectWindow("Pax");
run("Subtract Background...", "rolling=15 stack");
run("Convolve...", "text1=[1 2 3 2 1\n2 6 9 6 2\n3 9 81 9 3\n2 6 9 6 2\n1 2 3 2 1] normalize stack");
run("Unsharp Mask...", "radius=15 mask=0.60 stack");
run("Convolve...", "text1=[1 2 3 2 1\n2 6 9 6 2\n3 9 81 9 3\n2 6 9 6 2\n1 2 3 2 1] normalize stack");
saveAs("Tiff", outputImages+"Pax-fil_"+SaveName);rename("Pax");

//Create a blurred image of the cell, threshold, then create mask and save an ROI
//Create a blurred image of the cell, threshold, then create mask and save an ROI
run("Duplicate...", "duplicate");selectWindow("Pax-1"); rename("Pax-dup");selectWindow("Pax-dup");
run("Gaussian Blur...", "sigma=11");
setAutoThreshold("Otsu dark");
run("Analyze Particles...", "size=500-Infinity show=Masks slice");
selectWindow("Mask of Pax-dup"); idTotal=getImageID();
run("Invert LUT");
run("Make Binary", "method=Default background=Default calculate black");run("Fill Holes");
run("Create Selection");
roiManager("Add");//#0


//analyze the adhesions found within the cell ROI
selectWindow("Pax");
setAutoThreshold("Otsu dark");
roiManager("Select", 0);
run("Set Measurements...", "area mean modal min centroid center perimeter bounding fit shape feret's stack limit redirect=None decimal=3");
run("Analyze Particles...", "size=0.5-Infinity show=Masks display clear summarize slice");;
//selectWindow("Results");Table.rename("Results", SaveName+"_Tot-Pax");
//Table.save(outputData+SaveName+"_Tot-ind-Pax.csv");run("Clear Results");
selectWindow("Summary");//Table.rename("Summary", SaveName+"_Tot-Pax");
Table.save(outputData+SaveName+"_Tot-Sum-Pax.csv");run("Clear Results");Table.deleteRows(0, 15, "Summary");
selectWindow("Mask of Pax");run("Invert LUT");
saveAs("Tiff", outputImages+"Pax-mask_"+SaveName);close();

//Create a "center-cell" ROI based on the original cell shape by erosion 
selectWindow("Mask of Pax-dup");
run("Select None"); run("Duplicate...", "duplicate"); idCenter=getImageID();
run("Options...", "iterations=73 count=1 black do=Erode");//run("Options...", "iterations=25 count=1 black do=Erode");
run("Create Selection"); 
roiManager("Add");//#1

//Analyze the adhesions within the "cell-center" ROI
selectWindow("Pax");
roiManager("Select", 1);
run("Set Measurements...", "area mean modal min centroid center perimeter bounding fit shape feret's stack limit redirect=None decimal=3");
run("Analyze Particles...", "size=0.5-Infinity show=Masks display clear exclude summarize slice");
selectWindow("Results");Table.rename("Results", SaveName+"_Cen-Pax");
Table.save(outputData+SaveName+"_Cen-ind-Pax.csv");
selectWindow("Summary");//Table.rename("Summary", SaveName+"_Cen-Pax");
Table.save(outputData+SaveName+"_Cen-Sum-Pax.csv");Table.deleteRows(0, 15, "Summary");
selectWindow("Mask of Pax");run("Invert LUT");
saveAs("Tiff", outputImages+"Pax-Cen-mask_"+SaveName);close();

selectImage(idTotal);
roiManager("Select", 1);
run("Clear");
run("Create Selection"); run("Make Inverse");
roiManager("Add");//#2

//Analyze the adhesions within the "cell-peripheral" ROI
selectWindow("Pax");
roiManager("Select", 2);
run("Set Measurements...", "area mean modal min centroid center perimeter bounding fit shape feret's stack limit redirect=None decimal=3");
run("Analyze Particles...", "size=0.5-Infinity show=Masks display clear exclude summarize slice");
selectWindow("Results");Table.rename("Results", SaveName+"_Peri-Pax");
Table.save(outputData+SaveName+"_Peri-ind-Pax.csv");
selectWindow("Summary");//Table.rename("Summary", SaveName+"_Peri-Pax");

Table.save(outputData+SaveName+"_Peri-Sum-Pax.csv");Table.deleteRows(0, 15, "Summary");
selectWindow("Mask of Pax");run("Invert LUT");
saveAs("Tiff", outputImages+"Pax-Peri-mask_"+SaveName);close();


roiManager("Reset");
run("Close All");run("Clear Results");Table.deleteRows(0, 15, "Summary");
}