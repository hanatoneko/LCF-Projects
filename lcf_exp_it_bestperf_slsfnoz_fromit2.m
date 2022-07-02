function[] = lcf_exp_it_bestperf_slsfnoz_fromit2(iteration_max,premium_diff,premiumstr_diff,variscens_lcf_it_bestperf,fixedscens_lcf_it_bestperf,notes_bestperf)
%%% this code does the performance analysis of the recorded best solution, then
%%% a matlab data file is created saving all matlab variables, the file
%%% title includes the number of completed iterations, premium, number of variable and fixed
%%% scenarios used, and any other notes in the notes string,
%%% the variables for the experiment end with _lcf_it_bestperf, and 
%%%(most of) the performance analysis variables/values start with 'test' 

%%%inputs: iteration_max is the final iteration of noperf at which point a solution 
%is returned, premium_diff is the premium*ones(m,n) given a different name from premium because I
%%%accidentally saved premium values in the params and slsf file and
%%%loading the variable file would overwrite the values, premiumstr_diff is
%%% the string to record the premium in the output file, is '75' for .75,
%%% '85' for .85, etc, and '10' for 1.0, variscens__lcf_it_bestperf and 
%%% fixedscens_lcf_it_bestperf are the number of variable and fixed scenarios 
%%% respectively, notes_bestperf is a string that can be added (or left as
%%% '') to distinguish one run of the code from another that has the same
%%% inputs otherwise 

%%% point to the folder containing CPLEX so matlab can run the solver
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio129\CPLEX_Studio\cplex\matlab\x64_win64'));

%%% load info from the final SOL-IT iteration
stem = sprintf('lcf_it_noperf_slsfnoz_fromit2I%dP%sFS%dVS%d%s.mat',iteration_max,premiumstr_diff,fixedscens_lcf_it_bestperf,variscens_lcf_it_bestperf,notes_bestperf);
filename = [ 'C:\Users\horneh\Documents\LCF_Paper_experiments\LCF_it_noperf_diffprem\' stem];
load(filename);


%%% 'best u, p, and ptrue' weren't recorded as bestperf variables in the
%%% made data files, but code was adjusted so they will be recorded in any
%%% new files


%%% when the variable/value is the same for all scenarios (e.g. x, p), the
%%% arrays for each trial are concatenated horizontally. When there is a
%%% variable set for each scenario, the m x n arrays for the same problem
%%% instances are concatenated horizontally across the scenarios, then the
%%% arrays representing all scenarios for each problem instance are concatenated vertically


%%% best soln variables
    xbest_lcf_it_bestperf = xbest_lcf_it_noperf;
    ubest_lcf_it_bestperf = ubest_lcf_it_noperf;
    ptruebest_lcf_it_bestperf = ptruebest_lcf_it_noperf; % is pij, i.e. p double dot rounded down to not exceed 1 
    p_best_lcf_it_bestperf = pbest_lcf_it_noperf; %is p double dot
    
%%%best solution performance info, initialized as slsf soln info
    testyhat_best_lcf_it_bestperf = testyhat_slsf;
    testscenprobs_best_lcf_it_bestperf = testscenprobs_slsf;
    testscenbase_best_lcf_it_bestperf = testscenbase_slsf;
    testscenexp_best_lcf_it_bestperf = testscenexp_slsf;
    
    testobjs_best_lcf_it_bestperf = testobjs_slsf;
    testobjave_best_lcf_it_bestperf = testobjave_slsf;
    testdupave_best_lcf_it_bestperf = testdupave_slsf; %average number of requests accepted by unhappy driver 
    testrejave_best_lcf_it_bestperf = testrejave_slsf; %average number of unmatched requests
    testv_best_lcf_best_it = testv_slsf;
    testz_best_lcf_it_bestperf = testz_slsf;
    testw_best_lcf_it_bestperf = testw_slsf;
    aveassign_best_lcf_it_bestperf = aveassign_slsf; %for a problem instance, it's an m x n array where entry ij is the portion of 
% test scenarios in which request i is assigned to driver j

    avecomp_best_lcf_it_bestperf = avecomp_slsf; %average compensation paid to matched drivers
    aveperccomp_best_lcf_it_bestperf = aveperccomp_slsf; %average compensation divided by the fare paid to matched drivers
    avetotprofit_best_lcf_it_bestperf = avetotprofit_slsf; % average profit made across the test scenarios
    percposprofit_best_lcf_it_bestperf = percposprofit_slsf; %portion of test scenarios that have a positive profit
    aveextratime_best_lcf_it_bestperf = aveextratime_slsf; %average extra driving time for matched drivers

for t=1:trials
    %if the best-found solution is not the initial slsf solution, do
    %performance analysis and save
    if guessbestiter_lcf_it_noperf(1,t) >= 1
       
        %generate random test scenarios
        tic
        [testyhat,testscenprobs,testscenbase,testscenexp] = indepy_generate_scens(xbest_lcf_it_noperf(:,(t-1)*n+1:t*n).*ptruebest_lcf_it_noperf(:,(t-1)*n+1:t*n),testsamps,0);
        toc
        testyhat_best_lcf_it_bestperf((t-1)*m+1:t*m,:) = testyhat;
        testscenprobs_best_lcf_it_bestperf(t,:) = testscenprobs;
        testscenbase_best_lcf_it_bestperf(t,:) = testscenbase;
        testscenexp_best_lcf_it_bestperf(t,:) = testscenexp;
        
         %%% do performance analysis of best soln   
        tic
        [objave,objsd,dupave,dupsd,rejave,rejsd,aveassign,objvals,vfull,zfull,wfull] = sample_cases_performance_indepy(Chatlong(:,(t-1)*n+1:t*n)-ubest_lcf_it_noperf(:,(t-1)*n+1:t*n)-alphavalslong(:,(t-1)*n+1:t*n),Dlong(:,(t-1)*n+1:t*n),zeros(m,1),qlong,xbest_lcf_it_noperf(:,(t-1)*n+1:t*n),ptruebest_lcf_it_noperf(:,(t-1)*n+1:t*n),5000,testyhat,testscenprobs);
        toc

        testobjs_best_lcf_it_bestperf(t,:) = objvals;
        testobjave_best_lcf_it_bestperf(1,t) = objave;
        testdupave_best_lcf_it_bestperf(1,t) = dupave;
        testrejave_best_lcf_it_bestperf(1,t) = rejave;
        testv_best_lcf_it_bestperf((t-1)*m+1:t*m,:) = vfull;
        testz_best_lcf_it_bestperf((t-1)*m+1:t*m,:) = zfull;
        testw_best_lcf_it_bestperf((t-1)*m+1:t*m,:) = wfull;
        aveassign_best_lcf_it_bestperf(:,(t-1)*n+1:t*n) = aveassign;

         % solution quality metrics
        [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare] = quality_metrics(farelong(:,(t-1)*n+1:t*n),alphavalslong(:,(t-1)*n+1:t*n)+ubest_lcf_it_noperf(:,(t-1)*n+1:t*n),extradrivingtimelong(:,(t-1)*n+1:t*n),vfull,wfull);
        avecomp_best_lcf_it_bestperf(1,t) = avecomp;
        aveperccomp_best_lcf_it_bestperf(1,t) = aveperccomp;
        avetotprofit_best_lcf_it_bestperf(1,t) = avetotprofit;
        percposprofit_best_lcf_it_bestperf(1,t) = percposprofit;
        aveextratime_best_lcf_it_bestperf(1,t) = aveextratime;
        
    
   
   
    end
    
    
end

%%% save all active variables into matlab data file 
stem = sprintf('lcf_it_bestperf_slsfnoz_fromit2maxI%dP%sFS%dVS%d%s.mat',iteration_max,premiumstr_diff,fixedscens_lcf_it_bestperf,variscens_lcf_it_bestperf,notes_bestperf);
  
filename = [ 'C:\Users\horneh\Documents\LCF_Paper_experiments\LCF_it_bestperf_diffprem\' stem];
save(filename,'-v7.3');

