function[] = lcf_exp_eq_bestperf(iteration_max,premium_diff,premiumstr_diff,variscens_lcf_it_bestperf,fixedscens_lcf_it_bestperf,eqtype,threshold,notes_bestperf)
%%% this code is very similar to lcf_exp_it_bestperf except it evaluates
%%% SOL-FR solutions instead of SOL-IT (which is really the same process) and we only save relevant variables in the data file
%%% instead of all variables (excluding, for example, indices variables)

%%% this code does the performance analysis of the recorded best solution, then
%%% a matlab data file is created saving all matlab variables, the file
%%% title includes the number of completed iterations,fairness type and threshold, premium, number of variable and fixed
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
%%% respectively, eqtype is the fairness type: 'ch' for closer higher, 'dp' for driver
%%% proximity, and 'eq' for all equal, threshold is the fairness threshold in minutes (if applicable),  notes_bestperf is a string that can be added (or left as
%%% '') to distinguish one run of the code from another that has the same
%%% inputs otherwise 

%%% point to the folder containing CPLEX so matlab can run the solver
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio129\CPLEX_Studio\cplex\matlab\x64_win64'));

stem = sprintf('lcf_eq_noperfI%dP%sFS%dVS%dEq%sT%d%s.mat',iteration_max,premiumstr_diff,fixedscens_lcf_it_bestperf,variscens_lcf_it_bestperf,eqtype,threshold,notes_bestperf);
    filename = [ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Eq_experiments\noperf\' stem];
load(filename);



%%% 'best u, p, and ptrue' weren't recorded as bestperf variables in the
%%% made data files, but code was adjusted so they will be recorded in any
%%% new files

%%% when the variable/value is the same for all scenarios (e.g. x, p), the
%%% arrays for each trial are concatenated horizontally. When there is a
%%% variable set for each scenario, the m x n arrays for the same problem
%%% instances are concatenated horizontally across the scenarios, then the
%%% arrays representing all scenarios for each problem instance are concatenated vertically


%%% info from the final SOL-IT iteration 

    xbest_lcf_it_bestperf = xbest_lcf_it_noperf;
    ubest_lcf_it_bestperf = ubest_lcf_it_noperf;
    ptruebest_lcf_it_bestperf = ptruebest_lcf_it_noperf; % is pij, i.e. p double dot rounded down to not exceed 1 
    pbest_lcf_it_bestperf = pbest_lcf_it_noperf; %is p double dot
    
%%%best solution performance info, initialized as slsf soln info   
    testyhat_best_lcf_it_bestperf = testyhat_slsf;
    testscenprobs_best_lcf_it_bestperf = testscenprobs_slsf;
    testscenbase_best_lcf_it_bestperf = testscenbase_slsf;
    testscenexp_best_lcf_it_bestperf = testscenexp_slsf;
    
    testobjs_best_lcf_it_bestperf = testobjs_slsf;
    testobjave_best_lcf_it_bestperf = testobjave_slsf;
    testdupave_best_lcf_it_bestperf = testdupave_slsf; %average number of requests accepted by unhappy driver 
    testrejave_best_lcf_it_bestperf = testrejave_slsf; %average number of unmatched requests
    testv_best_lcf_it_bestperf = testv_slsf;
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

%%%%%%%%%%%%%%%%% save variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stem = sprintf('lcf_eq_bestperfmaxI%dP%sFS%dVS%dEq%sT%d%s.mat',iteration_max,premiumstr_diff,fixedscens_lcf_it_bestperf,variscens_lcf_it_bestperf,eqtype,threshold,notes_bestperf);
    filename = [ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Eq_experiments\bestperf\' stem];
 



 save(filename, 'Chatlong','Clong', 'Dlong', 'rlong', 'qlong','farelong', 'yprobslong','minitestsize',...
    'slsfcomplong', 'alphavalslong', 'betavalslong', 'OjOiminslong', 'extradrivingtimelong', 'drandlong','mincomp',...
    'Oilong','Dilong','Ojlong','Djlong','eqtype','threshold','mins','iteration','lcfgap',...
    ...
    'yhat_slsf','scenprobs_slsf','scenbase_slsf','scenexp_slsf','simobjs_slsf','x_slsf','v_slsf','z_slsf','w_slsf','runtimes_slsf','gaps_slsf',...
...
...%performance analysis values slsf
'testyhat_slsf','testscenprobs_slsf','testscenbase_slsf','testscenexp_slsf','testobjs_slsf','testobjave_slsf',...
'testdupave_slsf','testrejave_slsf','testv_slsf','testz_slsf','testw_slsf','aveassign_slsf','runtimes_perf_slsf',...
...
...%quality metrics for slsf
'avecomp_slsf','aveperccomp_slsf','avetotprofit_slsf','percposprofit_slsf','aveextratime_slsf','averejfare_slsf',...
...%LCF fixed scenarios
'yhat_lcfinput','scenprobs_lcfinput','scenbase_lcfinput','scenexp_lcfinput','runtimes_scens_lcfinput',...
...%slsf/best minitest info
'testyhat_mini_slsf','testscenprobs_mini_slsf','testscenbase_mini_slsf','testscenexp_mini_slsf',...
'runtimes_mini_slsf','testobjave_mini_slsf','testrejave_mini_slsf','testdupave_mini_slsf',...
'bestsoln_mini_obj_lcf_it_noperf','bestsoln_mini_rej_lcf_it_noperf','bestsoln_mini_dup_lcf_it_noperf','guessbestiter_lcf_it_noperf','times_soln_updated_lcf_it_noperf',...    
...%soln info on best found, initialized as slsf soln info
'xbest_lcf_it_noperf','ubest_lcf_it_noperf','ptruebest_lcf_it_noperf','pbest_lcf_it_noperf','DensityNumsBest',...
...%%%%%% LCF iter 1 soln varis    
'x_lcf_it_noperf','DensityNumsLong','simobjs_lcf_it_noperf','v_lcf_it_noperf','w_lcf_it_noperf','y_lcf_it_noperf','p_lcf_it_noperf','ptrue_lcf_it_noperf',...
'u_lcf_it_noperf','psi_lcf_it_noperf','runtimes_lcf_it_noperf','gaps_lcf_it_noperf','runtimes_lcf_it_noperf',...
...%%% miniteset for lcf iter 1 soln variables
'testyhat_mini_lcf_it_noperf','testscenprobs_mini_lcf_it_noperf','testscenbase_mini_lcf_it_noperf','testscenexp_mini_lcf_it_noperf',...
'runtimes_mini_lcf_it_noperf','testobjave_mini_lcf_it_noperf','testrejave_mini_lcf_it_noperf','testdupave_mini_lcf_it_noperf',...
...
'comp_old_lcf_it_noperf','u_old_lcf_it_noperf','runtimes_total_lcf_it_noperf',...
...%%%% bestperf varis
'xbest_lcf_it_bestperf', 'ubest_lcf_it_bestperf', 'ptruebest_lcf_it_bestperf','pbest_lcf_it_bestperf',...
'testobjs_best_lcf_it_bestperf', 'testobjave_best_lcf_it_bestperf', 'testdupave_best_lcf_it_bestperf', ...
'testrejave_best_lcf_it_bestperf', 'testyhat_best_lcf_it_bestperf', 'testscenprobs_best_lcf_it_bestperf',... 
'testv_best_lcf_it_bestperf', 'testz_best_lcf_it_bestperf',... 
'testw_best_lcf_it_bestperf', 'aveassign_best_lcf_it_bestperf', 'avecomp_best_lcf_it_bestperf',... 
'aveperccomp_best_lcf_it_bestperf', 'avetotprofit_best_lcf_it_bestperf',...
'percposprofit_best_lcf_it_bestperf', 'aveextratime_best_lcf_it_bestperf',... 
'-v7.3');
