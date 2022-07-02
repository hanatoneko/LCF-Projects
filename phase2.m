%function[]=phase2(trials,testsamps,notes)

%this code runs the experiments used for the 'phase 2' analysis, which
%became phase 3 becase we added heuristic comparison as the new phase 2.
%Basicaly this code runs ten problem instances of SLSF with the recomended
%number of training and test scenarios from phases 0 and 1 (100 training
%5000 test). Performance analysis of the solution is completed using 5000
%test scenarios and all variables are saved to a matlab data file in
%Paper_experiments\phase_3\. The file that was used for the paper analysis
%was phase2instw5000testsamps

trials=10; %number of problem instances
testsamps=5000;
notes=''
m=20;
n=20;
theta=5;

%%% NOTE on variable array construction:
%%% when the parameter/variable/value is the same for all scenarios (e.g. Chat, x, p), the
%%% arrays for each trial are concatenated horizontally. When there is a
%%% variable set for each scenario, the m x n arrays for the same problem
%%% instances are concatenated horizontally across the scenarios, then the
%%% arrays representing all scenarios for each problem instance are
%%% concatenated vertically. The problem instance parameters are the
%%% parameter name plus 'long'

%parameters
Clong=zeros(m,n*trials);
Dlong=zeros(m,n*trials);
rlong=zeros(m,trials);
drandlong=zeros(m,n*trials); %the random component of D
Oilong=zeros(m,trials);
Dilong=zeros(m,trials);
Ojlong=zeros(n,trials);
Djlong=zeros(n,trials);
yprobslong=zeros(m,n*trials);

%save values from training scen generation and slsf soln
saayhatlong=zeros(m*trials,n*100);
saascenprobslong=zeros(trials,100);
saascenbaselong=zeros(trials,100);
saascenexplong=zeros(trials,100);
objlong=zeros(1,trials);
xlong=zeros(m,n*trials);
vlong=zeros(m*trials,n*100);
zlong=zeros(m*trials,n*100);
wlong=zeros(m*trials,100);

%save performance analysis info
testyhatlong=zeros(m*trials,n*testsamps);
testscenprobslong=zeros(trials,testsamps);
testscenbaselong=zeros(trials,testsamps);
testscenexplong=zeros(trials,testsamps);
testobjlong=zeros(trials,testsamps);
testvlong=zeros(m*trials,n*testsamps);
testzlong=zeros(m*trials,n*testsamps);
testwlong=zeros(m*trials,testsamps);
aveassignlong=zeros(m,n*trials);



for t=1:trials
    %generate and save problem instance parameters
    [C,D,r,q,yprobs,Oi,Di,Oj,Dj,drand]=generate_params(m,n,1);
    Clong(:,(t-1)*n+1:t*n)=C;
    Dlong(:,(t-1)*n+1:t*n)=D;
    rlong(:,t)=r;
    drandlong(:,t)=drand;
    Oilong(:,t)=Oi;
    Dilong(:,t)=Di;
    Ojlong(:,t)=Oj;
    Djlong(:,t)=Dj;
    yprobslong(:,(t-1)*n+1:t*n)=yprobs; 
    
    %generate and save mutated training scenarios
    [yhat,scenprobs,newretention,scenbase,scenexp]=filter_scens(m,n,yprobs,0,0,0,1000000,'t',100);
    %[yhat,scenprobs,scenbase,scenexp]=indepy_generate_scens(yprobs,100,0);
    saayhatlong((t-1)*m+1:t*m,:)=yhat;
    saascenprobslong(t,:)=scenprobs;
    saascenbaselong(t,:)=scenbase;
    saascenexplong(t,:)=scenexp;
    
    %solve slsf and save info
    [obj,gap,x,v,z,w]=fixed_y_prob_cplex_dot(C,D,r,5,q,yprobs,yhat,scenprobs,0,0,500,0.01,0);
    objlong(1,t)=obj;
    xlong(:,(t-1)*n+1:t*n)=x;
    vlong((t-1)*m+1:t*m,:)=v;
    zlong((t-1)*m+1:t*m,:)=z;
    wlong((t-1)*m+1:t*m,:)=w;
    
    %generate and save test scenarios
    [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*yprobs,testsamps,0);
    testyhatlong((t-1)*m+1:t*m,:)=testyhat;
    testscenprobslong(t,:)=testscenprobs;
    testscenbaselong(t,:)=testscenbase;
    testscenexplong(t,:)=testscenexp;
    
    %do performance analysis and save info
    [objave,objsd,dupave,dupsd,rejave,rejsd,aveassign,objvals,vfull,zfull,wfull]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,5000,testyhat,testscenprobs);
    testobjlong(t,:)=objvals;
    testvlong((t-1)*m+1:t*m,:)=vfull;
    testzlong((t-1)*m+1:t*m,:)=zfull;
    testwlong((t-1)*m+1:t*m,:)=wfull;
    aveassignlong(:,(t-1)*n+1:t*n)=aveassign;
    
    
    
end

%create matlab data file
stem= sprintf('phase2inst%s.mat',notes);

filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_3\' stem];
save(filename);