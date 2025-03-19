imgdir=getDir("Choose image folder");
parentdir = File.getParent(imgdir);
File.setDefaultDir(parentdir);
imglist=getFileList(imgdir);
output = getDirectory("Select folder to save file/s");
synroi= output + "4. ROIs";
File.makeDirectory(synroi);


Dialog.create("Thresholding");
	threshchoice=newArray("Auto","Manual","Set");
	threshchoice2=newArray("Auto","Manual","Set","None");
	Dialog.addChoice("Synapse", threshchoice,"");
	Dialog.addChoice("Signal", threshchoice2,"");
Dialog.show;
thresh=Dialog.getChoice();
thresh2=Dialog.getChoice();

if (thresh == "Set") {
	Dialog.create("Thresholding");
			Dialog.addNumber("Threshold:", 1000);
			Dialog.show;
sett=Dialog.getNumber();
}
if (thresh2 == "Set") {
	Dialog.create("Thresholding");
			Dialog.addNumber("Threshold:", 1000);
			Dialog.show;
sett2=Dialog.getNumber();
}


print("\\Clear");
run("Clear Results");
run("Set Measurements...", "area mean integrated area_fraction limit display redirect=None decimal=2");
Table.create("Synapse");
Table.create("Neuron");
Table.create("Signal");
print("File	"+"SynapseT	"+"SignalT"); 

for(f=0;f<imglist.length;f++)
{
	open(imgdir+imglist[f]);
	name=getTitle();
	nameindex=indexOf(name, ".tif");
  	newname=substring(name, 0, nameindex);
	processROI();
}

selectWindow("Synapse");
NAME=Table.getColumn("Label");
SArea=Table.getColumn("Area");
SIntDen=Table.getColumn("RawIntDen");
SMean=Table.getColumn("Mean");
if(thresh2 != "None"){
SigT=Table.getColumn("MinThr");
SigAPer=Table.getColumn("%Area");
syncov=newArray();
			for(j=0;j<nResults;j++) {
			SC=getResult("Area",j)/getResult("%Area",j)*100;
			syncov=Array.concat(syncov,SC);
			}
}
Table.rename("Synapse", "Results");
saveAs("Results",output+File.separator+"7. Synapse.csv");
close("Results");

selectWindow("Neuron");
NArea=Table.getColumn("Area");
NIntDen=Table.getColumn("RawIntDen");
NMean=Table.getColumn("Mean");
if(thresh2 != "None"){
NAPer=Table.getColumn("%Area");
totcov=newArray();
			for(j=0;j<nResults;j++) {
			TC=getResult("Area",j)/getResult("%Area",j)*100;
			totcov=Array.concat(totcov,TC);
			}
Table.rename("Neuron", "Results");
saveAs("Results",output+File.separator+"7. Neuron.csv");
close("Results");

if(thresh2 != "None"){
selectWindow("Signal");
SigPerc=Table.getColumn("%Area");
saveAs("Results",output+File.separator+"7. Signal.csv");
close("Results");
}
//Compiled results					
Table.create("Results");
Table.setColumn("Label", NAME);
Table.setColumn("Total Signal", NIntDen);
Table.setColumn("Synaptic Signal", SIntDen);
Psigcalc=newArray();
			for(j=0;j<nResults;j++) {
			PS=getResult("Synaptic Signal",j)/getResult("Total Signal",j)*100;
			Psigcalc=Array.concat(Psigcalc,PS);
			}
if(thresh2 != "None"){
Table.setColumn("Total Signal Area", NArea);
Table.setColumn("Total Area", totcov);
Table.setColumn("Synaptic Signal Area", SArea);
Table.setColumn("Synaptic Area", syncov);
}
else{
Table.setColumn("Total Area", NArea);
Table.setColumn("Synaptic Area", SArea);
}


Table.setColumn("% Syn Signal", Psigcalc);
if(thresh2 != "None"){
Table.setColumn("%CoverageSyn", SigPerc);
}
Table.setColumn("AVG Total Signal", NMean);
Table.setColumn("AVG Syn Signal", SMean);



selectWindow("Log");
saveAs("Text", output+File.separator+"5. Thresholding Values.csv");
selectWindow("Results");
saveAs("Results",output+File.separator+"6. Summary.csv");
close("Results");

Titles = getList("window.titles");
for (i=0; i< Titles.length; i++) 
if ( Titles.length != 0) {
selectWindow(Titles[i]);
close(Titles[i]);
}

function processROI() {
roiManager("reset");
title=getTitle();
run("Split Channels");
selectImage("C2-"+title);
rename(title);
//get neuron roi
setThreshold(1, 65535);
run("Create Selection");
roiManager("Add");
resetThreshold;
roiManager("Select", 0);
roiManager("Rename", "Neuron");
//get synapse roi
selectImage("C1-"+title);
resetThreshold;
x=0;
a=65535;
run("Grays");
setAutoThreshold("Default dark");
run("Threshold...");
if(thresh == "Manual"){
run("Threshold...");
run("In [+]");
run("In [+]");
run("In [+]");
run("In [+]");
waitForUser("set and record threshold");
getThreshold(x,a);
			}
if(thresh == "Set"){
x=sett;
setThreshold(x, 65535);	
			}	

getThreshold(x,a);
run("Create Selection");
roiManager("Add");
roiManager("Select",1);
roiManager("Rename", "Synapse T"+x);
//get signal roi
selectImage(title);
resetThreshold;
y=0;
a=65535;
run("Grays");
setAutoThreshold("Default dark");
run("Threshold...");

if(thresh2 == "None"){
getThreshold(y,a);}

else{
if(thresh2 == "Manual"){
run("In [+]");
run("In [+]");
run("In [+]");
run("In [+]");
waitForUser("set and record threshold");
getThreshold(y,a);
			}
if(thresh2 == "Set"){
y=sett2;
resetThreshold;
setThreshold(y, 65535);	
}
wait(100);
getThreshold(y,a);
run("Create Selection");
roiManager("Add");
roiManager("Select",2);
roiManager("Rename", "Signal T"+y);
}

Table.rename("Neuron", "Results");
roiManager("Select", 0);
roiManager("Measure");
Table.rename("Results", "Neuron");

Table.rename("Synapse", "Results");
roiManager("Select", 1);
roiManager("Measure");
Table.rename("Results", "Synapse");

if(thresh2 != "None"){

Table.rename("Signal", "Results");
selectImage("C1-"+title);
roiManager("Select", 2);
roiManager("Measure");
Table.rename("Results", "Signal");
}

roiManager("save", synroi+File.separator+title+"_ROI.zip")
print(title+"	" + x +"	" +y);
roiManager("reset");
close("*");
}
