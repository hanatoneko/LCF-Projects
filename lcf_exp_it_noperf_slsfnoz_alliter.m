function[] = lcf_exp_it_noperf_slsfnoz_alliter(newiter,premium_diff,premiumstr_diff,variscens_lcf_it_noperf,fixedscens_lcf_it_noperf,notes_noperf)
%%% this code completes one iteration of the experiment for SOL-IT,
%%% using the input data from the parameters and initial slsf experiment (and info from previous iterations). For each problem instance/trial,
%%% LCF-FMS (i.e. LCF-IT) is run and the small performance analysis is conducted, then
%%% a matlab data file is created saving all matlab variables, the file
%%% title includes the iteration, premium, number of variable and fixed
%%% scenarios used, and any other notes in the notes string,
%%% the normal performance analysis is not run each iteration, instead
%%% lcf_exp_it_bestperf does the performance analysis of the final returned
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
%%% respectively, notes_noperf is a string that can be added (or left as
%%% '') to distinguish one run of the code from another that has the same
%%% inputs otherwise 

%%% point to the folder containing CPLEX so matlab can run the solver
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio129\CPLEX_Studio\cplex\matlab\x64_win64'));

iteration = newiter;

%%% load the previous iteration's data (includes initial problem data), or
%%% load initial problem data if it's the first iteration
if iteration == 1
%     if length(notes_noperf) == 3
%   load('C:\Users\horneh\Documents\LCF_Paper_experiments\parameter_values\paramandslsf_with200.mat');
%     starttrial = 101;
%     else
    load('C:\Users\horneh\Documents\LCF_Paper_experiments\parameter_values\paramandslsf.mat');
%     starttrial = 1;
%     end
else
   stem = sprintf('lcf_it_noperf_slsfnoz_alliterI%dP%sFS%dVS%d%s.mat',iteration-1,premiumstr_diff,fixedscens_lcf_it_noperf,variscens_lcf_it_noperf,notes_noperf);
    filename = [ 'C:\Users\horneh\Documents\LCF_Paper_experiments\LCF_it_noperf_diffprem\' stem];
    load(filename);
    
    iteration = iteration + 1
end

%%% point to the folder containing CPLEX so matlab can run the solver
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio129\CPLEX_Studio\cplex\matlab\x64_win64'));


mincomp=0.8; %the minimum portion of the far the compensations must pay to the driver (also must be at least $4)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%for iteration 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% if iteration 1, make blank variable arrays for best found soln
if iteration == 1
    
    x_slsfnoz = zeros(m,n*trials);
    runtimes_slsfnoz_lcf_it_noperf = zeros(1,trials);
    runtimes_slsfnoz_total_lcf_it_noperf = zeros(1,trials);
    
    %%% small performance analysis of the slsfnoz menus from the parameter
    %%% input file, using the _slsfnoz suffix for the arrays
    testyhat_mini_slsfnoz = zeros(m*trials,n*minitestsize);
    testscenprobs_mini_slsfnoz = zeros(trials,minitestsize);
    testscenbase_mini_slsfnoz = zeros(trials,minitestsize);
    testscenexp_mini_slsfnoz = zeros(trials,minitestsize);
    
    runtimes_mini_slsfnoz = zeros(1,trials);
    testobjave_mini_slsfnoz = zeros(1,trials);
    testrejave_mini_slsfnoz = zeros(1,trials); %average number of unmatched requests in the small performance tests
    testdupave_mini_slsfnoz = zeros(1,trials); %average number of requests accepted by unhappy driver  in the small performance tests
    
    bestsoln_mini_obj_lcf_it_noperf = zeros(1,trials);
    bestsoln_mini_rej_lcf_it_noperf = zeros(1,trials); %average number of unmatched requests in the small performance tests for the current best-found soln
    bestsoln_mini_dup_lcf_it_noperf = zeros(1,trials); %average number of requests accepted by unhappy driver  in the small performance tests for the current best-found soln
    guessbestiter_lcf_it_noperf = zeros(1,trials); %the iteration of the current best-found solution (is initialized as 0 to represent the initial slsfnoz soln)
    times_soln_updated_lcf_it_noperf = zeros(1,trials); %keeps track of the number of times a better solution was found than the current best
    
    
    for t = 1:trials
    
    % solve and save slsfnoz menu
    tic
    [obj,gap,x,v,w] = fixed_y_prob_cplex_dot_no_z(Clong(:,(t-1)*n+1:t*n),Dlong(:,(t-1)*n+1:t*n),rlong(:,t),5,qlong,yprobslong(:,(t-1)*n+1:t*n),yhat_slsf((t-1)*m+1:t*m,:),scenprobs_slsf(t,:),0,0,60,.01,0);                                              
    toc
    
    runtimes_slsfnoz_lcf_it_noperf(1,t) = toc;
    runtimes_slsfnoz_total_lcf_it_noperf(1,t) = runtimes_slsfnoz_total_lcf_it_noperf(1,t) + toc;
    x_slsfnoz(:,(t-1)*n+1:t*n) = x;   
        
        
        
    %%% slsfnoz minitest (small performance analysis test)
    %%% generate random test scenarios
     tic
    [testyhat,testscenprobs,testscenbase,testscenexp] = indepy_generate_scens(x_slsfnoz(:,(t-1)*n+1:t*n).*yprobslong(:,(t-1)*n+1:t*n),minitestsize,0);
    toc
    
    runtimes_mini_slsfnoz(1,t) = toc;
    testyhat_mini_slsfnoz((t-1)*m+1:t*m,:) = testyhat;
    testscenprobs_mini_slsfnoz(t,:) = testscenprobs;
    testscenbase_mini_slsfnoz(t,:) = testscenbase;
    testscenexp_mini_slsfnoz(t,:) = testscenexp;
    
    %%% perform the slsfnoz small performance analysis and save values
    tic
    [objave,objsd,dupave,dupsd,rejave,rejsd,aveassign,objvals,vfull,zfull,wfull] = sample_cases_performance_indepy(Clong(:,(t-1)*n+1:t*n),Dlong(:,(t-1)*n+1:t*n),rlong(:,t),qlong,x_slsfnoz(:,(t-1)*n+1:t*n),yprobslong(:,(t-1)*n+1:t*n),minitestsize,testyhat,testscenprobs);
    toc
    
    runtimes_mini_slsfnoz(1,t) = runtimes_mini_slsfnoz(1,t) + toc;
    testobjave_mini_slsfnoz(1,t) = objave;
    testrejave_mini_slsfnoz(1,t) = rejave;
    testdupave_mini_slsfnoz(1,t) = dupave;
    
    bestsoln_mini_obj_lcf_it_noperf(1,t) = objave;
    bestsoln_mini_rej_lcf_it_noperf(1,t) = rejave;
    bestsoln_mini_dup_lcf_it_noperf(1,t) = dupave;
    
    end
   
    
    
    %soln info on best found, initialized as slsfnoz soln info
    xbest_lcf_it_noperf = x_slsfnoz;
    ubest_lcf_it_noperf = zeros(m,n*trials);
    ptruebest_lcf_it_noperf = zeros(m,n*trials); % is pij, i.e. p double dot rounded down to not exceed 1
    pbest_lcf_it_noperf = zeros(m,n*trials); %is p double dot 
   
    %%%%%% initialize the LCF solution variables/values  
    x_lcf_it_noperf = x_slsfnoz;

    simobjs_lcf_it_noperf = zeros(1,trials);
    v_lcf_it_noperf = zeros(m*trials,n*(fixedscens_lcf_it_noperf+variscens_lcf_it_noperf));
    w_lcf_it_noperf = zeros(m*trials,(fixedscens_lcf_it_noperf+variscens_lcf_it_noperf));
    y_lcf_it_noperf = zeros(m*trials,n*variscens_lcf_it_noperf);
    p_lcf_it_noperf = zeros(m,n*trials); %is p double dot
    ptrue_lcf_it_noperf = zeros(m,n*trials); % is pij, i.e. p double dot rounded down to not exceed 1
    u_lcf_it_noperf = zeros(m,n*trials);
    psi_lcf_it_noperf = zeros(m*trials,n*(fixedscens_lcf_it_noperf+variscens_lcf_it_noperf));
    gaps_lcf_it_noperf = zeros(1,trials); %optimality gap of the solutions
    runtimes_full_total_lcf_it_noperf = zeros(1,trials); %runtime of all components of SOL-IT through current iteration, including iteration 1 slsfnoz soln time etc
    runtimes_lcf_it_noperf = zeros(1,trials); %lcf runtime of current iteration
    runtimes_lcf_total_lcf_it_noperf = zeros(1,trials); %total runtime of lcf-fms across all iterations
    
    %%% miniteset for lcf iter 1 soln variables
     testyhat_mini_lcf_it_noperf = zeros(m*trials,n*minitestsize);
    testscenprobs_mini_lcf_it_noperf = zeros(trials,minitestsize);
    testscenbase_mini_lcf_it_noperf = zeros(trials,minitestsize);
    testscenexp_mini_lcf_it_noperf = zeros(trials,minitestsize);
    
    runtimes_mini_lcf_it_noperf = zeros(1,trials); %runtime of minitest for that iteration
    runtimes_mini_total_lcf_it_noperf = zeros(1,trials);%total runtime of minitest across iterations
    testobjave_mini_lcf_it_noperf = zeros(1,trials);
    testrejave_mini_lcf_it_noperf = zeros(1,trials);
    testdupave_mini_lcf_it_noperf = zeros(1,trials);

   
    
    
    %%% find soln and do minitest for LCF-fms (iteration 1)
    for t = 1:trials
        
    %%% run LCF-FMS iter 1 and save soln info
    tic
     [obj,gap,v,w,y,p,ptrue,u,psi] = comp_model_w_scens_fixed_menu(Chatlong(:,(t-1)*n+1:t*n),x_slsfnoz(:,(t-1)*n+1:t*n),qlong,variscens_lcf_it_noperf,yhat_lcfinput((t-1)*m+1:t*m,1:n*fixedscens_lcf_it_noperf),ones(1,fixedscens_lcf_it_noperf),farelong(:,(t-1)*n+1:t*n),alphavalslong(:,(t-1)*n+1:t*n),betavalslong(:,(t-1)*n+1:t*n),premium_diff,mincomp,300,lcfgap,0);
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
    runtimes_lcf_total_lcf_it_noperf(1,t) = runtimes_lcf_total_lcf_it_noperf(1,t) + toc;
    gaps_lcf_it_noperf(1,t) = gap;
    
    %%% SOL-IT iter 1 minitest (small performance test)  
    %%% generate random test scenarios
    tic
    [testyhat,testscenprobs,testscenbase,testscenexp] = indepy_generate_scens(x_slsfnoz(:,(t-1)*n+1:t*n).*ptrue,minitestsize,0);
    tic
    
    runtimes_mini_lcf_it_noperf(1,t) = toc;
    runtimes_mini_total_lcf_it_noperf(1,t) = runtimes_mini_total_lcf_it_noperf(1,t) + toc;
    testyhat_mini_lcf_it_noperf((t-1)*m+1:t*m,:) = testyhat;
    testscenprobs_mini_lcf_it_noperf(t,:) = testscenprobs;
    testscenbase_mini_lcf_it_noperf(t,:) = testscenbase;
    testscenexp_mini_lcf_it_noperf(t,:) = testscenexp;

    %run the small performance analysis  (SOL-IT first iteration)
    tic
    [objave,objsd,dupave,dupsd,rejave,rejsd,aveassign,objvals,vfull,zfull,wfull] = sample_cases_performance_indepy(Chatlong(:,(t-1)*n+1:t*n)-u-alphavalslong(:,(t-1)*n+1:t*n),Dlong(:,(t-1)*n+1:t*n),zeros(m,1),qlong,x_slsfnoz(:,(t-1)*n+1:t*n),ptrue,minitestsize,testyhat,testscenprobs);
    toc
    
    runtimes_mini_lcf_it_noperf(1,t) = runtimes_mini_lcf_it_noperf(1,t) + toc;
    runtimes_mini_total_lcf_it_noperf(1,t) = runtimes_mini_total_lcf_it_noperf(1,t) + toc;
    testobjave_mini_lcf_it_noperf(1,t) = objave;
    testrejave_mini_lcf_it_noperf(1,t) = rejave;
    testdupave_mini_lcf_it_noperf(1,t) = dupave;
    
    %check if small performance test of SOL-IT iteration 1 yields a better
    %objective estimate than the initial slsfnoz solution
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

   
    end
    end 
    
    %initialize the old compensations and update runtime
    comp_old_lcf_it_noperf = slsfcomplong; %save the compensation used in the iteration, as the next compensation update uses this info
    u_old_lcf_it_noperf = u_lcf_it_noperf; %save the u values from the iteration, as the next compensation update uses this info
    runtimes_full_total_lcf_it_noperf =  runtimes_slsfnoz_lcf_it_noperf + runtimes_mini_slsfnoz + (fixedscens_lcf_it_noperf/100)*runtimes_scens_lcfinput + runtimes_lcf_it_noperf + runtimes_mini_lcf_it_noperf;

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%for iterations 2 and higher:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

else
   


%initialize sol-it's lcf-fms soln variables/values
x_lcf_it_noperf = zeros(m,n*trials);
runtimes_slsfnoz_lcf_it_noperf = zeros(1,trials); %slsfnoz runtime of current iter

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

slsfcomplong_new_lcf_it_noperf = zeros(m,n*trials); %save the base fixed compensation used for slsf-noz
yprobslong_new_lcf_it_noperf = zeros(m,n*trials); %save the yprobs (pij) resulting from the fixed compensation
Clong_new_lcf_it_noperf = zeros(m,n*trials); %save the C variable (not including match bonus) resulting from the fixed compensation


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% do the iteration of SOL-IT
for t = 1:trials
    % calculate new fixed compensations
    [C,yprobs,newslsfcomp] = generate_comp_iter(alphavalslong(:,(t-1)*n+1:t*n)+u_old_lcf_it_noperf(:,(t-1)*n+1:t*n),comp_old_lcf_it_noperf(:,(t-1)*n+1:t*n),alphavalslong(:,(t-1)*n+1:t*n),farelong(:,(t-1)*n+1:t*n),OjOiminslong(:,(t-1)*n+1:t*n),extradrivingtimelong(:,(t-1)*n+1:t*n),drandlong(:,(t-1)*n+1:t*n),'c');
    
    Clong_new_lcf_it_noperf(:,(t-1)*n+1:t*n) = C;
    yprobslong_new_lcf_it_noperf(:,(t-1)*n+1:t*n) = yprobs;
    slsfcomp_new_lcf_it_noperf(:,(t-1)*n+1:t*n) = newslsfcomp;
    
     %generate mutated scenarios for slsfnoz 
    tic
    [yhat,scenprobs,newretention,scenbase,scenexp] = filter_scens(m,n,yprobs,0,0,0,1000000,'t',100);
    toc
    runtimes_slsfnoz_lcf_it_noperf(1,t) = toc;
    runtimes_slsfnoz_total_lcf_it_noperf(1,t) = runtimes_slsfnoz_total_lcf_it_noperf(1,t) + toc;

    
    % solve and save slsfnoz menu
    tic
    [obj,gap,x,v,w] = fixed_y_prob_cplex_dot_no_z(C,Dlong(:,(t-1)*n+1:t*n),rlong(:,t),5,qlong,yprobs,yhat,scenprobs,0,0,60,.01,0);                                              
    toc
    
    runtimes_slsfnoz_lcf_it_noperf(1,t) = runtimes_slsfnoz_lcf_it_noperf(1,t) + toc;
    runtimes_slsfnoz_total_lcf_it_noperf(1,t) = runtimes_slsfnoz_total_lcf_it_noperf(1,t) + toc;
    x_lcf_it_noperf(:,(t-1)*n+1:t*n) = x;
    
    
    %generate lcf-fms random scenarios
    
    tic
    [yhat,scenprobs,scenbase,scenexp]=indepy_generate_scens(x.*yprobs,fixedscens_lcf_it_noperf,0);
    toc
    
    runtimes_lcf_it_noperf(1,t)=toc;
    runtimes_lcf_total_lcf_it_noperf(1,t)= runtimes_lcf_total_lcf_it_noperf(1,t) + toc;
    
   
   % run lcf-fms and save variables
    tic
     [obj,gap,v,w,y,p,ptrue,u,psi] = comp_model_w_scens_fixed_menu(Chatlong(:,(t-1)*n+1:t*n),x,qlong,variscens_lcf_it_noperf,yhat,ones(1,fixedscens_lcf_it_noperf),farelong(:,(t-1)*n+1:t*n),alphavalslong(:,(t-1)*n+1:t*n),betavalslong(:,(t-1)*n+1:t*n),premium_diff,mincomp,300,lcfgap,0);
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
    runtimes_lcf_total_lcf_it_noperf(1,t)= runtimes_lcf_total_lcf_it_noperf(1,t) + toc;
    gaps_lcf_it_noperf(1,t) = gap;
    
    
    
    %minitest (small performance test) for this iteration's sol-it soln
    %generate random test scenarios
    tic
    [testyhat,testscenprobs,testscenbase,testscenexp] = indepy_generate_scens(x.*ptrue,minitestsize,0);
    tic
    
    runtimes_mini_lcf_it_noperf(1,t) = toc;
    runtimes_mini_total_lcf_it_noperf(1,t) = runtimes_mini_total_lcf_it_noperf(1,t) + toc;
    testyhat_mini_lcf_it_noperf((t-1)*m+1:t*m,:) = testyhat;
    testscenprobs_mini_lcf_it_noperf(t,:) = testscenprobs;
    testscenbase_mini_lcf_it_noperf(t,:) = testscenbase;
    testscenexp_mini_lcf_it_noperf(t,:) = testscenexp;

    %small performance analysis
    tic
    [objave,objsd,dupave,dupsd,rejave,rejsd,aveassign,objvals,vfull,zfull,wfull] = sample_cases_performance_indepy(Chatlong(:,(t-1)*n+1:t*n)-u-alphavalslong(:,(t-1)*n+1:t*n),Dlong(:,(t-1)*n+1:t*n),zeros(m,1),qlong,x,ptrue,minitestsize,testyhat,testscenprobs);
    toc
    
    runtimes_mini_lcf_it_noperf(1,t) = runtimes_mini_lcf_it_noperf(1,t) + toc;
    runtimes_mini_total_lcf_it_noperf(1,t) = runtimes_mini_total_lcf_it_noperf(1,t) + toc;
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

   
    end
    
    
end

%update the old compensation and u, update runtime
comp_old_lcf_it_noperf = slsfcomp_new_lcf_it_noperf;
u_old_lcf_it_noperf = u_lcf_it_noperf;
runtimes_full_total_lcf_it_noperf = runtimes_full_total_lcf_it_noperf + runtimes_slsfnoz_lcf_it_noperf + runtimes_lcf_it_noperf + runtimes_mini_lcf_it_noperf;

end

%%% save all active variables from this iteration into matlab data file 
stem = sprintf('lcf_it_noperf_slsfnoz_alliterI%dP%sFS%dVS%d%s.mat',iteration,premiumstr_diff,fixedscens_lcf_it_noperf,variscens_lcf_it_noperf,notes_noperf);
  
filename = [ 'C:\Users\horneh\Documents\LCF_Paper_Experiments\LCF_IT_noperf_diffprem\' stem];
save(filename,'-v7.3');
