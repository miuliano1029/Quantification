2-Channel ROI
Processes 2 channels of an image, with one being the ROI selection criteria. Thresholding for this selection can be done within the macro manually or automatically, or can be entered as global set values or uploaded via .csv for file-specific values. There is an option to include a limit of the signal of interest to a particular threshold, which can also generate relative area coverage.
Example: Isolate a a neuron via fill (thresholded for ROI selection), and then measure intensity of signal of interest within the ROI. Total intensity can be averaged, while thresholded limit will give percent area coverage.

2-Channel ROI Extended
A variant of the 2-Channel ROI macro, this one has more elaborate results output into specific tables.
Currently, this marco does not support individual thresholding via .csv, but can be updated.
Example: A 2-channel image of a synaptic marker and a protein of interest to examine intensity within synaptic ROI and percent area of target localized at synapses.

3-Level ROI Signal Intensity
This build off of the previous, starting from a TIF file where an initial ROI is selected (Level 1), and another ROI (Level 2) is generated within that selection to measure signal of interest, where thresholding (Level 3) allows for percent localization.
Example: Isolate a neuron via MAP2 or fill (Level 1 Thresholding), then specify synaptic regions via synaptic marker signal (Level 2 Thresholding) to measure signal at vs outside of synaptic regions. Thresholding of signal of interest (Level 3) allows to remove background signal via lower thresholding limit, as well as generate a binary mask for relative expression in or outside of Level 2 ROIs

