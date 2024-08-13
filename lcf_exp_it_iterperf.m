function[] = lcf_exp_it_iterperf(iterperfiter,iteration_max,premium_diff,premiumstr_diff,variscens_lcf_it_noperf,fixedscens_lcf_it_noperf)
%%% this code completes the full performance analysis (not the minitest) on one SOL-IT iteration's solution of the experiment for SOL-IT,
%%% using the input data from the parameters and initial slsf experiment. For each problem instance/trial,
%%% the specified iteration's solution undergoes performance anlysis then
%%% a matlab data file is created saving all matlab variables, the file
%%% title includes the iteration, premium, number of variable and fixed
%%% scenarios used, and any other notes in the notes string,
%%% the normal performance analysis is not run each iteration, instead
%%% lcf_exp_it_bestperf does the performance analysis of the final returned
%%% solution
%%% the variables for the analysis end with _lcf_it_iterperf,  before the lcf_it_noperf 

%%%inputs: iterperfiter is what iteration is to be performance analyzed, premium_diff is the
%%%premium*ones(m,n) given a different name from premium because I
%%%accidentally saved premium values in the params and slsf file and
%%%loading the variable file would overwrite the values, premiumstr_diff is
%%% the string to record the premium in the output file, is '75' for .75,
%%% '85' for .85, etc, and '10' for 1.0, variscens__lcf_it_noperf and 
%%% fixedscens_lcf_it_noperf are the number of variable and fixed scenarios 
%%% respectively



iteration = iterperfiter;


%%% point to the folder containing CPLEX so matlab can run the solver
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio129\CPLEX_Studio\cplex\matlab\x64_win64'));

%%% load the information from the best-found solution (final analysis)
stem = sprintf('lcf_it_bestperfmaxI%dP%sFS%dVS%d%s.mat',iteration_max,premiumstr_diff,fixedscens_lcf_it_noperf,variscens_lcf_it_noperf,'');
filename = [ 'C:\Users\horneh\Documents\LCF_Paper_experiments\LCF_it_bestperf\' stem];
load(filename);

iteration
iterperfiter

%save values under different name
guessbestiter_lcf_it_final = guessbestiter_lcf_it_noperf
times_soln_updated_lcf_it_final  = times_soln_updated_lcf_it_noperf

%load the information from noperf for that iteration
stem = sprintf('lcf_it_noperfI%dP%sFS%dVS%d%s.mat',iterperfiter,premiumstr_diff,fixedscens_lcf_it_noperf,variscens_lcf_it_noperf,'')
filename = [ 'C:\Users\horneh\Documents\LCF_Paper_experiments\LCF_it_noperf\' stem];
load(filename);

iteration
iterperfiter

%%%% intitialize soln vals as best soln

    testyhat_lcf_it_iterperf = testyhat_best_lcf_it_bestperf;
    testscenprobs_lcf_it_iterperf = testscenprobs_best_lcf_it_bestperf;
    testscenbase_lcf_it_iterperf = testscenbase_best_lcf_it_bestperf;
    testscenexp_lcf_it_iterperf = testscenexp_best_lcf_it_bestperf;
    
    testobjs_lcf_it_iterperf = testobjs_best_lcf_it_bestperf;
    testobjave_lcf_it_iterperf = testobjave_best_lcf_it_bestperf;
    testdupave_lcf_it_iterperf = testdupave_best_lcf_it_bestperf;
    testrejave_lcf_it_iterperf = testrejave_best_lcf_it_bestperf;
    testv_lcf_it_iterperf = testv_best_lcf_best_it;
    testz_lcf_it_iterperf = testz_best_lcf_it_bestperf;
    testw_lcf_it_iterperf = testw_best_lcf_it_bestperf;
    aveassign_lcf_it_iterperf = aveassign_best_lcf_it_bestperf;

    avecomp_lcf_it_iterperf = avecomp_best_lcf_it_bestperf;
    aveperccomp_lcf_it_iterperf = aveperccomp_best_lcf_it_bestperf;
    avetotprofit_lcf_it_iterperf = avetotprofit_best_lcf_it_bestperf;
    percposprofit_lcf_it_iterperf = percposprofit_best_lcf_it_bestperf;
    aveextratime_lcf_it_iterperf = aveextratime_best_lcf_it_bestperf;

    
    for t=1:trials
        
        %if current iteration is not the one that has the best soln, do
        %perf analysis
        if guessbestiter_lcf_it_final(1,t)~= iterperfiter
            
            %generate random test scenarios
            tic
            [testyhat,testscenprobs,testscenbase,testscenexp] = indepy_generate_scens(x_lcf_it_noperf(:,(t-1)*n+1:t*n).*ptrue_lcf_it_noperf(:,(t-1)*n+1:t*n),testsamps,0);
            toc
            testyhat_lcf_it_iterperf((t-1)*m+1:t*m,:) = testyhat;
            testscenprobs_lcf_it_iterperf(t,:) = testscenprobs;
            testscenbase_lcf_it_iterperf(t,:) = testscenbase;
            testscenexp_lcf_it_iterperf(t,:) = testscenexp;
            
            %do the performance analysis
            tic
            [objave,objsd,dupave,dupsd,rejave,rejsd,aveassign,objvals,vfull,zfull,wfull] = sample_cases_performance_indepy(Chatlong(:,(t-1)*n+1:t*n)-u_lcf_it_noperf(:,(t-1)*n+1:t*n)-alphavalslong(:,(t-1)*n+1:t*n),Dlong(:,(t-1)*n+1:t*n),zeros(m,1),qlong,x_lcf_it_noperf(:,(t-1)*n+1:t*n),ptrue_lcf_it_noperf(:,(t-1)*n+1:t*n),5000,testyhat,testscenprobs);
            toc

            testobjs_lcf_it_iterperf(t,:) = objvals;
            testobjave_lcf_it_iterperf(1,t) = objave;
            testdupave_lcf_it_iterperf(1,t) = dupave;
            testrejave_lcf_it_iterperf(1,t) = rejave;
            testv_lcf_it_iterperf((t-1)*m+1:t*m,:) = vfull;
            testz_lcf_it_iterperf((t-1)*m+1:t*m,:) = zfull;
            testw_lcf_it_iterperf((t-1)*m+1:t*m,:) = wfull;
            aveassign_lcf_it_iterperf(:,(t-1)*n+1:t*n) = aveassign;

             % quality metrics
            [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare] = quality_metrics(farelong(:,(t-1)*n+1:t*n),alphavalslong(:,(t-1)*n+1:t*n)+ubest_lcf_it_noperf(:,(t-1)*n+1:t*n),extradrivingtimelong(:,(t-1)*n+1:t*n),vfull,wfull);
            avecomp_lcf_it_iterperf(1,t) = avecomp;
            aveperccomp_lcf_it_iterperf(1,t) = aveperccomp;
            avetotprofit_lcf_it_iterperf(1,t) = avetotprofit;
            percposprofit_lcf_it_iterperf(1,t) = percposprofit;
            aveextratime_lcf_it_iterperf(1,t) = aveextratime;

            
            
            
        end
        
        
        
    end

%update the old compensation and u, update runtime   
stem = sprintf('lcf_it_iterperfI%dP%sFS%dVS%d%s.mat',iterperfiter,premiumstr_diff,fixedscens_lcf_it_noperf,variscens_lcf_it_noperf,'');
  
filename = [ 'C:\Users\horneh\Documents\LCF_Paper_experiments\LCF_IT_iterperf\' stem];
save(filename,'-v7.3');


