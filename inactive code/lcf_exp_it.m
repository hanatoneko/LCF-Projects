iteration = 2;
premium = 0.65*ones(20,20);
premiumstr = '65';
variscens_lcf_it = 10;
fixedscens_lcf_it = 10;
minitestsize = 400;
notes = '';
if iteration == 2
    stem = sprintf('lcf_fmsP%sFS%dVS%d%s.mat',premiumstr,fixedscens_lcf_it,variscens_lcf_it,notes);
    filename = [ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Paper_experiments\LCF_fms\' stem];
    load(filename);
    
else
   stem = sprintf('lcf_itI%dP%sFS%dVS%d%s.mat',iteration-1,premiumstr,fixedscens_lcf_it,variscens_lcf_it,notes);
    filename = [ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Paper_experiments\LCF_it\' stem];
    load(filename);
end
notes = ''
iteration = 2;
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio129\cplex\matlab\x64_win64'));

%%% if iteration 2, make variables for best found soln
if iteration == 2
    comp_old_lcf_it = slsfcomplong;
    u_old_lcf_it = u_lcf_fms;
    
    testyhat_mini_slsf = zeros(m*trials,n*minitestsize);
    testscenprobs_mini_slsf = zeros(trials,minitestsize);
    testscenbase_mini_slsf = zeros(trials,minitestsize);
    testscenexp_mini_slsf = zeros(trials,minitestsize);
    
    runtimes_mini_slsf = zeros(1,trials);
    testobjave_mini_slsf = zeros(1,trials);
    testrejave_mini_slsf = zeros(1,trials);
    testdupave_mini_slsf = zeros(1,trials);
    
    bestsoln_mini_obj_lcf_it = zeros(1,trials);
    bestsoln_mini_rej_lcf_it = zeros(1,trials);
    bestsoln_mini_dup_lcf_it = zeros(1,trials);
    guessbestiter_lcf_it = zeros(1,trials);
    times_soln_updated_lcf_it = zeros(1,trials);
    
    %%% slsf minitest
    for t = 1:trials
    tic
    [testyhat,testscenprobs,testscenbase,testscenexp] = indepy_generate_scens(x_slsf(:,(t-1)*n+1:t*n).*yprobslong(:,(t-1)*n+1:t*n),minitestsize,0);
    toc
    
    runtimes_mini_slsf(1,t) = toc;
    testyhat_mini_slsf((t-1)*m+1:t*m,:) = testyhat;
    testscenprobs_mini_slsf(t,:) = testscenprobs;
    testscenbase_mini_slsf(t,:) = testscenbase;
    testscenexp_mini_slsf(t,:) = testscenexp;

    tic
    [objave,objsd,dupave,dupsd,rejave,rejsd,aveassign,objvals,vfull,zfull,wfull] = sample_cases_performance_indepy(Clong(:,(t-1)*n+1:t*n),Dlong(:,(t-1)*n+1:t*n),rlong(:,t),qlong,x_slsf(:,(t-1)*n+1:t*n),yprobslong(:,(t-1)*n+1:t*n),minitestsize,testyhat,testscenprobs);
    toc
    
    runtimes_mini_slsf(1,t) = runtimes_mini_slsf(1,t) + toc;
    testobjave_mini_slsf(1,t) = objave;
    testrejave_mini_slsf(1,t) = rejave;
    testdupave_mini_slsf(1,t) = dupave;
    
    bestsoln_mini_obj_lcf_it(1,t) = objave;
    bestsoln_mini_rej_lcf_it(1,t) = rejave;
    bestsoln_mini_dup_lcf_it(1,t) = dupave;
    
    end
   
    
    
    %soln info on best found, initialized as slsf soln info
    xbest_lcf_it = x_slsf;
    ubest_lcf_it = zeros(m,n*trials);
    ptruebest_lcf_it = zeros(m,n*trials);
    pbest_lcf_it = zeros(m,n*trials);
    
    testyhat_best_lcf_it = testyhat_slsf;
    testscenprobs_best_lcf_it = testscenprobs_slsf;
    testscenbase_best_lcf_it = testscenbase_slsf;
    testscenexp_best_lcf_it= testscenexp_slsf;
    
    testobjs_best_lcf_it = testobjs_slsf;
    testobjave_best_lcf_it = testobjave_slsf;
    testdupave_best_lcf_it = testdupave_slsf;
    testrejave_best_lcf_it = testrejave_slsf;
    testv_best_lcf_best_it = testv_slsf;
    testz_best_lcf_it = testz_slsf;
    testw_best_lcf_it = testw_slsf;
    aveassign_best_lcf_it = aveassign_slsf;

    avecomp_best_lcf_it = avecomp_slsf;
    aveperccomp_best_lcf_it = aveperccomp_slsf;
    avetotprofit_best_lcf_it = avetotprofit_slsf;
    percposprofit_best_lcf_it = percposprofit_slsf;
    aveextratime_best_lcf_it = aveextratime_slsf;
    
    %%% miniteset for lcf iter 1 soln variables
    testyhat_mini_lcf_fms = zeros(m*trials,n*minitestsize);
    testscenprobs_mini_lcf_fms = zeros(trials,minitestsize);
    testscenbase_mini_lcf_fms = zeros(trials,minitestsize);
    testscenexp_mini_lcf_fms = zeros(trials,minitestsize);
    
    runtimes_mini_lcf_fms(1,t) = zeros(1,trials);
    testobjave_mini_lcf_fms(1,t) = zeros(1,trials);
    testrejave_mini_lcf_fms(1,t) = zeros(1,trials);
    testdupave_mini_lcf_fms(1,t) = zeros(1,trials);
    
    
    %%% minitest for LCF-fms (iteration 1)
    for t = 1:trials
    tic
    [testyhat,testscenprobs,testscenbase,testscenexp] = indepy_generate_scens(x_slsf(:,(t-1)*n+1:t*n).*ptrue_lcf_fms(:,(t-1)*n+1:t*n),minitestsize,0);
    tic
    
    runtimes_mini_lcf_fms(1,t) = toc;
    testyhat_mini_lcf_fms((t-1)*m+1:t*m,:) = testyhat;
    testscenprobs_mini_lcf_fms(t,:) = testscenprobs;
    testscenbase_mini_lcf_fms(t,:) = testscenbase;
    testscenexp_mini_lcf_fms(t,:) = testscenexp;

    tic
    [objave,objsd,dupave,dupsd,rejave,rejsd,aveassign,objvals,vfull,zfull,wfull] = sample_cases_performance_indepy(Chatlong(:,(t-1)*n+1:t*n)-u_lcf_fms(:,(t-1)*n+1:t*n)-alphavalslong(:,(t-1)*n+1:t*n),Dlong(:,(t-1)*n+1:t*n),zeros(m,1),qlong,x_slsf(:,(t-1)*n+1:t*n),ptrue_lcf_fms(:,(t-1)*n+1:t*n),minitestsize,testyhat,testscenprobs);
    toc
    
    runtimes_mini_lcf_fms(1,t) = runtimes_mini_lcf_fms(1,t) + toc;
    testobjave_mini_lcf_fms(1,t) = objave;
    testrejave_mini_lcf_fms(1,t) = rejave;
    testdupave_mini_lcf_fms(1,t) = dupave;
    
    if objave > bestsoln_mini_obj_lcf_it(1,t)
        
        %%% update best soln
        guessbestiter_lcf_it(1,t) = 1;
        times_soln_updated_lcf_it(1,t) = times_soln_updated_lcf_it(1,t) + 1;

        bestsoln_mini_obj_lcf_it(1,t) = objave;
        bestsoln_mini_rej_lcf_it(1,t) = rejave;
        bestsoln_mini_dup_lcf_it(1,t) = dupave;

        ubest_lcf_it(:,(t-1)*n+1:t*n) = u_lcf_fms(:,(t-1)*n+1:t*n);
        ptruebest_lcf_it(:,(t-1)*n+1:t*n) = ptrue_lcf_fms(:,(t-1)*n+1:t*n);
        pbest_lcf_it(:,(t-1)*n+1:t*n) = p_lcf_fms(:,(t-1)*n+1:t*n);
        
        testyhat_best_lcf_it((t-1)*m+1:t*m,:) = testyhat_lcf_fms((t-1)*m+1:t*m,:);
        testscenprobs_best_lcf_it(t,:) = testscenprobs_lcf_fms(t,:);
        testscenbase_best_lcf_it(t,:) = testscenbase_lcf_fms(t,:);
        testscenexp_best_lcf_it(t,:) = testscenexp_lcf_fms(t,:);

        testobjs_best_lcf_it(t,:) = testobjs_lcf_fms(t,:);
        testobjave_best_lcf_it(1,t) = testobjave_lcf_fms(1,t);
        testdupave_best_lcf_it(1,t) = testdupave_lcf_fms(1,t);
        testrejave_best_lcf_it(1,t) = testrejave_lcf_fms(1,t);
        testv_best_lcf_best_it((t-1)*m+1:t*m,:) = testv_lcf_fms((t-1)*m+1:t*m,:);
        testz_best_lcf_it((t-1)*m+1:t*m,:) = testz_lcf_fms((t-1)*m+1:t*m,:);
        testw_best_lcf_it((t-1)*m+1:t*m,:) = testw_lcf_fms((t-1)*m+1:t*m,:);
        aveassign_best_lcf_it(:,(t-1)*n+1:t*n) = aveassign_lcf_fms(:,(t-1)*n+1:t*n);

        avecomp_best_lcf_it(1,t) = avecomp_lcf_fms(1,t);
        aveperccomp_best_lcf_it(1,t) = aveperccomp_lcf_fms(1,t);
        avetotprofit_best_lcf_it(1,t) = avetotprofit_lcf_fms(1,t);
        percposprofit_best_lcf_it(1,t) = percposprofit_lcf_fms(1,t);
        aveextratime_best_lcf_it(1,t) = aveextratime_lcf_fms(1,t);
   
    end
    end 
  
    runtimes_total_lcf_it =  runtimes_slsf + runtimes_mini_slsf + runtimes_scens_lcfinput + runtimes_lcf_fms + runtimes_mini_lcf_fms;
end
   
runtimes_mini_lcf_it(1,t) = zeros(1,trials);
testobjave_mini_lcf_it(1,t) = zeros(1,trials);
testrejave_mini_lcf_it(1,t) = zeros(1,trials);
testdupave_mini_lcf_it(1,t) = zeros(1,trials);

slsfcomplong_new_lcf_it = zeros(m,n*trials);
yprobslong_new_lcf_it = zeros(m,n*trials);
Clong_new_lcf_it = zeros(m,n*trials);

%save values lcf-it soln
yhat_slsf_lcf_it = zeros(m*trials,n*100);
scenprobs_slsf_lcf_it = zeros(trials,100);
scenbase_slsf_lcf_it = zeros(trials,100);
scenexp_slsf_lcf_it = zeros(trials,100);
x_lcf_it = zeros(m,n*trials);
runtimes_slsf_lcf_it = zeros(1,trials);

yhat_fixed_lcf_it = zeros(m*trials,n*100);
scenprobs_fixed_lcf_it = zeros(trials,100);
scenbase_fixed_lcf_it = zeros(trials,100);
scenexp_fixed_lcf_it = zeros(trials,100);

simobjs_lcf_it = zeros(1,trials);
v_lcf_it = zeros(m*trials,n*(fixedscens_lcf_it+variscens_lcf_it));
w_lcf_it = zeros(m*trials,(fixedscens_lcf_it+variscens_lcf_it));
y_lcf_it = zeros(m*trials,n*variscens_lcf_it);
p_lcf_it = zeros(m,n*trials);
ptrue_lcf_it = zeros(m,n*trials);
u_lcf_it = zeros(m,n*trials);
psi_lcf_it = zeros(m*trials,n*(fixedscens_lcf_it+variscens_lcf_it));
runtimes_lcf_it = zeros(1,trials);
gaps_lcf_it = zeros(1,trials);

%performance analysis values
nontrivialvals_lcf_it = zeros(1,trials);
testyhat_lcf_it = zeros(m*trials,n*testsamps);
testscenprobs_lcf_it = zeros(trials,testsamps);
testscenbase_lcf_it = zeros(trials,testsamps);
testscenexp_lcf_it = zeros(trials,testsamps);

testobjs_lcf_it = zeros(trials,testsamps);
testobjave_lcf_it = zeros(1,trials);
testdupave_lcf_it = zeros(1,trials);
testrejave_lcf_it = zeros(1,trials);
testv_lcf_it = zeros(m*trials,n*testsamps);
testz_lcf_it = zeros(m*trials,n*testsamps);
testw_lcf_it = zeros(m*trials,testsamps);
aveassign_lcf_it = zeros(m,n*trials);
runtimes_perf_lcf_it = zeros(1,trials);

%quality metrics for lcf
avecomp_lcf_it = zeros(1,trials);
aveperccomp_lcf_it = zeros(1,trials);
avetotprofit_lcf_it = zeros(1,trials);
percposprofit_lcf_it = zeros(1,trials);
aveextratime_lcf_it = zeros(1,trials);
averejfare_lcf_it = zeros(1,trials);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for t = 1:trials
    % calculate new comp sceme
    [C,yprobs,newslsfcomp] = generate_comp_iter(alphavalslong(:,(t-1)*n+1:t*n)+u_old_lcf_it(:,(t-1)*n+1:t*n),comp_old_lcf_it(:,(t-1)*n+1:t*n),alphavalslong(:,(t-1)*n+1:t*n),farelong(:,(t-1)*n+1:t*n),OjOiminslong(:,(t-1)*n+1:t*n),extradrivingtimelong(:,(t-1)*n+1:t*n),drandlong(:,(t-1)*n+1:t*n),'c');
    
    Clong_new_lcf_it(:,(t-1)*n+1:t*n) = C;
    yprobslong_new_lcf_it(:,(t-1)*n+1:t*n) = yprobs;
    slsfcomp_new_lcf_it(:,(t-1)*n+1:t*n) = newslsfcomp;
    
     %generate and save slsf scenarios
    tic
    [yhat,scenprobs,newretention,scenbase,scenexp] = filter_scens(m,n,yprobs,0,0,0,1000000,'t',100);
    toc
    yhat_slsf_lcf_it((t-1)*m+1:t*m,:) = yhat;
    scenprobs_slsf_lcf_it(t,:) = scenprobs;
    scenbase_slsf_lcf_it(t,:) = scenbase;
    scenexp_slsf_lcf_it(t,:) = scenexp;
    runtimes_slsf_lcf_it(1,t) = toc;

    % solve and save slsf menu
    tic
    [obj,gap,x,v,z,w] = fixed_y_prob_cplex_dot(C,Dlong(:,(t-1)*n+1:t*n),rlong(:,t),5,qlong,yprobs,yhat,scenprobs,0,0,60,.01,0);
    toc
    
    runtimes_slsf_lcf_it(1,t) = runtimes_slsf_lcf_it(1,t) + toc;
    x_lcf_it(:,(t-1)*n+1:t*n) = x;
    
    
    %generate lcf-it scenarios
    
    tic
    [yhat,scenprobs,scenbase,scenexp]=indepy_generate_scens(x.*yprobs,fixedscens_lcf_it,0);
    toc
    yhat_fixed_lcf_it((t-1)*m+1:t*m,:)=yhat;
    scenprobs_fixed_lcf_it(t,:)=scenprobs;
    scenbase_fixed_lcf_it(t,:)=scenbase;
    scenexp_fixed_lcf_it(t,:)=scenexp;
    runtimes_lcf_it(1,t)=toc;
    
   
   % run lcf
    tic
     [obj,gap,v,w,y,p,ptrue,u,psi] = comp_model_w_scens_fixed_menu(Chatlong(:,(t-1)*n+1:t*n),x,qlong,variscens_lcf_it,yhat,ones(1,fixedscens_lcf_it),farelong(:,(t-1)*n+1:t*n),alphavalslong(:,(t-1)*n+1:t*n),betavalslong(:,(t-1)*n+1:t*n),premium,mincomp,300,lcfgap,0);
    toc
        
    simobjs_lcf_it(1,t) = obj;
    v_lcf_it((t-1)*m+1:t*m,:) = v;
    w_lcf_it((t-1)*m+1:t*m,:) = w;
    y_lcf_it((t-1)*m+1:t*m,:) = y;
    p_lcf_it(:,(t-1)*n+1:t*n) = p;
    ptrue_lcf_it(:,(t-1)*n+1:t*n) = ptrue;
    u_lcf_it(:,(t-1)*n+1:t*n) = u;
    psi_lcf_it((t-1)*m+1:t*m,:) = psi;
    runtimes_lcf_it(1,t) = runtimes_lcf_it(1,t) + toc;
    gaps_lcf_it(1,t) = gap;
    
    
    % lcf performance analysis
    nontrivialvals_lcf_it(1,t) = nnz(ptrue.*x)-size(find(ptrue.*x >= 1),1);
    scens2use = min(2^nontrivialvals_lcf_it(1,t),testsamps);
    tic
    [testyhat,testscenprobs,testscenbase,testscenexp] = indepy_generate_scens(x.*ptrue,scens2use,0);
    toc
    testyhat_lcf_it((t-1)*m+1:t*m,1:scens2use*n) = testyhat;
    testscenprobs_lcf_it(t,1:scens2use) = testscenprobs;
    testscenbase_lcf_it(t,1:scens2use) = testscenbase;
    testscenexp_lcf_it(t,1:scens2use) = testscenexp;
    runtimes_perf_lcf_it(1,t) = toc;

    tic
    [objave,objsd,dupave,dupsd,rejave,rejsd,aveassign,objvals,vfull,zfull,wfull] = sample_cases_performance_indepy(Chatlong(:,(t-1)*n+1:t*n)-u-alphavalslong(:,(t-1)*n+1:t*n),Dlong(:,(t-1)*n+1:t*n),zeros(m,1),qlong,x,ptrue,scens2use,testyhat,testscenprobs);
    toc
    
    testobjs_lcf_it(t,1:scens2use) = objvals;
    testobjave_lcf_it(1,t) = objave;
    testdupave_lcf_it(1,t) = dupave;
    testrejave_lcf_it(1,t) = rejave;
    testv_lcf_it((t-1)*m+1:t*m,1:scens2use*n) = vfull;
    testz_lcf_it((t-1)*m+1:t*m,1:scens2use*n) = zfull;
    testw_lcf_it((t-1)*m+1:t*m,1:scens2use) = wfull;
    aveassign_lcf_it(:,(t-1)*n+1:t*n) = aveassign;
    runtimes_perf_lcf_it(1,t) = runtimes_perf_lcf_it(1,t) + toc;
    
     % lcf quality metrics
    [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare] = quality_metrics(farelong(:,(t-1)*n+1:t*n),alphavalslong(:,(t-1)*n+1:t*n)+u,extradrivingtimelong(:,(t-1)*n+1:t*n),vfull,wfull)
    avecomp_lcf_it(1,t) = avecomp;
    aveperccomp_lcf_it(1,t) = aveperccomp;
    avetotprofit_lcf_it(1,t) = avetotprofit;
    percposprofit_lcf_it(1,t) = percposprofit;
    aveextratime_lcf_it(1,t) = aveextratime;
    averejfare_lcf_it(1,t) = averejfare;
    
    %minitest for lcf soln
    tic
    [testyhat,testscenprobs,testscenbase,testscenexp] = indepy_generate_scens(x.*ptrue,minitestsize,0);
    tic
    
    runtimes_mini_lcf_it(1,t) = toc;
    testyhat_mini_lcf_it((t-1)*m+1:t*m,:) = testyhat;
    testscenprobs_mini_lcf_it(t,:) = testscenprobs;
    testscenbase_mini_lcf_it(t,:) = testscenbase;
    testscenexp_mini_lcf_it(t,:) = testscenexp;

    tic
    [objave,objsd,dupave,dupsd,rejave,rejsd,aveassign,objvals,vfull,zfull,wfull] = sample_cases_performance_indepy(Chatlong(:,(t-1)*n+1:t*n)-u-alphavalslong(:,(t-1)*n+1:t*n),Dlong(:,(t-1)*n+1:t*n),zeros(m,1),qlong,x,ptrue,minitestsize,testyhat,testscenprobs);
    toc
    
    runtimes_mini_lcf_it(1,t) = runtimes_mini_lcf_it(1,t) + toc;
    testobjave_mini_lcf_it(1,t) = objave;
    testrejave_mini_lcf_it(1,t) = rejave;
    testdupave_mini_lcf_it(1,t) = dupave;
    
    if objave > bestsoln_mini_obj_lcf_it(1,t)
        
        %%% update best soln if better
        guessbestiter_lcf_it(1,t) = iteration;
        times_soln_updated_lcf_it(1,t) = times_soln_updated_lcf_it(1,t) + 1;

        bestsoln_mini_obj_lcf_it(1,t) = objave;
        bestsoln_mini_rej_lcf_it(1,t) = rejave;
        bestsoln_mini_dup_lcf_it(1,t) = dupave;
        
        
        xbest_lcf_it(:,(t-1)*n+1:t*n) = x;
        ubest_lcf_it(:,(t-1)*n+1:t*n) = u;
        ptruebest_lcf_it(:,(t-1)*n+1:t*n) = ptrue;
        pbest_lcf_it(:,(t-1)*n+1:t*n) = p;
        
        testyhat_best_lcf_it((t-1)*m+1:t*m,:) = testyhat_lcf_it((t-1)*m+1:t*m,:);
        testscenprobs_best_lcf_it(t,:) = testscenprobs_lcf_it(t,:);
        testscenbase_best_lcf_it(t,:) = testscenbase_lcf_it(t,:);
        testscenexp_best_lcf_it(t,:) = testscenexp_lcf_it(t,:);

        testobjs_best_lcf_it(t,:) = testobjs_lcf_it(t,:);
        testobjave_best_lcf_it(1,t) = testobjave_lcf_it(1,t);
        testdupave_best_lcf_it(1,t) = testdupave_lcf_it(1,t);
        testrejave_best_lcf_it(1,t) = testrejave_lcf_it(1,t);
        testv_best_lcf_best_it((t-1)*m+1:t*m,:) = testv_lcf_it((t-1)*m+1:t*m,:);
        testz_best_lcf_it((t-1)*m+1:t*m,:) = testz_lcf_it((t-1)*m+1:t*m,:);
        testw_best_lcf_it((t-1)*m+1:t*m,:) = testw_lcf_it((t-1)*m+1:t*m,:);
        aveassign_best_lcf_it(:,(t-1)*n+1:t*n) = aveassign_lcf_it(:,(t-1)*n+1:t*n);

        avecomp_best_lcf_it(1,t) = avecomp_lcf_it(1,t);
        aveperccomp_best_lcf_it(1,t) = aveperccomp_lcf_it(1,t);
        avetotprofit_best_lcf_it(1,t) = avetotprofit_lcf_it(1,t);
        percposprofit_best_lcf_it(1,t) = percposprofit_lcf_it(1,t);
        aveextratime_best_lcf_it(1,t) = aveextratime_lcf_it(1,t);
   
    end
    
    
end

comp_old_lcf_it = slsfcomp_new_lcf_it;
u_old_lcf_it = u_lcf_it;
runtimes_total_lcf_it = runtimes_total_lcf_it + runtimes_slsf_lcf_it + runtimes_lcf_it + runtimes_mini_lcf_it;
    
stem = sprintf('lcf_itI%dP%sFS%dVS%d%s.mat',iteration,premiumstr,fixedscens_lcf_it,variscens_lcf_it,notes);
  
filename = [ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Paper_experiments\LCF_it\' stem];
save(filename,'-v7.3');