input = getDirectory("Select folder containing images");
File.setDefaultDir(input);
output = getDirectory("Select folder to save file/s");

//organizing TIF files & setting parameters
Dialog.create("Get Started");
	channels = newArray("C1","C2","C3","C4");
	Dialog.addNumber("How many channels in image?",4,0,1,"channel/s");
Dialog.show;
numChan = Dialog.getNumber();
chan=Array.trim(channels, numChan);
//Selecting neuron, synapse, & signal channels
Dialog.create("Channels");
	Dialog.addChoice("Primary (Neuron) Thresholding",chan);
	Dialog.addCheckbox("Cell body exclusion?", 0);
	Dialog.addChoice("Baseline (Signal) Thresholding",chan);
Dialog.show();
map2tchan=Dialog.getChoice();
cellexclusion=Dialog.getCheckbox();
signaltchan=Dialog.getChoice();

	for (i=0; i<channels.length; i++) {
    	if(channels[i] == map2tchan){
    	neuronslice = i+1;
    		}

map2files = output+"Neuron ROIs";
File.makeDirectory(map2files);

if(cellexclusion==1){
	cellexfiles = output+"Cell Body ROIs";
	File.makeDirectory(cellexfiles);
}

ssmerge= output+ "Signal in ROI";
File.makeDirectory(ssmerge);

print("\\Clear");
run("Clear Results");
run("Set Measurements...", "area mean perimeter integrated area_fraction limit display redirect=None decimal=2");
print("File	"+"Threshold");
titlelist=newArray();
processtifFolder(input);
selectWindow("Log");
saveAs("Text", output+File.separator+"Thresholding-Neuron.csv");
saveAs("Results",output+File.separator+"Neuron Results.csv");
print("\\Clear");

Titles = getList("window.titles");
for (i=0; i< Titles.length; i++) 
if ( Titles.length != 0) {
selectWindow(Titles[i]);
close(Titles[i]);
}

//loop tif images
function processtifFolder(input) {
list = getFileList(input);
list = Array.sort(list);
for (i = 0; i < list.length; i++) {
	if(File.isDirectory(input + File.separator + list[i]))
		processFolder(input + File.separator + list[i]);
	if(endsWith(list[i],".tif"))
		processneuron(input, output, list[i]);
}
}

//threshold the neuronal marker in the original TIF image
function processneuron(input, output, file){
roiManager("reset");
open(input + file);
Image.removeScale;
title=getTitle();
if(cellexclusion==1){
run("Color Balance...");
run("Enhance Contrast", "saturated=0.35");
waitForUser("Review Image");
repeat=	getBoolean("Do you have a new cell body in frame?");
while (repeat==1) {
    // Code to execute if the user clicked "Yes"
		title = getTitle();
  	setTool("freehand");
	selectWindow(title);
	waitForUser ("Select ROI then hit OK");
	roiManager("Add");
	roiManager("Show All");
	count = roiManager("count");
	roiManager("Select", count-1);
	num = (count);
    roiManager("Rename", title+" ROI "+count);
	selectWindow(title);
	run("Clear", "Stack");
	repeat=	getBoolean("Do you have a new cell body ROI in frame?");
	}
	if(repeat !=1) {
		run("ROI Manager...");
		if(roiManager("count") > 0) {
			roiManager("Save", cellexfiles+File.separator+title+"_ROI.zip");
		}
	}
}
roiManager("reset");
run("Split Channels");
x=0;
selectImage(map2tchan+"-"+title);
rename(title);
run("Grays");
setAutoThreshold("Default dark");
		run("Threshold...");
		waitForUser("set and record threshold");
		getThreshold(x,a);
		print(title+"	" + x);
			if( x == 0){
			close();}
			if (x == 65535){
		close();
			}
	else{
			selectImage(file);			
			run("Create Selection");
			roiManager("Add");
			roiManager("Select", 0);
			roiManager("Rename", file);
			roiManager("save", map2files+File.separator+file+" T"+x+"_ROI.zip")
			ROIextract();
			}
}

//selects synapse and signal channels from neuronal ROI
function ROIextract(){

selectImage(signaltchan+"-"+title);
rename(title);
roiManager("Select",0);
roiManager("Measure");
run("Copy");
run("Internal Clipboard");
selectWindow("Clipboard");
saveAs("Tiff", ssmerge+File.separator+title);
close("*");
roiManager("Delete");
}