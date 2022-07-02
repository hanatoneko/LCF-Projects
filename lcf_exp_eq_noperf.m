function[] = lcf_exp_eq_noperf(newiter,premium_diff,premiumstr_diff,variscens_lcf_it_noperf,fixedscens_lcf_it_noperf,eqtype,threshold,notes_noperf)
%%% this code is very similar to lcf_exp_it_noperf except it runs SOL-FR
%%% instead of SOL-IT and we only save relevant variables in the data file
%%% instead of all variables (excluding, for example, indices variables)
%%% this code completes one iteration of the experiment for SOL-FR,
%%% using the input data from the parameters and initial slsf experiment (and info from previous iterations). For each problem instance/trial,
%%% LCF-FR is run and the small performance analysis is conducted, then
%%% a matlab data file is created saving all matlab variables, the file
%%% title includes the iteration, fairness type and threshold, premium, number of variable and fixed
%%% scenarios used, and any other notes in the notes string,
%%% the normal performance analysis is not run each iteration, instead
%%% lcf_exp_eq_bestperf does the performance analysis of the final returned
%%% solution
%%% the variables for the experiment end with _lcf_it_noperf, the small performance analysis variables/values have 'mini' before the lcf_it_noperf 

%%%inputs: newiter is what iteration is to be performed, premium_diff is the
%%%premium*ones(m,n) given a different name from premium because I
%%%accidentally saved premium values in the params and slsf file and
%%%loading the variable file would overwrite the values (I also accidentally
%%% saved 'minitestsize=200' in the file so a different number of scenarios for 
%%% the small performance analysis size would need to be overwritten by adding 
%%% 'minitestsize=[your new size]' after the data files are loaded or by rerunning 
%%% the params_slsf file to make a new data file, premiumstr_diff is
%%% the string to record the premium in the output file, is '75' for .75,
%%% '85' for .85, etc, and '10' for 1.0, variscens__lcf_it_noperf and 
%%% fixedscens_lcf_it_noperf are the number of variable and fixed scenarios 
%%% respectively, eqtype is the fairness type: 'ch' for closer higher, 'dp' for driver
%%% proximity, and 'eq' for all equal, threshold is the fairness threshold in minutes (if applicable), 
%%% notes_noperf is a string that can be added (or left as
%%% '') to distinguish one run of the code from another that has the same
%%% inputs otherwise 

%%% point to the folder containing CPLEX so matlab can run the solver
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio129\CPLEX_Studio\cplex\matlab\x64_win64'));

iteration = newiter;
NumMetrics = 4; %his is an input for the constraint density calculation, since the 
%%% function was designed to be able to add more metrics

%%% load the previous iteration's data (includes initial problem data), or
%%% load initial problem data if it's the first iteration
if iteration == 1

    load('C:\Users\horneh\Documents\LCF_Paper_experiments\parameter_values\paramandslsf.mat');

else
   stem = sprintf('lcf_eq_noperfI%dP%sFS%dVS%dEq%sT%d%s.mat',iteration-1,premiumstr_diff,fixedscens_lcf_it_noperf,variscens_lcf_it_noperf,eqtype,threshold,notes_noperf);
    filename = [ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Eq_experiments\noperf\' stem];
    load(filename);
    
    iteration = iteration + 1
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%for iteration 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% when the variable/value is the same for all scenarios (e.g. x, p), the
%%% arrays for each trial are concatenated horizontally. When there is a
%%% variable set for each scenario, the m x n arrays for the same problem
%%% instances are concatenated horizontally across the scenarios, then the
%%% arrays representing all scenarios for each problem instance are concatenated vertically


%%% if iteration 1, make blank variable arrays for best found soln
if iteration == 1
    
     %%% small performance analysis of the slsf menus from the parameter
    %%% input file, using the _slsf suffix for the arrays
    testyhat_mini_slsf = zeros(m*trials,n*minitestsize);
    testscenprobs_mini_slsf = zeros(trials,minitestsize);
    testscenbase_mini_slsf = zeros(trials,minitestsize);
    testscenexp_mini_slsf = zeros(trials,minitestsize);
    
    runtimes_mini_slsf = zeros(1,trials);
    testobjave_mini_slsf = zeros(1,trials);
    testrejave_mini_slsf = zeros(1,trials);
    testdupave_mini_slsf = zeros(1,trials);
    
    bestsoln_mini_obj_lcf_it_noperf = zeros(1,trials);
    bestsoln_mini_rej_lcf_it_noperf = zeros(1,trials);
    bestsoln_mini_dup_lcf_it_noperf = zeros(1,trials);
    guessbestiter_lcf_it_noperf = zeros(1,trials);
    times_soln_updated_lcf_it_noperf = zeros(1,trials);
    
    %%% slsf minitest (small performance analysis test)
    for t = 1:trials
    %%% generate random test scenarios
    tic
    [testyhat,testscenprobs,testscenbase,testscenexp] = indepy_generate_scens(x_slsf(:,(t-1)*n+1:t*n).*yprobslong(:,(t-1)*n+1:t*n),minitestsize,0);
    toc
    
    runtimes_mini_slsf(1,t) = toc;
    testyhat_mini_slsf((t-1)*m+1:t*m,:) = testyhat;
    testscenprobs_mini_slsf(t,:) = testscenprobs;
    testscenbase_mini_slsf(t,:) = testscenbase;
    testscenexp_mini_slsf(t,:) = testscenexp;

    %%% perform the slsf small performance analysis and save values
    tic
    [objave,objsd,dupave,dupsd,rejave,rejsd,aveassign,objvals,vfull,zfull,wfull] = sample_cases_performance_indepy(Clong(:,(t-1)*n+1:t*n),Dlong(:,(t-1)*n+1:t*n),rlong(:,t),qlong,x_slsf(:,(t-1)*n+1:t*n),yprobslong(:,(t-1)*n+1:t*n),minitestsize,testyhat,testscenprobs);
    toc
    
    runtimes_mini_slsf(1,t) = runtimes_mini_slsf(1,t) + toc;
    testobjave_mini_slsf(1,t) = objave;
    testrejave_mini_slsf(1,t) = rejave;
    testdupave_mini_slsf(1,t) = dupave;
    
    bestsoln_mini_obj_lcf_it_noperf(1,t) = objave;
    bestsoln_mini_rej_lcf_it_noperf(1,t) = rejave;
    bestsoln_mini_dup_lcf_it_noperf(1,t) = dupave;
    
    end
   
    
    
    %soln info on best found, initialized as slsf soln info
    xbest_lcf_it_noperf = x_slsf;
    ubest_lcf_it_noperf = zeros(m,n*trials);
    ptruebest_lcf_it_noperf = zeros(m,n*trials); % is pij, i.e. p double dot rounded down to not exceed 1
    pbest_lcf_it_noperf = zeros(m,n*trials); %is p double dot 
    DensityNumsBest = zeros(m,NumMetrics*trials);

   
    %%%%%% initialize the LCF solution variables/values  
    x_lcf_it_noperf = x_slsf;
    DensityNumsLong = zeros(m,NumMetrics*trials);

    simobjs_lcf_it_noperf = zeros(1,trials);
    v_lcf_it_noperf = zeros(m*trials,n*(fixedscens_lcf_it_noperf+variscens_lcf_it_noperf));
    w_lcf_it_noperf = zeros(m*trials,(fixedscens_lcf_it_noperf+variscens_lcf_it_noperf));
    y_lcf_it_noperf = zeros(m*trials,n*variscens_lcf_it_noperf);
    p_lcf_it_noperf = zeros(m,n*trials);
    ptrue_lcf_it_noperf = zeros(m,n*trials);
    u_lcf_it_noperf = zeros(m,n*trials);
    psi_lcf_it_noperf = zeros(m*trials,n*(fixedscens_lcf_it_noperf+variscens_lcf_it_noperf));
    runtimes_lcf_it_noperf = zeros(1,trials);
    gaps_lcf_it_noperf = zeros(1,trials);
    runtimes_lcf_it_noperf = zeros(1,trials);
    
    %%% miniteset for lcf iter 1 soln variables
     testyhat_mini_lcf_it_noperf = zeros(m*trials,n*minitestsize);
    testscenprobs_mini_lcf_it_noperf = zeros(trials,minitestsize);
    testscenbase_mini_lcf_it_noperf = zeros(trials,minitestsize);
    testscenexp_mini_lcf_it_noperf = zeros(trials,minitestsize);
    
    runtimes_mini_lcf_it_noperf = zeros(1,trials);
    testobjave_mini_lcf_it_noperf = zeros(1,trials);
    testrejave_mini_lcf_it_noperf = zeros(1,trials);
    testdupave_mini_lcf_it_noperf = zeros(1,trials);

   
    
    
    %%% find soln and do minitest for LCF-fms (iteration 1)
    for t = 1:trials
        
     %%% find uconst and calculate density
     [miles,mins]=loadtripinfo();
    [uconst,rhsconst] = create_uconst(x_slsf(:,(t-1)*n+1:t*n),eqtype,threshold,threshold,threshold,Ojlong(:,t),Djlong(:,t),Oilong(:,t),Dilong(:,t),alphavalslong(:,(t-1)*n+1:t*n),mins,0);
    [DensityNums] = calculate_density(x_slsf(:,(t-1)*n+1:t*n),eqtype,uconst);
    DensityNumsLong(:,(t-1)*NumMetrics+1: t*NumMetrics) = DensityNums;
     
    %%% run lcf iter 1 and save soln info
    tic
    [obj,gap,v,w,y,p,ptrue,u,psi]=LCF_with_equity(Chatlong(:,(t-1)*n+1:t*n),x_slsf(:,(t-1)*n+1:t*n),qlong,variscens_lcf_it_noperf,yhat_lcfinput((t-1)*m+1:t*m,1:n*fixedscens_lcf_it_noperf),ones(1,fixedscens_lcf_it_noperf),farelong(:,(t-1)*n+1:t*n),alphavalslong(:,(t-1)*n+1:t*n),betavalslong(:,(t-1)*n+1:t*n),premium_diff,mincomp,uconst,rhsconst,300,lcfgap,0);

     toc
        
    simobjs_lcf_it_noperf(1,t) = obj;
    v_lcf_it_noperf((t-1)*m+1:t*m,:) = v;
    w_lcf_it_noperf((t-1)*m+1:t*m,:) = w;
    y_lcf_it_noperf((t-1)*m+1:t*m,:) = y;
    p_lcf_it_noperf(:,(t-1)*n+1:t*n) = p;
    ptrue_lcf_it_noperf(:,(t-1)*n+1:t*n) = ptrue;
    u_lcf_it_noperf(:,(t-1)*n+1:t*n) = u;
    psi_lcf_it_noperf((t-1)*m+1:t*m,:) = psi;
    runtimes_lcf_it_noperf(1,t) = toc;
    gaps_lcf_it_noperf(1,t) = gap;
    
    %%% SOL-FR iter 1 minitest (small performance test)  
    %%% generate random test scenarios
    tic
    [testyhat,testscenprobs,testscenbase,testscenexp] = indepy_generate_scens(x_slsf(:,(t-1)*n+1:t*n).*ptrue,minitestsize,0);
    tic
    
    runtimes_mini_lcf_it_noperf(1,t) = toc;
    testyhat_mini_lcf_it_noperf((t-1)*m+1:t*m,:) = testyhat;
    testscenprobs_mini_lcf_it_noperf(t,:) = testscenprobs;
    testscenbase_mini_lcf_it_noperf(t,:) = testscenbase;
    testscenexp_mini_lcf_it_noperf(t,:) = testscenexp;
    
    %run the small performance analysis  (SOL-FR first iteration)
    tic
    [objave,objsd,dupave,dupsd,rejave,rejsd,aveassign,objvals,vfull,zfull,wfull] = sample_cases_performance_indepy(Chatlong(:,(t-1)*n+1:t*n)-u-alphavalslong(:,(t-1)*n+1:t*n),Dlong(:,(t-1)*n+1:t*n),zeros(m,1),qlong,x_slsf(:,(t-1)*n+1:t*n),ptrue,minitestsize,testyhat,testscenprobs);
    toc
    
    runtimes_mini_lcf_it_noperf(1,t) = runtimes_mini_lcf_it_noperf(1,t) + toc;
    testobjave_mini_lcf_it_noperf(1,t) = objave;
    testrejave_mini_lcf_it_noperf(1,t) = rejave;
    testdupave_mini_lcf_it_noperf(1,t) = dupave;
    
    %check if small performance test of SOL-FR iteration 1 yields a better
    %objective estimate than the initial slsf solution
    if objave > bestsoln_mini_obj_lcf_it_noperf(1,t)
        
        %%% update best soln
        guessbestiter_lcf_it_noperf(1,t) = 1;
        times_soln_updated_lcf_it_noperf(1,t) = times_soln_updated_lcf_it_noperf(1,t) + 1;

        bestsoln_mini_obj_lcf_it_noperf(1,t) = objave;
        bestsoln_mini_rej_lcf_it_noperf(1,t) = rejave;
        bestsoln_mini_dup_lcf_it_noperf(1,t) = dupave;

        ubest_lcf_it_noperf(:,(t-1)*n+1:t*n) = u;
        ptruebest_lcf_it_noperf(:,(t-1)*n+1:t*n) = ptrue;
        pbest_lcf_it_noperf(:,(t-1)*n+1:t*n) = p;
        DensityNumsBest(:,(t-1)*NumMetrics+1: t*NumMetrics) = DensityNums;

   
    end
    end 
    
    %initialize the old compensations and update runtime
    comp_old_lcf_it_noperf = slsfcomplong; %save the compensation used in the iteration, as the next compensation update uses this info
    u_old_lcf_it_noperf = u_lcf_it_noperf; %save the u values from the iteration, as the next compensation update uses this info
    runtimes_total_lcf_it_noperf = runtimes_slsf + runtimes_mini_slsf + (fixedscens_lcf_it_noperf/100)*runtimes_scens_lcfinput + runtimes_lcf_it_noperf + runtimes_mini_lcf_it_noperf;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%for iterations 2 and higher:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
   


%initialize sol-fr's lcf-fr soln variables/values
x_lcf_it_noperf = zeros(m,n*trials);

DensityNumsLong = zeros(m,NumMetrics*trials);
runtimes_slsf_lcf_it_noperf = zeros(1,trials);

simobjs_lcf_it_noperf = zeros(1,trials);
v_lcf_it_noperf = zeros(m*trials,n*(fixedscens_lcf_it_noperf+variscens_lcf_it_noperf));
w_lcf_it_noperf = zeros(m*trials,(fixedscens_lcf_it_noperf+variscens_lcf_it_noperf));
y_lcf_it_noperf = zeros(m*trials,n*variscens_lcf_it_noperf);
p_lcf_it_noperf = zeros(m,n*trials);
ptrue_lcf_it_noperf = zeros(m,n*trials);
u_lcf_it_noperf = zeros(m,n*trials);
psi_lcf_it_noperf = zeros(m*trials,n*(fixedscens_lcf_it_noperf+variscens_lcf_it_noperf));
runtimes_lcf_it_noperf = zeros(1,trials);
gaps_lcf_it_noperf = zeros(1,trials);

% minitest soln varis    
runtimes_mini_lcf_it_noperf = zeros(1,trials);
testobjave_mini_lcf_it_noperf = zeros(1,trials);
testrejave_mini_lcf_it_noperf = zeros(1,trials);
testdupave_mini_lcf_it_noperf = zeros(1,trials);

slsfcomplong_new_lcf_it_noperf = zeros(m,n*trials);
yprobslong_new_lcf_it_noperf = zeros(m,n*trials);
Clong_new_lcf_it_noperf = zeros(m,n*trials);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% do the iteration of SOL-FR
for t = 1:trials
    % calculate new fixed compensations
    [C,yprobs,newslsfcomp] = generate_comp_iter(alphavalslong(:,(t-1)*n+1:t*n)+u_old_lcf_it_noperf(:,(t-1)*n+1:t*n),comp_old_lcf_it_noperf(:,(t-1)*n+1:t*n),alphavalslong(:,(t-1)*n+1:t*n),farelong(:,(t-1)*n+1:t*n),OjOiminslong(:,(t-1)*n+1:t*n),extradrivingtimelong(:,(t-1)*n+1:t*n),drandlong(:,(t-1)*n+1:t*n),'c');
    
    Clong_new_lcf_it_noperf(:,(t-1)*n+1:t*n) = C;
    yprobslong_new_lcf_it_noperf(:,(t-1)*n+1:t*n) = yprobs;
    slsfcomp_new_lcf_it_noperf(:,(t-1)*n+1:t*n) = newslsfcomp;

     %generate mutated scenarios for slsf 
    tic
    [yhat,scenprobs,newretention,scenbase,scenexp] = filter_scens(m,n,yprobs,0,0,0,1000000,'t',100);
    toc
    runtimes_slsf_lcf_it_noperf(1,t) = toc;

    % solve and save slsf menu
    tic
    [obj,gap,x,v,z,w] = fixed_y_prob_cplex_dot(C,Dlong(:,(t-1)*n+1:t*n),rlong(:,t),5,qlong,yprobs,yhat,scenprobs,0,0,60,.01,0);
    toc
    
    runtimes_slsf_lcf_it_noperf(1,t) = runtimes_slsf_lcf_it_noperf(1,t) + toc;
    x_lcf_it_noperf(:,(t-1)*n+1:t*n) = x;
    
    
    %generate random lcf-fr scenarios
    
    tic
    [yhat,scenprobs,scenbase,scenexp]=indepy_generate_scens(x.*yprobs,fixedscens_lcf_it_noperf,0);
    toc
    
    runtimes_lcf_it_noperf(1,t)=toc;
    
       %%% find uconst and calculate density
    [uconst,rhsconst] = create_uconst(x,eqtype,threshold,threshold,threshold,Ojlong(:,t),Djlong(:,t),Oilong(:,t),Dilong(:,t),alphavalslong(:,(t-1)*n+1:t*n),mins,0);
    [DensityNums] = calculate_density(x,eqtype,uconst);
    DensityNumsLong(:,(t-1)*NumMetrics+1: t*NumMetrics) = DensityNums;
   
    % run lcf-fms and save variables
    
    tic
    [obj,gap,v,w,y,p,ptrue,u,psi]=LCF_with_equity(Chatlong(:,(t-1)*n+1:t*n),x,qlong,variscens_lcf_it_noperf,yhat,ones(1,fixedscens_lcf_it_noperf),farelong(:,(t-1)*n+1:t*n),alphavalslong(:,(t-1)*n+1:t*n),betavalslong(:,(t-1)*n+1:t*n),premium_diff,mincomp,uconst,rhsconst,300,lcfgap,0);

     toc
   
        
    simobjs_lcf_it_noperf(1,t) = obj;
    v_lcf_it_noperf((t-1)*m+1:t*m,:) = v;
    w_lcf_it_noperf((t-1)*m+1:t*m,:) = w;
    y_lcf_it_noperf((t-1)*m+1:t*m,:) = y;
    p_lcf_it_noperf(:,(t-1)*n+1:t*n) = p;
    ptrue_lcf_it_noperf(:,(t-1)*n+1:t*n) = ptrue;
    u_lcf_it_noperf(:,(t-1)*n+1:t*n) = u;
    psi_lcf_it_noperf((t-1)*m+1:t*m,:) = psi;
    runtimes_lcf_it_noperf(1,t) = runtimes_lcf_it_noperf(1,t) + toc;
    gaps_lcf_it_noperf(1,t) = gap;
    
    
    
    %minitest (small performance test) for this iteration's sol-it soln
    %generate random test scenarios
    tic
    [testyhat,testscenprobs,testscenbase,testscenexp] = indepy_generate_scens(x.*ptrue,minitestsize,0);
    tic
    
    runtimes_mini_lcf_it_noperf(1,t) = toc;
    
    testyhat_mini_lcf_it_noperf((t-1)*m+1:t*m,:) = testyhat;
    testscenprobs_mini_lcf_it_noperf(t,:) = testscenprobs;
    testscenbase_mini_lcf_it_noperf(t,:) = testscenbase;
    testscenexp_mini_lcf_it_noperf(t,:) = testscenexp;

    %small performance analysis
    tic
    [objave,objsd,dupave,dupsd,rejave,rejsd,aveassign,objvals,vfull,zfull,wfull] = sample_cases_performance_indepy(Chatlong(:,(t-1)*n+1:t*n)-u-alphavalslong(:,(t-1)*n+1:t*n),Dlong(:,(t-1)*n+1:t*n),zeros(m,1),qlong,x,ptrue,minitestsize,testyhat,testscenprobs);
    toc
    
    runtimes_mini_lcf_it_noperf(1,t) = runtimes_mini_lcf_it_noperf(1,t) + toc;
    testobjave_mini_lcf_it_noperf(1,t) = objave;
    testrejave_mini_lcf_it_noperf(1,t) = rejave;
    testdupave_mini_lcf_it_noperf(1,t) = dupave;
    
    %check if small performance test of this iteration's SOL-IT yields a better
    %objective estimate than the current recorded best solution
    if objave > bestsoln_mini_obj_lcf_it_noperf(1,t)
        
        %%% update best soln if better
        guessbestiter_lcf_it_noperf(1,t) = iteration;
        times_soln_updated_lcf_it_noperf(1,t) = times_soln_updated_lcf_it_noperf(1,t) + 1;

        bestsoln_mini_obj_lcf_it_noperf(1,t) = objave;
        bestsoln_mini_rej_lcf_it_noperf(1,t) = rejave;
        bestsoln_mini_dup_lcf_it_noperf(1,t) = dupave;
        
        xbest_lcf_it_noperf(:,(t-1)*n+1:t*n) = x;
        ubest_lcf_it_noperf(:,(t-1)*n+1:t*n) = u;
        ptruebest_lcf_it_noperf(:,(t-1)*n+1:t*n) = ptrue;
        pbest_lcf_it_noperf(:,(t-1)*n+1:t*n) = p;
        
        DensityNumsBest(:,(t-1)*NumMetrics+1: t*NumMetrics) = DensityNums;

   
    end
    
    
end

%update the old compensation and u, update runtime
comp_old_lcf_it_noperf = slsfcomp_new_lcf_it_noperf;
u_old_lcf_it_noperf = u_lcf_it_noperf;
runtimes_total_lcf_it_noperf = runtimes_total_lcf_it_noperf + runtimes_slsf_lcf_it_noperf + runtimes_lcf_it_noperf + runtimes_mini_lcf_it_noperf;

end


%%%%%%%%%%%%%%%%% save desired variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stem = sprintf('lcf_eq_noperfI%dP%sFS%dVS%dEq%sT%d%s.mat',iteration,premiumstr_diff,fixedscens_lcf_it_noperf,variscens_lcf_it_noperf,eqtype,threshold,notes_noperf);
    filename = [ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Eq_experiments\noperf\' stem];
 save(filename, 'Chatlong','Clong', 'Dlong', 'rlong','qlong', 'farelong', 'yprobslong','minitestsize',...
    'slsfcomplong', 'alphavalslong', 'betavalslong', 'OjOiminslong', 'extradrivingtimelong', 'drandlong','mincomp','lcfgap',...
    'Oilong','Dilong','Ojlong','Djlong','eqtype','threshold','mins','iteration','trials','testsamps','m','n','theta','slsfperc',...
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
'-v7.3');
