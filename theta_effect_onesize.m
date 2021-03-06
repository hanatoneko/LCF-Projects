 function[]=theta_effect_onesize(notes)
 
 %this code does the theta (menu size) effect experiment (phase 4) that is used in
 %the SLSF paper. For each problem instance, SLSF is solved for each menu
 %size and performance analysis is conducted on each solution using the
 %same 5000 test scenarios (same for all menus in the same problem
 %instance). The values are saved into a matlab data file.
 

notes='noloop'

m=20;
n=20;
thetasizes=[1;3;5;10;20]; %menu sizes to be tested
numthetas=5; %number of menu sizes to test
trials=10;
testsamps=5000;

%%% NOTE on variable array construction:
%%% when the parameter/variable/value is the same for all scenarios (e.g. Chat, x, p), the
%%% arrays for each trial are concatenated horizontally. When there is a
%%% variable set for each scenario, the m x n arrays for the same problem
%%% instances are concatenated horizontally across the scenarios, then the
%%% arrays representing all scenarios for each problem instance are
%%% concatenated vertically. The problem instance parameters are the
%%% parameter name plus 'long'


%%% parameter values
Clong=zeros(m,n*trials);
Dlong=zeros(m,n*trials);
rlong=zeros(m,trials);
drandlong=zeros(m,n*trials); %random component of D
Oilong=zeros(m,trials);
Dilong=zeros(m,trials);
Ojlong=zeros(n,trials);
Djlong=zeros(n,trials);
yprobslong=zeros(m,n*trials);

%mutated training scenario info
saayhatlong=zeros(m*trials,n*100);
saascenprobslong=zeros(trials,100);
saascenbaselong=zeros(trials,100);
saascenexplong=zeros(trials,100);

%%%% solution variables
objlong=zeros(numthetas,trials); %objective of the training scenarios
xlong=zeros(m*numthetas,n*trials);
vlong=zeros(m*trials*numthetas,n*100);
zlong=zeros(m*trials*numthetas,n*100);
wlong=zeros(m*trials*numthetas,100);
timeslong=zeros(numthetas,trials);

%perf analysis info
testyhatlong=zeros(m*trials,n*testsamps);
testscenprobslong=zeros(trials,testsamps);
testscenbaselong=zeros(trials,testsamps);
testscenexplong=zeros(trials,testsamps);


testobjavelong=zeros(numthetas,trials);
testobjlong=zeros(trials*numthetas,testsamps);
testvlong=zeros(m*trials*numthetas,n*testsamps);
testzlong=zeros(m*trials*numthetas,n*testsamps);
testwlong=zeros(m*trials*numthetas,testsamps);
aveassignlong=zeros(m*numthetas,n*trials);


for t=1:trials
    %generate and save problem instance data
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
    %xunion stores all menus from a given problem instance, since we want the same
    %scens across theta sizes and we want to compare menu differences
    %between menus with different sample sizes
    xunion=zeros(m,n);
         
   [yhat,scenprobs,newretention,scenbase,scenexp]=filter_scens(m,n,yprobs,0,0,0,1000000,'t',100);
    saayhatlong((t-1)*m+1:t*m,:)=yhat;
    saascenprobslong(t,:)=scenprobs;
    saascenbaselong(t,:)=scenbase;
    saascenexplong(t,:)=scenexp;  
       
    for s=1:numthetas
        theta=thetasizes(s,1);
       %solve with the current theta
        tic
       [obj,gap,x,v,z,w]=fixed_y_prob_cplex_dot(C,D,r,theta,q,yprobs,yhat,scenprobs,0,0,500,0.01,0);
        toc
        
        xunion=min(ones(m,n),x+xunion);
        timeslong(s,t)=toc;
        objlong(1,t)=obj;
        xlong((s-1)*m+1:s*m,(t-1)*n+1:t*n)=x;
        vlong((s-1)*m*trials+(t-1)*m+1:(s-1)*m*trials+t*m,:)=v;
        vlong((s-1)*m*trials+(t-1)*m+1:(s-1)*m*trials+t*m,:)=z;
        wlong((s-1)*m*trials+(t-1)*m+1:(s-1)*m*trials+t*m,:)=w;
 
    end
    
    
    %%%now for a performance analysis on all menus for current instance
    [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(xunion.*yprobs,5000,0);
    testyhatlong((t-1)*m+1:t*m,:)=testyhat;
    testscenprobslong(t,:)=testscenprobs;
    testscenbaselong(t,:)=testscenbase;
    testscenexplong(t,:)=testscenexp;

    
      %performance analysis for each theta's solution
        for s=1:numthetas
            [objave1,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,q,xlong((s-1)*m+1:s*m,(t-1)*n+1:t*n),yprobs,5000,testyhat,testscenprobs);
            testobjavelong(s,t)=objave1;
            testobjlong((s-1)*trials+t,:)=objvals1;
            testvlong((s-1)*m*trials+(t-1)*m+1:(s-1)*m*trials+t*m,:)=vfull1;
            testzlong((s-1)*m*trials+(t-1)*m+1:(s-1)*m*trials+t*m,:)=zfull1;
            testwlong((s-1)*m*trials+(t-1)*m+1:(s-1)*m*trials+t*m,:)=wfull1;
            aveassignlong((s-1)*m+1:s*m,(t-1)*n+1:t*n)=aveassign1;

        end
end

%create data file
stem= sprintf('phase3thetaeffect%s.mat',notes);

filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_3\' stem];
save(filename);

