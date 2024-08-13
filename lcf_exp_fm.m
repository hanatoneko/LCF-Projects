%%% this code completes the experiment for the LCF-FM (SOL-FM),
%%% using the input data from the parameters and initial slsf experiment. For each problem instance/trial,
%%% LCF-FM is run and performance analysis is conducted, then
%%% a matlab data file is created saving all matlab variables, the file
%%% title includes the premium and number of variable scenarios used and any other notes in the notes string,
%%% the variables for this experiment end with _lcf_fm, (most of) the performance analysis variables/values start with 'test' 


%%% load the stored variables from the file with input parameters etc
load('C:\Users\horneh\Documents\LCF_Paper_experiments\parameter_values\paramandslsf.mat');
trials=100; %number of problem instances
testsamps=5000;%number of test samples used for performance analysis
notes='' %% can include a string to be added to the outputted data file to differentiate a specific run

m=20;
n=20;
theta=5;
mincomp=0.8; %the minimum portion of the far the compensations must pay to the driver (also must be at least $4)
premium=ones(m,n);
premiumstr='10' %the string to record the premium in the output file, is '75' for .75, '85' for .85, etc, and '10' for 1.0
lcfgap=.05; %optimality gap (terminates solver upon reaching it)
variscens_lcf_fm=10; %number of variable scenarios
%%% point to the folder containing CPLEX so matlab can run the solver
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio129\CPLEX_Studio\cplex\matlab\x64_win64'));

%%% when the variable/value is the same for all scenarios (e.g. x, p), the
%%% arrays for each trial are concatenated horizontally. When there is a
%%% variable set for each scenario, the m x n arrays for the same problem
%%% instances are concatenated horizontally across the scenarios, then the
%%% arrays representing all scenarios for each problem instance are concatenated vertically

%save values lcf-fm soln
simobjs_lcf_fm=zeros(1,trials);  %objectives returned by LCF-FM solver
v_lcf_fm=zeros(m*trials,n*variscens_lcf_fm);
w_lcf_fm=zeros(m*trials,variscens_lcf_fm);
y_lcf_fm=zeros(m*trials,n*variscens_lcf_fm);
p_lcf_fm=zeros(m,n*trials);%is p double dot
ptrue_lcf_fm=zeros(m,n*trials); % is pij, i.e. p double dot rounded down to not exceed 1
u_lcf_fm=zeros(m,n*trials);
psi_lcf_fm=zeros(m*trials,n*variscens_lcf_fm);
runtimes_lcf_fm=zeros(1,trials);
gaps_lcf_fm=zeros(1,trials); %optimality gap of the solutions

%performance analysis values
nontrivialvals_lcf_fm=zeros(1,trials); %number of menu entries with nontrivial pij
testyhat_lcf_fm=zeros(m*trials,n*testsamps);
testscenprobs_lcf_fm=zeros(trials,testsamps);
testscenbase_lcf_fm=zeros(trials,testsamps);
testscenexp_lcf_fm=zeros(trials,testsamps);

testobjs_lcf_fm=zeros(trials,testsamps);
testobjave_lcf_fm=zeros(1,trials);
testdupave_lcf_fm=zeros(1,trials); %average number of requests accepted by unhappy driver 
testrejave_lcf_fm=zeros(1,trials); %average number of unmatched requests
testv_lcf_fm=zeros(m*trials,n*testsamps);
testz_lcf_fm=zeros(m*trials,n*testsamps);
testw_lcf_fm=zeros(m*trials,testsamps);
aveassign_lcf_fm=zeros(m,n*trials); %for a problem instance, it's an m x n array where entry ij is the portion of 
% test scenarios in which request i is assigned to driver j
runtimes_perf_lcf_fm=zeros(1,trials); %performance analysis runtime

%quality metrics for lcf
avecomp_lcf_fm=zeros(1,trials); %average compensation paid to matched drivers
aveperccomp_lcf_fm=zeros(1,trials); %average compensation divided by the fare paid to matched drivers
avetotprofit_lcf_fm=zeros(1,trials); % average profit made across the test scenarios
percposprofit_lcf_fm=zeros(1,trials); %portion of test scenarios that have a positive profit
aveextratime_lcf_fm=zeros(1,trials); %average extra driving time for matched drivers
averejfare_lcf_fm=zeros(1,trials); %average fare of rejected requests


for t=1:trials
    %run LCF-FM and save outputted variables
    tic
    [obj,gap,v,w,y,p,ptrue,u,psi]=comp_model_fixed_menu(Chatlong(:,(t-1)*n+1:t*n),x_slsf(:,(t-1)*n+1:t*n),qlong,variscens_lcf_fm,farelong(:,(t-1)*n+1:t*n),alphavalslong(:,(t-1)*n+1:t*n),betavalslong(:,(t-1)*n+1:t*n),premium,mincomp,300,lcfgap,0);
    disp('done with solver')
    toc
        
    simobjs_lcf_fm(1,t)=obj;
    v_lcf_fm((t-1)*m+1:t*m,:)=v;
    w_lcf_fm((t-1)*m+1:t*m,:)=w;
    y_lcf_fm((t-1)*m+1:t*m,:)=y;
    p_lcf_fm(:,(t-1)*n+1:t*n)=p;
    ptrue_lcf_fm(:,(t-1)*n+1:t*n)=ptrue;
    u_lcf_fm(:,(t-1)*n+1:t*n)=u;
    psi_lcf_fm((t-1)*m+1:t*m,:)=psi;
    runtimes_lcf_fm(1,t)=toc;
    gaps_lcf_fm(1,t)=gap;
    
    
    %%%%%%%%%% performance analysis of the menu and compensation %%%%%%%%
  
    nontrivialvals_lcf_fm(1,t)=nnz(ptrue.*x_slsf(:,(t-1)*n+1:t*n))-size(find(ptrue.*x_slsf(:,(t-1)*n+1:t*n)>=1),1);
    scens2use=min(2^nontrivialvals_lcf_fm(1,t),testsamps); %%% temporary variable, if there are fewer 
    %%% distinct scenarios than testsamps, test all scenarios
    
    % generate test scenarios
    tic
    [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x_slsf(:,(t-1)*n+1:t*n).*ptrue,scens2use,0);
    toc
    testyhat_lcf_fm((t-1)*m+1:t*m,1:scens2use*n)=testyhat;
    testscenprobs_lcf_fm(t,1:scens2use)=testscenprobs;
    testscenbase_lcf_fm(t,1:scens2use)=testscenbase;
    testscenexp_lcf_fm(t,1:scens2use)=testscenexp;
    runtimes_perf_lcf_fm(1,t)=toc;
    
    %%% do performance analysis on the scenarios
    tic
    [objave,objsd,dupave,dupsd,rejave,rejsd,aveassign,objvals,vfull,zfull,wfull]=sample_cases_performance_indepy(Chatlong(:,(t-1)*n+1:t*n)-u-alphavalslong(:,(t-1)*n+1:t*n),Dlong(:,(t-1)*n+1:t*n),zeros(m,1),qlong,x_slsf(:,(t-1)*n+1:t*n),ptrue,scens2use,testyhat,testscenprobs);
    toc
    
    testobjs_lcf_fm(t,1:scens2use)=objvals;
    testobjave_lcf_fm(1,t)=objave;
    testdupave_lcf_fm(1,t)=dupave;
    testrejave_lcf_fm(1,t)=rejave;
    testv_lcf_fm((t-1)*m+1:t*m,1:scens2use*n)=vfull;
    testz_lcf_fm((t-1)*m+1:t*m,1:scens2use*n)=zfull;
    testw_lcf_fm((t-1)*m+1:t*m,1:scens2use)=wfull;
    aveassign_lcf_fm(:,(t-1)*n+1:t*n)=aveassign;
    runtimes_perf_lcf_fm(1,t)=runtimes_perf_lcf_fm(1,t) + toc;
    
     % soln quality metrics
    [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare]=quality_metrics(farelong(:,(t-1)*n+1:t*n),alphavalslong(:,(t-1)*n+1:t*n)+u,extradrivingtimelong(:,(t-1)*n+1:t*n),vfull,wfull)
    avecomp_lcf_fm(1,t)=avecomp;
    aveperccomp_lcf_fm(1,t)=aveperccomp;
    avetotprofit_lcf_fm(1,t)=avetotprofit;
    percposprofit_lcf_fm(1,t)=percposprofit;
    aveextratime_lcf_fm(1,t)=aveextratime;
    averejfare_lcf_fm(1,t)=averejfare;
   
end

%%% output data file
stem= sprintf('lcf_fmP%sS%d%s.mat',premiumstr,variscens_lcf_fm,notes);

filename =[ 'C:\Users\horneh\Documents\LCF_Paper_experiments\LCF_fm\' stem];
save(filename,'-v7.3');