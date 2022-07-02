%this code was made to facilitate analysis comparing the 5 performance metrics 
%(obj, match rate, unhappy driver requests, profit, runtime) of using a
%variety of settings for SOL-IT, including different numbers of variable and fixed scenarios
% with 10 iterations of SOL-IT, terminating SOL-IT after different
% numbers of iterations (e.g. the performance benefits
% of solving SOL-IT with 5 iterations vs only 2 iterations)(and using a few different numbers of variable and
% fixed scenarios), and using alternative methods like SLSF, LCF-DIR,
% LCF-FM, LCF-FMS, and the four heuristics CLOS-1, CLOS-5, LIK-1, and
% LIK-5.
% For each of these methods and settings, 
% bestperf analysis is run and a separate data file is created.  This code produces a single matlab
%data file named 'param_tuning_vals.mat' that contains performance
%information for each tested method/setting, grouping similar
%methods/settings into the same variables, e.g. the alternative methods'
%performance analysis are grouped together into the same values, with the different settings/methods concatenated vertically.



%%% this was to rearrange rows on the 10 iteration solutions bc I initially
%%% coded them wrong
% %  variscen_sizes_lcf_it_10=[0,5,10,10,10,20,20,50,50];
% %  fixedscen_sizes_lcf_it_10=[0,5,10,20,50,10,20,10,50];
% % testobjave_lcf_it_10 = testobjave_lcf_it_10([1 2 3 4 5 6 8 7 9],:);
% % testrejave_lcf_it_10=testrejave_lcf_it_10([1 2 3 4 5 6 8 7 9],:);
% % testdupave_lcf_it_10=testdupave_lcf_it_10([1 2 3 4 5 6 8 7 9],:);
% % avetotprofit_lcf_it_10=avetotprofit_lcf_it_10([1 2 3 4 5 6 8 7 9],:);
% % runtimes_lcf_it_10=runtimes_lcf_it_10([1 2 3 4 5 6 8 7 9],:);


clear
numtrials = 100; %number of problem instances


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% first, save the performance info of the different numbers of variable and fixed scenarios with 10
%%% iterations of SOL-IT, plus SLSF as the first 'size'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numsizes_10=9; %number of sizes we test
variscen_sizes_lcf_it_10=[0,5,10,10,10,20,20,50,50]; %number of variable scenarios for each experiment
fixedscen_sizes_lcf_it_10=[0,5,10,20,50,10,20,10,50]; %number of fixed scenarios for each experiment
testobjave_lcf_it_10=zeros(numsizes_10,numtrials); %average objective for each problem instance and scenario sample size experiment
testrejave_lcf_it_10=zeros(numsizes_10,numtrials); %average number of unmatched requests for each problem instance and scenario sample size experiment
testdupave_lcf_it_10=zeros(numsizes_10,numtrials); %average number of requests accepted by an unhappy driver for each problem instance and scenario sample size experiment
avetotprofit_lcf_it_10=zeros(numsizes_10,numtrials); %average profit for each problem instance and scenario sample size experiment
runtimes_lcf_it_10=zeros(numsizes_10,numtrials); %average runtime for each problem instance and scenario sample size experiment


%%%  load the SOL-IT soln info for each fixed/variable scenario sample
%%%  size, all of the bestperf files for SOL-IT have the SLSF performance
%%%  info so we'll save the SLSF info when we save the first SOL-IT experiment
 for i_plots=2:numsizes_10
     %load the given experiment
    stem= sprintf('lcf_it_bestperfmaxI10P10FS%dVS%d%s.mat',fixedscen_sizes_lcf_it_10(1,i_plots),variscen_sizes_lcf_it_10(1,i_plots),'');
    filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Paper_experiments\LCF_it_bestperf\' stem];
    load(filename)
  
    %%% if it's the first iteration, save the slsf info
     if i_plots == 2 
         %compute the profit where the scenarios are non-equally weighted 
        for t_plots = 1:trials
        [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare] = quality_metrics_with_scenprobs(farelong(:,(t-1)*n+1:t*n),slsfcomplong(:,(t-1)*n+1:t*n),extradrivingtimelong(:,(t-1)*n+1:t*n),testscenprobs_slsf(t,:),testv_slsf((t-1)*m+1:t*m,:),testw_slsf((t-1)*m+1:t*m,:)); 
          avetotprofit_slsf(1,t) = avetotprofit;
        end
        testobjave_lcf_it_10(1,:)=testobjave_slsf;
        testrejave_lcf_it_10(1,:)=testrejave_slsf;
        testdupave_lcf_it_10(1,:)=testdupave_slsf;
       % avetotprofit_lcf_it_10(1,:)=avetotprofit_slsf;
        runtimes_lcf_it_10(1,:)=runtimes_slsf;
    end
    
    for t_plots = 1:trials %to do non-equally weighted avetotprofit calculation
        if guessbestiter_lcf_it_noperf(1,t) ~= 0
            [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare] = quality_metrics_with_scenprobs(farelong(:,(t-1)*n+1:t*n),...
           alphavalslong(:,(t-1)*n+1:t*n)+ubest_lcf_it_bestperf(:,(t-1)*n+1:t*n),extradrivingtimelong(:,(t-1)*n+1:t*n),testscenprobs_best_lcf_it_bestperf(t,:),...
            testv_best_lcf_it_bestperf((t-1)*m+1:t*m,:),testw_best_lcf_it_bestperf((t-1)*m+1:t*m,:));
            avetotprofit_best_lcf_it_bestperf(1,t)=avetotprofit;
        else
            avetotprofit_best_lcf_it_bestperf(1,t) = avetotprofit_slsf;
        end
    end

    testobjave_lcf_it_10(i_plots,:)=testobjave_best_lcf_it_bestperf;
    testrejave_lcf_it_10(i_plots,:)=testrejave_best_lcf_it_bestperf;
    testdupave_lcf_it_10(i_plots,:)=testdupave_best_lcf_it_bestperf;
%     avetotprofit_lcf_it_10(i_plots,:)=avetotprofit_best_lcf_it_bestperf;
    runtimes_lcf_it_10(i_plots,:)=runtimes_total_lcf_it_noperf;
    
    
 end


 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% save the performance info of the different numbers of iterations solutions when the number of
%%% iterations done is lower than 10. We test SOL-IT with 1, 2, 5, and 7
%%% iterations, each of these tested with 5, 10, 20, and 50 each of
%%% fixed/variable scenarios 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 numsizes_1257=16; %number of experiments
 top_iter_1257 = [1,1,1,1,2,2,2,2,5,5,5,5,7,7,7,7]; %number of iterations
 variscen_sizes_lcf_it_1257=[5,10,20,50,5,10,20,50,5,10,20,50,5,10,20,50];%number of variable scenarios for each experiment
 fixedscen_sizes_lcf_it_1257=[5,10,20,50,5,10,20,50,5,10,20,50,5,10,20,50]; %number of fixed scenarios for each experiment
testobjave_lcf_it_1257=zeros(numsizes_1257,numtrials);%average objective for each problem instance and scenario sample size/iteration experiment
testrejave_lcf_it_1257=zeros(numsizes_1257,numtrials); %average number of unmatched requests for each problem instance and scenario sample size/iteration experiment
testdupave_lcf_it_1257=zeros(numsizes_1257,numtrials);%average number of requests accepted by an unhappy driver for each problem instance and scenario sample size/iteration experiment
avetotprofit_lcf_it_1257=zeros(numsizes_1257,numtrials);%average profit for each problem instance and scenario sample size/iteration experiment
runtimes_lcf_it_1257=zeros(numsizes_1257,numtrials);%average runtime for each problem instance and scenario sample size/iteration experiment



% % testobjave_lcf_it_1257 = testobjave_lcf_it_1257([1 2 3 3 4 5 6 6 7 8 9 9 10 11 12 12],:);
% % testrejave_lcf_it_1257=testrejave_lcf_it_1257([1 2 3 3 4 5 6 6 7 8 9 9 10 11 12 12],:);
% % testdupave_lcf_it_1257=testdupave_lcf_it_1257([1 2 3 3 4 5 6 6 7 8 9 9 10 11 12 12],:);
% % avetotprofit_lcf_it_1257=avetotprofit_lcf_it_1257([1 2 3 3 4 5 6 6 7 8 9 9 10 11 12 12],:);
% % runtimes_lcf_it_1257=runtimes_lcf_it_1257([1 2 3 3 4 5 6 6 7 8 9 9 10 11 12 12],:);


for i_plots=1:numsizes_1257
    stem= sprintf('lcf_it_bestperfmaxI%dP10FS%dVS%d%s.mat',top_iter_1257(1,i_plots),fixedscen_sizes_lcf_it_1257(1,i_plots),variscen_sizes_lcf_it_1257(1,i_plots),'');
    filename =[ 'C:\Users\horneh\Documents\LCF_Paper_experiments\LCF_it_bestperf\' stem];
    load(filename)

    testobjave_lcf_it_1257(i_plots,:)=testobjave_best_lcf_it_bestperf;
    testrejave_lcf_it_1257(i_plots,:)=testrejave_best_lcf_it_bestperf;
    testdupave_lcf_it_1257(i_plots,:)=testdupave_best_lcf_it_bestperf;
    avetotprofit_lcf_it_1257(i_plots,:)=avetotprofit_best_lcf_it_bestperf;
    runtimes_lcf_it_1257(i_plots,:)=runtimes_total_lcf_it_noperf;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% save the performance info of the different numbers of iterations solutions when the number of
%%% iterations done is higher than 10. The only number we test above 10 is
%%% 13 iterations,
%%% each of these tested with 5, 10, and 20, each of
%%% fixed/variable scenarios 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numsizes_13=3; %number of experiments
variscen_sizes_lcf_it_13=[5,10,20];%number of variable scenarios for each experiment
fixedscen_sizes_lcf_it_13=[5,10,20];%number of fixed scenarios for each experiment
testobjave_lcf_it_13=zeros(numsizes_13,numtrials);%average objective 
testrejave_lcf_it_13=zeros(numsizes_13,numtrials);%average number of unmatched requests 
testdupave_lcf_it_13=zeros(numsizes_13,numtrials);%average number of requests accepted by an unhappy driver 
avetotprofit_lcf_it_13=zeros(numsizes_13,numtrials);%average profit 
runtimes_lcf_it_13=zeros(numsizes_13,numtrials);%average runtime 


%for each experiment, load and save the info
for i_plots=1:numsizes_13
    stem= sprintf('lcf_it_bestperfmaxI13P10FS%dVS%d%s.mat',fixedscen_sizes_lcf_it_13(1,i_plots),variscen_sizes_lcf_it_13(1,i_plots),'');
    filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Paper_experiments\LCF_it_bestperf\' stem];
    load(filename)

    testobjave_lcf_it_13(i_plots,:)=testobjave_best_lcf_it_bestperf;
    testrejave_lcf_it_13(i_plots,:)=testrejave_best_lcf_it_bestperf;
    testdupave_lcf_it_13(i_plots,:)=testdupave_best_lcf_it_bestperf;
    avetotprofit_lcf_it_13(i_plots,:)=avetotprofit_best_lcf_it_bestperf;
    runtimes_lcf_it_13(i_plots,:)=runtimes_total_lcf_it_noperf;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% save the performance info of each of the alternative methods: CLOS-1, LIK-1, CLOS-5, LIK-5,
%%%LCF-DIR, LCF-FM, LCF-FMS, 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numsizes_mthds=7; %number 
numtrials = 100;
testobjave_lcf_mthds=zeros(numsizes_mthds,numtrials); %average objective for each alternative method
testrejave_lcf_mthds=zeros(numsizes_mthds,numtrials);%average number of unmatched requests for each alternative method
testdupave_lcf_mthds=zeros(numsizes_mthds,numtrials);%average number of requests accepted by an unhappy driver for each alternative method
avetotprofit_lcf_mthds=zeros(numsizes_mthds,numtrials);%average profit for each alternative method
runtimes_lcf_mthds=zeros(numsizes_mthds,numtrials);%average runtime for each alternative method



%%%%%%%% first four rows for heuristics
 stem= 'lcf_exp_heur.mat';
    filename =[ 'C:\Users\horneh\documents\LCF_Paper_experiments\' stem];
    load(filename)

    testobjave_lcf_mthds(1,:)=testobjave_clos1(:,1:100);
    testrejave_lcf_mthds(1,:)=testrejave_clos1(:,1:100);
    testdupave_lcf_mthds(1,:)=testdupave_clos1(:,1:100);
    avetotprofit_lcf_mthds(1,:)=avetotprofit_clos1(:,1:100);
    runtimes_lcf_mthds(1,:)=runtimes_clos1(:,1:100);
    
    testobjave_lcf_mthds(2,:)=testobjave_lik1(:,1:100);
    testrejave_lcf_mthds(2,:)=testrejave_lik1(:,1:100);
    testdupave_lcf_mthds(2,:)=testdupave_lik1(:,1:100);
    avetotprofit_lcf_mthds(2,:)=avetotprofit_lik1(:,1:100);
    runtimes_lcf_mthds(2,:)=runtimes_lik1(:,1:100);
    
    testobjave_lcf_mthds(3,:)=testobjave_clos5(:,1:100);
    testrejave_lcf_mthds(3,:)=testrejave_clos5(:,1:100);
    testdupave_lcf_mthds(3,:)=testdupave_clos5(:,1:100);
    avetotprofit_lcf_mthds(3,:)=avetotprofit_clos5(:,1:100);
    runtimes_lcf_mthds(3,:)=runtimes_clos5(:,1:100);
    
    testobjave_lcf_mthds(4,:)=testobjave_lik5(:,1:100);
    testrejave_lcf_mthds(4,:)=testrejave_lik5(:,1:100);
    testdupave_lcf_mthds(4,:)=testdupave_lik5(:,1:100);
    avetotprofit_lcf_mthds(4,:)=avetotprofit_lik5(:,1:100);
    runtimes_lcf_mthds(4,:)=runtimes_lik5(:,1:100);



%%%%%%%% fifth row for lcf base model
 stem= 'lcf_base_modelP10S10.mat';
    filename =[ 'C:\Users\horneh\documents\LCF_Paper_experiments\LCF_base_model\' stem];
    load(filename)

    testobjave_lcf_mthds(5,:)=testobjave_lcf_base(:,1:100);
    testrejave_lcf_mthds(5,:)=testrejave_lcf_base(:,1:100);
    testdupave_lcf_mthds(5,:)=testdupave_lcf_base(:,1:100);
    avetotprofit_lcf_mthds(5,:)=avetotprofit_lcf_base(:,1:100);
    runtimes_lcf_mthds(5,:)=runtimes_lcf_base(:,1:100);
%%%%%%%  lcf-fm
    stem= 'lcf_fmP10S10.mat';
    filename =[ 'C:\Users\horneh\documents\LCF_Paper_experiments\LCF_fm\' stem];
    load(filename)

    testobjave_lcf_mthds(6,:)=testobjave_lcf_fm(:,1:100);
    testrejave_lcf_mthds(6,:)=testrejave_lcf_fm(:,1:100);
    testdupave_lcf_mthds(6,:)=testdupave_lcf_fm(:,1:100);
    avetotprofit_lcf_mthds(6,:)=avetotprofit_lcf_fm(:,1:100);
    runtimes_lcf_mthds(6,:)=runtimes_lcf_fm(:,1:100);
   
%%%%%%%%%%%%%%%%  lcf-fms
   stem= 'lcf_fmsP10FS10VS10.mat';
    filename =[ 'C:\Users\horneh\documents\\LCF_Paper_experiments\LCF_fms\' stem];
    load(filename)

    testobjave_lcf_mthds(7,:)=testobjave_lcf_fms(:,1:100);
    testrejave_lcf_mthds(7,:)=testrejave_lcf_fms(:,1:100);
    testdupave_lcf_mthds(7,:)=testdupave_lcf_fms(:,1:100);
    avetotprofit_lcf_mthds(7,:)=avetotprofit_lcf_fms(:,1:100);
    runtimes_lcf_mthds(7,:)=runtimes_lcf_fms(:,1:100);


%%%%%%%%%%%%%%%%%% save variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stem = 'param_tuning_vals';
  
filename = [ 'C:\Users\horneh\Documents\LCF_Paper_experiments\' stem];
save(filename,...
'numsizes_10','variscen_sizes_lcf_it_10','fixedscen_sizes_lcf_it_10',...
    'testobjave_lcf_it_10','testrejave_lcf_it_10','testdupave_lcf_it_10',...
   'avetotprofit_lcf_it_10','runtimes_lcf_it_10',...
   ...
   'numsizes_1257','variscen_sizes_lcf_it_1257','fixedscen_sizes_lcf_it_1257',...
    'testobjave_lcf_it_1257','testrejave_lcf_it_1257','testdupave_lcf_it_1257',...
   'avetotprofit_lcf_it_1257','runtimes_lcf_it_1257',...
   ...
   'numsizes_13','variscen_sizes_lcf_it_13','fixedscen_sizes_lcf_it_13',...
    'testobjave_lcf_it_13','testrejave_lcf_it_13','testdupave_lcf_it_13',...
   'avetotprofit_lcf_it_13','runtimes_lcf_it_13',...
   ...
    'numsizes_mthds','testobjave_lcf_mthds','testrejave_lcf_mthds','testdupave_lcf_mthds',...
   'avetotprofit_lcf_mthds','runtimes_lcf_mthds', '-v7.3');
end