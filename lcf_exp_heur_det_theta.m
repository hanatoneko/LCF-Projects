%%% this code solves DET-theta, where theta is the menu size
%%% for that input data and runs performance analysis on the menu, then
%%% a matlab data file is created saving all matlab variables,
%%% the variables for the SLSF experiment end with _det,
%%%(most of) the performance analysis variables/values start with 'test' 

%%% load the problem instance input parameter info
load('C:\Users\horneh\Documents\LCF_Paper_experiments\parameter_values\paramandslsf.mat');


%point to the folder containing CPLEX
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio129\CPLEX_Studio\cplex\matlab\x64_win64'));
trials = 100; %number of problem instances
notes = ''; %any notes you want to add to the outputted file title
dettheta=5;

%save values from slsf scen generation and slsf soln
yhat_det=zeros(m*trials,n);
x_det=zeros(m,n*trials);
v_det=zeros(m*trials,n);
z_det=zeros(m*trials,n);
w_det=zeros(m*trials,1);
runtimes_det=zeros(1,trials);
gaps_det=zeros(1,trials); %optimality gap of the DET solution




%performance analysis values slsf
detnontrivials = zeros(1,trials);
 scens2use_det = zeros(1,trials);
testyhat_det=zeros(m*trials,n*testsamps);
testscenprobs_det=zeros(trials,testsamps);
testscenbase_det=zeros(trials,testsamps);
testscenexp_det=zeros(trials,testsamps);

testobjs_det=zeros(trials,testsamps);
testobjave_det=zeros(1,trials);
testdupave_det=zeros(1,trials);
testrejave_det=zeros(1,trials);
testv_det=zeros(m*trials,n*testsamps);
testz_det=zeros(m*trials,n*testsamps);
testw_det=zeros(m*trials,testsamps);
aveassign_det=zeros(m,n*trials);
runtimes_perf_det=zeros(1,trials);


%quality metrics for slsf
avecomp_det=zeros(1,trials); %average compensation paid to matched drivers
aveperccomp_det=zeros(1,trials); %average compensation divided by the fare paid to matched drivers
avetotprofit_det=zeros(1,trials); % average profit made
percposprofit_det=zeros(1,trials); %portion of test scenarios that have a positive profit
aveextratime_det=zeros(1,trials); %average extra driving time for matched drivers
averejfare_det=zeros(1,trials); %average fare of rejected requests


for t=1:trials
  
    %calculate most likely scenario
   yhat = round(yprobslong(:,(t-1)*n+1:t*n));
    yhat_det((t-1)*m+1:t*m,:) = yhat;
    
    while true
    %run DET and save outputted variables
    tic
    [obj,gap,x,v,z,w]=fixed_y_prob_cplex_dot(Clong(:,(t-1)*n+1:t*n),Dlong(:,(t-1)*n+1:t*n),rlong(:,t),dettheta,qlong,yprobslong(:,(t-1)*n+1:t*n),yhat,1,1,0,60,.01,0);
    toc
    
    if nnz(x) == dettheta*n %break if the menu has enough entries to seem like a valid solution
        break
    end
    end
    
    
    x_det(:,(t-1)*n+1:t*n)=x;
    v_det((t-1)*m+1:t*m,:)=v;
    z_det((t-1)*m+1:t*m,:)=z;
    w_det((t-1)*m+1:t*m,:)=w;
    runtimes_det(1,t)=runtimes_det(1,t) + toc;
    gaps_det(1,t)=gap;
    
    
    
    
     %%%%%%%%%% performance analysis of the slsf menu %%%%%%%%
     % generate test scenarios
     detnontrivials(1,t)=nnz(yprobslong(:,(t-1)*n+1:t*n).*x)-size(find(yprobslong(:,(t-1)*n+1:t*n).*x>=1),1);
     scens2use_det(1,t) = min(5000,2^detnontrivials(1,t));
     tic
    [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*yprobslong(:,(t-1)*n+1:t*n),scens2use_det(1,t),0);
    toc
    testyhat_det((t-1)*m+1:t*m,1:scens2use_det(1,t)*n)=testyhat;
    testscenprobs_det(t,1:scens2use_det(1,t))=testscenprobs;
    testscenbase_det(t,1:scens2use_det(1,t))=testscenbase;
    testscenexp_det(t,1:scens2use_det(1,t))=testscenexp;
    runtimes_perf_det(1,t)=toc;
    
    %%% do performance analysis on the scenarios
    tic
    [objave,objsd,dupave,dupsd,rejave,rejsd,aveassign,objvals,vfull,zfull,wfull]=sample_cases_performance_indepy(Clong(:,(t-1)*n+1:t*n),Dlong(:,(t-1)*n+1:t*n),rlong(:,t),qlong,x,yprobslong(:,(t-1)*n+1:t*n),scens2use_det(1,t),testyhat,testscenprobs);
    toc
    
    testobjs_det(t,1:scens2use_det(1,t))=objvals';
    testobjave_det(1,t)=objave;
    testdupave_det(1,t)=dupave;
    testrejave_det(1,t)=rejave;
    testv_det((t-1)*m+1:t*m,1:scens2use_det(1,t)*n)=vfull;
    testz_det((t-1)*m+1:t*m,1:scens2use_det(1,t)*n)=zfull;
    testw_det((t-1)*m+1:t*m,1:scens2use_det(1,t))=wfull;
    aveassign_det(:,(t-1)*n+1:t*n)=aveassign;
    runtimes_perf_det(1,t)= runtimes_perf_det(1,t) + toc;
    
    % DET quality metrics
    [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare]=quality_metrics(farelong(:,(t-1)*n+1:t*n),slsfcomplong(:,(t-1)*n+1:t*n),extradrivingtimelong(:,(t-1)*n+1:t*n),vfull,wfull)
    avecomp_det(1,t)=avecomp;
    aveperccomp_det(1,t)=aveperccomp;
    avetotprofit_det(1,t)=avetotprofit;
    percposprofit_det(1,t)=percposprofit;
    aveextratime_det(1,t)=aveextratime;
    averejfare_det(1,t)=averejfare;
    
   
    
end

%%% output data file
stem= sprintf('lcf_exp_heur_det%d.mat',dettheta);

filename =[ 'G:\My Drive\RPI\Research\code\LCF_Paper_experiments\' stem];
save(filename,'-v7.3');