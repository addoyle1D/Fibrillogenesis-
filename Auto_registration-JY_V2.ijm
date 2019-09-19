input = getDirectory("Input directory");
output = getDirectory("Output directory");
Dialog.create("File type");
Dialog.addString("File suffix: ", ".tif", 5);//Dialog.addString("Date", "1-11-11_");
Dialog.show();
suffix = Dialog.getString();
//Date = Dialog.getString();; 
targetD= output+"Aligned"+File.separator;
File.makeDirectory(targetD);

processFolder(input);
 
function processFolder(input) {
    list = getFileList(input);
    for (i = 0; i < list.length; i++) {
        if(File.isDirectory(list[i]))
            processFolder("" + input + list[i]);
        if(endsWith(list[i], suffix))
            processFile(input, output, list[i]);
    }
}
 
function processFile(input, output, file) {
    // do the processing here by replacing
    // the following two lines by your own code
          print("Processing: " + input + file);
    //run("Bio-Formats Importer", "open=" + input + file + " color_mode=Default view=Hyperstack stack_order=XYCZT");
    open(input + file);SaveName=getTitle();SaveName2=replace(SaveName,".tif","");
		run("Make Composite");
        run("Correct 3D drift", "channel=2 only=250 lowest=1 highest=1");
selectWindow("registered time points"); //saveAs("Tiff", output+"AL-"+SaveName2);//rename("registered time points");

selectWindow("registered time points");
run("Z Project...", "projection=[Min Intensity]");
selectWindow("MIN_registered time points");
run("Split Channels");
selectWindow("C3-MIN_registered time points");
close();
selectWindow("C1-MIN_registered time points");
close();
selectWindow("C2-MIN_registered time points");
setThreshold(1, 65535);


setTool("wand");
doWand(500,500);

run("ROI Manager...");
roiManager("Add");
selectWindow("registered time points");
roiManager("Select", 0);
run("Crop");
close("C2-MIN_registered time points");


selectWindow("registered time points");
    print("Saving to: " + output); 
    saveAs("TIFF", targetD+"AL_"+SaveName2);close();
    close(SaveName);
    roiManager("Delete");
    run("Close All");
}