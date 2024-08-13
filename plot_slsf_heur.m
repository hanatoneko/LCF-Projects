%load('C:\Users\horneh\Documents\LCF_Paper_experiments\parameter_values\paramandslsf.mat');
%load('C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_2\slsfpaper_exp_heur.mat');

%this code doesn't actually plot anything, it just calculates the average
%performance of each metric for the alternative methods (CLOS-1, DET-1, CLOS-5, DET-5) and
%SLSF 

metrics = zeros(5,5);

%put in objectives
metrics(1,1) = mean(testobjave_slsf);
metrics(1,2) = mean(testobjave_clos1);
metrics(1,3) = mean(testobjave_det1);
metrics(1,4) = mean(testobjave_clos5);
metrics(1,5) = mean(testobjave_det5);

%put in matches
metrics(2,1) = mean(testrejave_slsf);
metrics(2,2) = mean(testrejave_clos1);
metrics(2,3) = mean(testrejave_det1);
metrics(2,4) = mean(testrejave_clos5);
metrics(2,5) = mean(testrejave_det5);

%put in unhappy
metrics(3,1) = mean(testdupave_slsf);
metrics(3,2) = mean(testdupave_clos1);
metrics(3,3) = mean(testdupave_det1);
metrics(3,4) = mean(testdupave_clos5);
metrics(3,5) = mean(testdupave_det5);

%put in profit
metrics(4,1) = mean(avetotprofit_slsf);
metrics(4,2) = mean(avetotprofit_clos1);
metrics(4,3) = mean(avetotprofit_det1);
metrics(4,4) = mean(avetotprofit_clos5);
metrics(4,5) = mean(avetotprofit_det5);

%put in objectives
metrics(5,1) = mean(runtimes_slsf);
metrics(5,2) = mean(runtimes_clos1);
metrics(5,3) = mean(runtimes_det1);
metrics(5,4) = mean(runtimes_clos5);
metrics(5,5) = mean(runtimes_det5);

metrics=metrics'
mean(avetotprofit_det5le)