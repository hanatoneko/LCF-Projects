%function[]=phase2(trials,testsamps,notes)
%%% this code is basically the same as lcf_exp_params_and_slsf except it is
%%% used for the SLSF paper's phase 2, it just does 10 problem instances
%%% and doesn't need the lcf scenarios etc:

%%% this code generates driver data and other input data etc for each problem instance, solves SLSF
%%% for that input data and runs performance analysis on the SLSF menu, then
%%% a matlab data file is created saving all matlab variables,
%%% the variables for the SLSF experiment end with _slsf, the input parameters
%%% etc are the parameter name plus 'long',
%%%(most of) the performance analysis variables/values start with 'test' 


trials=10; %number of problem instances
testsamps=5000; %number of test samples used for performance analysis
notes='' %% can include a string to be added to the outputted data file to differentiate a specific run
m=20;
n=20;
theta=5;
slsfperc=0.8; %percent of fare paid under the fixed compensation used for SLSF

%%% point to the folder containing CPLEX so matlab can run the solver 
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio129\CPLEX_Studio\cplex\matlab\x64_win64'));

%%% NOTE on variable array construction:
%%% when the parameter/variable/value is the same for all scenarios (e.g. Chat, x, p), the
%%% arrays for each trial are concatenated horizontally. When there is a
%%% variable set for each scenario, the m x n arrays for the same problem
%%% instances are concatenated horizontally across the scenarios, then the
%%% arrays representing all scenarios for each problem instance are
%%% concatenated vertically. The problem instance parameters are the
%%% parameter name plus 'long'

%variables from generating parameters
Clong=zeros(m,n*trials);
Dlong=zeros(m,n*trials);
rlong=zeros(m,trials);
farelong=zeros(m,n*trials);
yprobslong=zeros(m,n*trials);
slsfcomplong=zeros(m,n*trials);
Oilong=zeros(m,trials);
Dilong=zeros(m,trials);
Ojlong=zeros(n,trials);
Djlong=zeros(n,trials);
OjOiminslong=zeros(m,n*trials);
extradrivingtimelong=zeros(m,n*trials);
drandlong=zeros(m,n*trials); %the random component of D


%save values from slsf scen generation and slsf soln
yhat_slsf=zeros(m*trials,n*100);
scenprobs_slsf=zeros(trials,100);
scenbase_slsf=zeros(trials,100);
scenexp_slsf=zeros(trials,100);
simobjs_slsf=zeros(1,trials);  %objectives returned by SLSF solver
x_slsf=zeros(m,n*trials);
v_slsf=zeros(m*trials,n*100);
z_slsf=zeros(m*trials,n*100);
w_slsf=zeros(m*trials,100);
runtimes_slsf=zeros(1,trials);
gaps_slsf=zeros(1,trials); %optimality gap of the  SLSF solution




%performance analysis values slsf
testyhat_slsf=zeros(m*trials,n*testsamps);
testscenprobs_slsf=zeros(trials,testsamps);
testscenbase_slsf=zeros(trials,testsamps);
testscenexp_slsf=zeros(trials,testsamps);

testobjs_slsf=zeros(trials,testsamps);
testobjave_slsf=zeros(1,trials);
testdupave_slsf=zeros(1,trials);
testrejave_slsf=zeros(1,trials);
testv_slsf=zeros(m*trials,n*testsamps);
testz_slsf=zeros(m*trials,n*testsamps);
testw_slsf=zeros(m*trials,testsamps);
aveassign_slsf=zeros(m,n*trials);
runtimes_perf_slsf=zeros(1,trials);


%quality metrics for slsf
avecomp_slsf=zeros(1,trials); %average compensation paid to matched drivers
aveperccomp_slsf=zeros(1,trials); %average compensation divided by the fare paid to matched drivers
avetotprofit_slsf=zeros(1,trials);  % average profit made
percposprofit_slsf=zeros(1,trials); %portion of test scenarios that have a positive profit
aveextratime_slsf=zeros(1,trials); %average extra driving time for matched drivers
averejfare_slsf=zeros(1,trials);  %average fare of rejected requests



for t=1:trials
    while true % redo param generation and slsf if 60 seconds isn't long enough to get a decent solution
   
     %generate and save input parameters
    [C,D,r,fare,qlong,yprobs,slsfcomp,Oi,Di,Oj,Dj,OjOimins,extradrivingtime,drand]=generate_params_slsf_heur(m,n);
    Clong(:,(t-1)*n+1:t*n)=C;
    Dlong(:,(t-1)*n+1:t*n)=D;
    rlong(:,t)=r;
    farelong(:,(t-1)*n+1:t*n)=fare;
    yprobslong(:,(t-1)*n+1:t*n)=yprobs;
    slsfcomplong(:,(t-1)*n+1:t*n)=slsfcomp;
    Oilong(:,t)=Oi;
    Dilong(:,t)=Di;
    Ojlong(:,t)=Oj;
    Djlong(:,t)=Dj;
    OjOiminslong(:,(t-1)*n+1:t*n)=OjOimins;
    extradrivingtimelong(:,(t-1)*n+1:t*n)=extradrivingtime;
    drandlong(:,t)=drand;
     
    %generate and save slsf scenarios
    tic
    [yhat,scenprobs,newretention,scenbase,scenexp]=filter_scens(m,n,yprobs,0,0,0,1000000,'t',100);
    toc
    yhat_slsf((t-1)*m+1:t*m,:)=yhat;
    scenprobs_slsf(t,:)=scenprobs;
    scenbase_slsf(t,:)=scenbase;
    scenexp_slsf(t,:)=scenexp;
    runtimes_slsf(1,t)=toc;

    %run SLSF and save outputted variables
    tic
    [obj,gap,x,v,z,w]=fixed_y_prob_cplex_dot(C,D,r,5,qlong,yprobs,yhat,scenprobs,0,0,60,.01,0);
    toc
    
    if nnz(x)>3*n %break if the menu has enough entries to seem like a valid solution
        break
    end
    end
    
    simobjs_slsf(1,t)=obj;
    x_slsf(:,(t-1)*n+1:t*n)=x;
    v_slsf((t-1)*m+1:t*m,:)=v;
    z_slsf((t-1)*m+1:t*m,:)=z;
    w_slsf((t-1)*m+1:t*m,:)=w;
    runtimes_slsf(1,t)=runtimes_slsf(1,t) + toc;
    gaps_slsf(1,t)=gap;
    
    
    
    
    %%%%%%%%%% performance analysis of the slsf menu %%%%%%%%
     % generate test scenarios
    tic
    [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*yprobs,testsamps,0);
    toc
    testyhat_slsf((t-1)*m+1:t*m,:)=testyhat;
    testscenprobs_slsf(t,:)=testscenprobs;
    testscenbase_slsf(t,:)=testscenbase;
    testscenexp_slsf(t,:)=testscenexp;
    runtimes_perf_slsf(1,t)=toc;

    %%% do performance analysis on the scenarios
    tic
    [objave,objsd,dupave,dupsd,rejave,rejsd,aveassign,objvals,vfull,zfull,wfull]=sample_cases_performance_indepy(C,D,r,qlong,x,yprobs,5000,testyhat,testscenprobs);
    toc
    
    testobjs_slsf(t,:)=objvals;
    testobjave_slsf(1,t)=objave;
    testdupave_slsf(1,t)=dupave;
    testrejave_slsf(1,t)=rejave;
    testv_slsf((t-1)*m+1:t*m,:)=vfull;
    testz_slsf((t-1)*m+1:t*m,:)=zfull;
    testw_slsf((t-1)*m+1:t*m,:)=wfull;
    aveassign_slsf(:,(t-1)*n+1:t*n)=aveassign;
    runtimes_perf_slsf(1,t)= runtimes_perf_slsf(1,t) + toc;
    
    % slsf quality metrics
    [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare]=quality_metrics(fare,slsfcomp,extradrivingtime,vfull,wfull)
    avecomp_slsf(1,t)=avecomp;
    aveperccomp_slsf(1,t)=aveperccomp;
    avetotprofit_slsf(1,t)=avetotprofit;
    percposprofit_slsf(1,t)=percposprofit;
    aveextratime_slsf(1,t)=aveextratime;
    averejfare_slsf(1,t)=averejfare;
    
   
    
end

%%% output data file
stem= sprintf('slsfpaper_paramandslsf1%s.mat',notes);

filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_2\' stem];
save(filename,'-v7.3');