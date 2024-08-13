%this code is basically the same code as load_eq_insights except this code
%considers all of the settings experiments that were run for the fairness
%paper

%When we conduct the SOL-FR experiments, each experiment/setting (premium, fairness type and threshold) is run individually
%and has its own data file produced. To make it easier to directly compare
%the performance of different experiments, this code produces a single matlab
%data file named 'concat_vals_eq_forall.mat' that contains performance information from every experiment by loading every experiment
%one at a time and adding that experiment's information into a set of
%larger variables that are concatenated variables from the experiments.

%The _concat variables are each iteration's info vertically concatenated,
%that is the slsf info (if applicable) is on the top, then the SOL-IT
%info then experiment 3 then 4 and so on



% stem = 'concat_vals_eq.mat';  
%  filename = [ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Eq_experiments\' stem];
% 
%  load(filename)


trials = 100;
numiters = 10;
m = 20;
n = 20;
minitestsize = 200;
testsamps = 5000;
fixedscens_lcf_it = 5;
variscens_lcf_it = 5;
NumMetrics = 4;
NumExperiments = 17; %The total number for experiments including the SLSF and SOL-IT experiments from the compensation paper
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% %%%%%% initialize storage variables %%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% the variables for each experiment are concatenated vertically into a
%%% longer variable that ends in _concat

guessbestiter_concat = zeros(NumExperiments-1,trials); %the iteration with the returned solution
% 
DensityNumsBest_concat = zeros(m*(NumExperiments),NumMetrics*trials); %constraint density info
compinmenu_all_concat = zeros(m*(NumExperiments),n*trials); %the compensation used by the best solution
compinmenu_noslsf_concat = zeros(m*(NumExperiments),n*trials); %same as previous except the SLSF compensation 
%(as the first experiment and for any experiment trials where the initial
%SLSF solution is returned) are left as zeros


% %soln variable info 
xbest_lcf_it_concat = zeros(m*(NumExperiments),n*trials);
pbest_lcf_it_concat = zeros(m*(NumExperiments),n*trials);
ptruebest_lcf_it_concat = zeros(m*(NumExperiments),n*trials);
ubest_lcf_it_concat = zeros(m*(NumExperiments),n*trials);




% %soln info for large perf analysisc
testyhat_lcf_it_concat = zeros(m*trials*(NumExperiments),n*testsamps);
testscenprobs_lcf_it_concat = zeros(trials*(NumExperiments),testsamps);
testobjs_lcf_it_concat = zeros(trials*(NumExperiments),testsamps);
testobjave_lcf_it_concat = zeros(NumExperiments,trials);
testdupave_lcf_it_concat = zeros(NumExperiments,trials);
testrejave_lcf_it_concat = zeros(NumExperiments,trials);
testv_lcf_it_concat = zeros(m*trials*(NumExperiments),n*testsamps);
testz_lcf_it_concat = zeros(m*trials*(NumExperiments),n*testsamps);
testw_lcf_it_concat = zeros(m*trials*(NumExperiments),testsamps);
aveassign_lcf_it_concat = zeros(m*(NumExperiments),n*trials);

%%% performance metrics
avecomp_lcf_it_concat = zeros(NumExperiments,trials);
aveperccomp_lcf_it_concat = zeros(NumExperiments,trials);
avetotprofit_lcf_it_concat = zeros(NumExperiments,trials);
percposprofit_lcf_it_concat = zeros(NumExperiments,trials);
aveextratime_lcf_it_concat = zeros(NumExperiments,trials);


%%% performance metrics that are calculated when the test scenarios are
%%% relatively weighted by liklihood, rather than equal weighting used in
%%% the other variables
avecomp_withwts_lcf_it_concat = zeros(NumExperiments,trials);
aveperccomp_withwts_lcf_it_concat = zeros(NumExperiments,trials);
avetotprofit_withwts_lcf_it_concat = zeros(NumExperiments,trials);
percposprofit_withwts_lcf_it_concat = zeros(NumExperiments,trials);
aveextratime_withwts_lcf_it_concat = zeros(NumExperiments,trials);


% %%%%%%%%%%%%%%%%%load slsf as first 'row' (first experiment so at the top
% of each array)
%%% load the slsf info
load('C:\Users\horneh\Documents\LCF_Paper_experiments\parameter_values\paramandslsf.mat');
ubest_lcf_it_concat(1:m,:) = -1*ones(m,n*trials);
pbest_lcf_it_concat(1:m,:) = yprobslong;
ptruebest_lcf_it_concat(1:m,:) = yprobslong;
xbest_lcf_it_concat(1:m,:) = x_slsf;

compinmenu_all_concat(1:m,:) = slsfcomplong;

%soln info for large perf analysisc(slsf is first 'line')
testyhat_lcf_it_concat(1:m*trials,:) = testyhat_slsf;
testscenprobs_lcf_it_concat(1:trials,:) = testscenprobs_slsf;
testobjs_lcf_it_concat(1:trials,:) = testobjs_slsf;
testobjave_lcf_it_concat(1,:) = testobjave_slsf;
testdupave_lcf_it_concat(1,:) = testdupave_slsf;
testrejave_lcf_it_concat(1,:) = testrejave_slsf;
testv_lcf_it_concat(1:m*trials,:) = testv_slsf;
testz_lcf_it_concat(1:m*trials,:) = testz_slsf;
testw_lcf_it_concat(1:m*trials,:) = testw_slsf;
aveassign_lcf_it_concat(1:m,:) = aveassign_slsf;

%%%%record quality metrics for slsf w/ scenprobs
    for t = 1:trials
        [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare] = quality_metrics_with_scenprobs(farelong(:,(t-1)*n+1:t*n),slsfcomplong(:,(t-1)*n+1:t*n),extradrivingtimelong(:,(t-1)*n+1:t*n),testscenprobs_slsf(t,:),testv_slsf((t-1)*m+1:t*m,:),testw_slsf((t-1)*m+1:t*m,:));
%         avecomp_slsf(1,t) = avecomp;
%         aveperccomp_slsf(1,t) = aveperccomp;
%         avetotprofit_slsf(1,t) = avetotprofit;
%         percposprofit_slsf(1,t) = percposprofit;
%         aveextratime_slsf(1,t) = aveextratime;
%         averejfare_slsf(1,t) = averejfare;
%         
        avecomp_withwts_lcf_it_concat(1,t) = avecomp;
        aveperccomp_withwts_lcf_it_concat(1,t) = aveperccomp;
        avetotprofit_withwts_lcf_it_concat(1,t) = avetotprofit;
        percposprofit_withwts_lcf_it_concat(1,t) = percposprofit;
        aveextratime_withwts_lcf_it_concat(1,t) = aveextratime;
        averejfare_withwts_lcf_it_concat(1,t) = averejfare;
        
        avecomp_lcf_it_concat(1,t) = avecomp_slsf(1,t);
        aveperccomp_lcf_it_concat(1,t) = aveperccomp_slsf(1,t);
        avetotprofit_lcf_it_concat(1,t) = avetotprofit_slsf(1,t);
        percposprofit_lcf_it_concat(1,t) = percposprofit_slsf(1,t);
        aveextratime_lcf_it_concat(1,t) = aveextratime_slsf(1,t);
        averejfare_lcf_it_concat(1,t) = averejfare_slsf(1,t);
    end
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%% load and save for each Experiment (eq
% type/threshold/preimium)
% %%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%each of these three vectors has the info for each experiment, for example
%experiment 3 is driver proximity with threshold 10 minuts and premium
%0.75. The first experiment is SLSF and the second is SOL-IT and the rest
%are SOL-FR with different settings.
eqtype_concat = ['na';'na';'dp';'dp';'dp';'dp';'dp';'dp';'ch';'ch';'ch';'ch';'ch';'ch';'eq';'eq';'eq'];
threshold_concat = [0,0,10,10,10,20,20,20,3,3,3,10,10,10,0,0,0];
premiumstr_concat = ['na';'na';'75';'87';'10';'75';'87';'10';'75';'87';'10';'75';'87';'10';'75';'87';'10'];

for i_concat = 2:NumExperiments
   
    %load the experiment info
    if i_concat == 2
        stem = sprintf('lcf_it_bestperfmaxI%dP10FS5VS5.mat',10);
         filename = [ 'C:\Users\horneh\Documents\LCF_Paper_experiments\LCF_IT_bestperf\' stem];
        load(filename);
    else
        stem = sprintf('lcf_eq_bestperfmaxI%dP%sFS%dVS%dEq%sT%d%s.mat',10,premiumstr_concat(i_concat,:),5,5,eqtype_concat(i_concat,:),threshold_concat(1,i_concat),'');
        filename = [ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Eq_experiments\bestperf\' stem];

        load(filename)
    
    end

%      % v_lcf_it_concat((i_concat-1)*m*trials+1:m*trials*(i_concat),:) = v_lcf_it_noperf;
      guessbestiter_concat(i_concat,:)= guessbestiter_lcf_it_noperf;
      if i_concat > 2
        DensityNumsBest_concat( (i_concat-1)*m+1:m*i_concat,:)= DensityNumsBest;
      end
      
    %soln variable info 
    xbest_lcf_it_concat((i_concat-1)*m+1:m*i_concat,:) =  xbest_lcf_it_noperf;
    pbest_lcf_it_concat((i_concat-1)*m+1:m*i_concat,:) = pbest_lcf_it_noperf;
    ptruebest_lcf_it_concat((i_concat-1)*m+1:m*i_concat,:) = ptruebest_lcf_it_noperf;
    ubest_lcf_it_concat((i_concat-1)*m+1:m*i_concat,:) = ubest_lcf_it_noperf;
   

    %soln info for large perf analysisc(slsf is first 'line')
    testyhat_lcf_it_concat((i_concat-1)*m*trials+1:m*trials*(i_concat),:) = testyhat_best_lcf_it_bestperf;
    testscenprobs_lcf_it_concat((i_concat-1)*trials+1:(i_concat)*trials,:) = testscenprobs_best_lcf_it_bestperf;
    testobjs_lcf_it_concat((i_concat-1)*trials+1:(i_concat)*trials,:) = testobjs_best_lcf_it_bestperf;
    testobjave_lcf_it_concat(i_concat,:) = testobjave_best_lcf_it_bestperf;
    testdupave_lcf_it_concat(i_concat,:) = testdupave_best_lcf_it_bestperf;
    testrejave_lcf_it_concat(i_concat,:) = testrejave_best_lcf_it_bestperf;
    if i_concat == 2
       for t = 1:trials
           %this puts the SLSF assignment into the testv_best variable for
           %SOL-IT solns where the initial SLSF soln is returned
        if guessbestiter_lcf_it_noperf(1,t) == 0
            testv_best_lcf_it_bestperf((t-1)*m+1:t*m,:) = testv_lcf_it_concat((t-1)*m+1:t*m,:); 
           
        else
            
        end
       end
    end
    testv_lcf_it_concat((i_concat-1)*m*trials+1:m*trials*(i_concat),:) = testv_best_lcf_it_bestperf;
    testz_lcf_it_concat((i_concat-1)*m*trials+1:m*trials*(i_concat),:) = testz_best_lcf_it_bestperf;
    testw_lcf_it_concat((i_concat-1)*m*trials+1:m*trials*(i_concat),:) = testw_best_lcf_it_bestperf;
    aveassign_lcf_it_concat((i_concat-1)*m+1:(i_concat)*m,:) = aveassign_best_lcf_it_bestperf;

    %%% calculate the quality metrics with scenprobs

    for t =1:trials
        
        %if SOL-FR for the given experiment returns the initial SLSF
        %solution, just put in the slsf info
       if guessbestiter_lcf_it_noperf(1,t) == 0
           ubest_lcf_it_concat((i_concat-1)*m+1:i_concat*m,(t-1)*n+1:t*n) = -1*ones(m,n);
           pbest_lcf_it_concat((i_concat-1)*m+1:i_concat*m,(t-1)*n+1:t*n) = yprobslong(:,(t-1)*n+1:t*n);
           ptruebest_lcf_it_concat((i_concat-1)*m+1:i_concat*m,(t-1)*n+1:t*n) = yprobslong(:,(t-1)*n+1:t*n);
           
            compinmenu_all_concat((i_concat-1)*m+1:i_concat*m,(t-1)*n+1:t*n) = slsfcomplong(:,(t-1)*n+1:t*n);

            avecomp_withwts_lcf_it_concat(i_concat,t) = avecomp_withwts_lcf_it_concat(1,t);
            aveperccomp_withwts_lcf_it_concat(i_concat,t) = aveperccomp_withwts_lcf_it_concat(1,t);
            avetotprofit_withwts_lcf_it_concat(i_concat,t) = avetotprofit_withwts_lcf_it_concat(1,t);
            percposprofit_withwts_lcf_it_concat(i_concat,t) = percposprofit_withwts_lcf_it_concat(1,t);
            aveextratime_withwts_lcf_it_concat(i_concat,t) = aveextratime_withwts_lcf_it_concat(1,t);
            averejfare_withwts_lcf_it_concat(i_concat,t) = averejfare_withwts_lcf_it_concat(1,t);
            
            avecomp_lcf_it_concat(i_concat,t) = avecomp_lcf_it_concat(1,t);
            aveperccomp_lcf_it_concat(i_concat,t) = aveperccomp_lcf_it_concat(1,t);
            avetotprofit_lcf_it_concat(i_concat,t) = avetotprofit_lcf_it_concat(1,t);
            percposprofit_lcf_it_concat(i_concat,t) = percposprofit_lcf_it_concat(1,t);
            aveextratime_lcf_it_concat(i_concat,t) = aveextratime_lcf_it_concat(1,t);
            averejfare_lcf_it_concat(i_concat,t) = averejfare_lcf_it_concat(1,t);

       else
            compinmenu_all_concat((i_concat-1)*m+1:i_concat*m,(t-1)*n+1:t*n) = xbest_lcf_it_noperf(:,(t-1)*n+1:t*n).*(ubest_lcf_it_noperf(:,(t-1)*n+1:t*n)+alphavalslong(:,(t-1)*n+1:t*n));
            compinmenu_noslsf_concat((i_concat-1)*m+1:i_concat*m,(t-1)*n+1:t*n) = xbest_lcf_it_noperf(:,(t-1)*n+1:t*n).*(ubest_lcf_it_noperf(:,(t-1)*n+1:t*n)+alphavalslong(:,(t-1)*n+1:t*n));

   
           [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare] = quality_metrics_with_scenprobs(farelong(:,(t-1)*n+1:t*n),...
               alphavalslong(:,(t-1)*n+1:t*n)+ubest_lcf_it_bestperf(:,(t-1)*n+1:t*n),extradrivingtimelong(:,(t-1)*n+1:t*n),testscenprobs_best_lcf_it_bestperf(t,:),...
                    testv_best_lcf_it_bestperf((t-1)*m+1:t*m,:),testw_best_lcf_it_bestperf((t-1)*m+1:t*m,:));
            avecomp_withwts_lcf_it_concat(i_concat,t) = avecomp;
            aveperccomp_withwts_lcf_it_concat(i_concat,t) = aveperccomp;
            avetotprofit_withwts_lcf_it_concat(i_concat,t) = avetotprofit;
            percposprofit_withwts_lcf_it_concat(i_concat,t) = percposprofit;
            aveextratime_withwts_lcf_it_concat(i_concat,t) = aveextratime;
            averejfare_withwts_lcf_it_concat(i_concat,t) = averejfare;
            
            avecomp_lcf_it_concat(i_concat,t) = avecomp_best_lcf_it_bestperf(1,t);
            aveperccomp_lcf_it_concat(i_concat,t) = aveperccomp_best_lcf_it_bestperf(1,t);
            avetotprofit_lcf_it_concat(i_concat,t) = avetotprofit_best_lcf_it_bestperf(1,t);
            percposprofit_lcf_it_concat(i_concat,t) = percposprofit_best_lcf_it_bestperf(1,t);
            aveextratime_lcf_it_concat(i_concat,t) = aveextratime_best_lcf_it_bestperf(1,t);
            %averejfare_lcf_it_concat(i_concat,t) = averejfare_best_lcf_it_bestperf(1,t);
       end
    end
    
end



%%%%%%%%%%%%%%%%% save variables into matlab data file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  stem = 'concat_vals_eq_forall.mat';
% %   
 filename = [ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Eq_experiments\' stem];
 save(filename, 'Chatlong','Clong', 'Dlong', 'rlong', 'farelong', 'yprobslong',...
    'slsfcomplong', 'alphavalslong', 'betavalslong', 'OjOiminslong', 'extradrivingtimelong', 'drandlong',...
    ...
    'Oilong','Dilong','Ojlong','Djlong','guessbestiter_concat',...
      'xbest_lcf_it_concat', 'pbest_lcf_it_concat',...
     'ptruebest_lcf_it_concat', 'ubest_lcf_it_concat','DensityNumsBest_concat', ...
     'compinmenu_all_concat','compinmenu_noslsf_concat',...
     ...
     'testyhat_lcf_it_concat', 'testscenprobs_lcf_it_concat', 'testobjs_lcf_it_concat',...
     'testobjave_lcf_it_concat', 'testdupave_lcf_it_concat', 'testrejave_lcf_it_concat',...
     'testv_lcf_it_concat', 'testz_lcf_it_concat', 'testw_lcf_it_concat', 'aveassign_lcf_it_concat',...
     ...
     'avecomp_lcf_it_concat', 'aveperccomp_lcf_it_concat', 'avetotprofit_lcf_it_concat','averejfare_lcf_it_concat',...
     'percposprofit_lcf_it_concat', 'aveextratime_lcf_it_concat',...
     'avecomp_withwts_lcf_it_concat', 'aveperccomp_withwts_lcf_it_concat', 'avetotprofit_withwts_lcf_it_concat',...
     'averejfare_withwts_lcf_it_concat','percposprofit_withwts_lcf_it_concat', 'aveextratime_withwts_lcf_it_concat',...
     '-v7.3');
 
