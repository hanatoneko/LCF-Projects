% function[]=theta_effect_onesize(notes)

%this code does the wages experiment used in Phase 4 of the SLSF paper, that
%is, for each problem instance, for each specified wage level SLSF is
%solved and performance analysis is conducted. Then a matlab data file
%containing all variables is created. The input parameters
%%% etc are the parameter name plus 'long',
%%%(most of) the performance analysis variables/values start with 'test' 

notes='fixedparams'
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio129\cplex\matlab\x64_win64'));
m=20;
n=20;
wagelevels=[0.4;0.5;0.6;0.7;0.8;0.9]; %the wage levels to test, e.g. 0.4 means the driver receives 40% of the fare
numwages=6; %number of wage levels tested
theta=5;
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
Clong=zeros(m*numwages,n*trials);
Dlong=zeros(m,n*trials);
rlong=zeros(m,trials);
drandlong=zeros(m,n*trials);
Oilong=zeros(m,trials);
Dilong=zeros(m,trials);
Ojlong=zeros(n,trials);
Djlong=zeros(n,trials);

%slsf training scenario input info
yprobslong=zeros(m*numwages,n*trials);
saayhatlong=zeros(m*numwages*trials,n*100);
saascenprobslong=zeros(trials*numwages,100);
saascenbaselong=zeros(trials*numwages,100);
saascenexplong=zeros(trials*numwages,100);

%%%% after solving
objlong=zeros(numwages,trials); %objective returned by the SLSF solver for the training scenarios
xlong=zeros(m*numwages,n*trials);
vlong=zeros(m*trials*numwages,n*100);
zlong=zeros(m*trials*numwages,n*100);
wlong=zeros(m*trials*numwages,100);
timeslong=zeros(numwages,trials);

%perf analysis
testyhatlong=zeros(m*numwages*trials,n*testsamps);
testscenprobslong=zeros(trials*numwages,testsamps);
testscenbaselong=zeros(trials*numwages,testsamps);
testscenexplong=zeros(trials*numwages,testsamps);

testobjavelong=zeros(numwages,trials);
testobjlong=zeros(trials*numwages,testsamps);
testvlong=zeros(m*trials*numwages,n*testsamps);
testzlong=zeros(m*trials*numwages,n*testsamps);
testwlong=zeros(m*trials*numwages,testsamps);
aveassignlong=zeros(m*numwages,n*trials);


for t=1:trials
    %generate and save input parameters
    [C,D,r,q,yprobs,Oi,Di,Oj,Dj,drand]=generate_params(m,n,1);

    Dlong(:,(t-1)*n+1:t*n)=D;
    rlong(:,t)=r;
    drandlong(:,t)=drand;
    Oilong(:,t)=Oi;
    Dilong(:,t)=Di;
    Ojlong(:,t)=Oj;
    Djlong(:,t)=Dj;
    
    %for each wage level
    for w=1:numwages
        %get the new C and yprobs, as these are affected by the wage
        [C,yprobs]=generate_params_adj_wage(m,n,wagelevels(w,1),D,r,q,Oi,Di,Oj,Dj,drand); 
        Clong((w-1)*m+1:w*m,(t-1)*n+1:t*n)=C;
        yprobslong((w-1)*m+1:w*m,(t-1)*n+1:t*n)=yprobs;  

    %generate training scenarios
       [yhat,scenprobs,newretention,scenbase,scenexp]=filter_scens(m,n,yprobs,0,0,0,1000000,'t',100);
        saayhatlong((w-1)*trials*m+(t-1)*m+1:(w-1)*trials*m+t*m,:)=yhat;
        saascenprobslong((w-1)*trials+t,:)=scenprobs;
        saascenbaselong((w-1)*trials+t,:)=scenbase;
        saascenexplong((w-1)*trials+t,:)=scenexp;  

   
       %solve with the current wage's yprobs and C
        tic
       [obj,gap,x,v,z,rej]=fixed_y_prob_cplex_dot(C,D,r,theta,q,yprobs,yhat,scenprobs,0,0,500,0.01,0);
        toc
        
        timeslong(w,t)=toc;
        objlong(1,t)=obj;
        xlong((w-1)*m+1:w*m,(t-1)*n+1:t*n)=x;
        vlong((w-1)*m*trials+(t-1)*m+1:(w-1)*m*trials+t*m,:)=v;
        vlong((w-1)*m*trials+(t-1)*m+1:(w-1)*m*trials+t*m,:)=z;
        wlong((w-1)*m*trials+(t-1)*m+1:(w-1)*m*trials+t*m,:)=rej;
 

        %%%now performance analysis using wage-based test yhat
        [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*yprobs,5000,0);
        testyhatlong((w-1)*trials*m+(t-1)*m+1:(w-1)*trials*m+t*m,:)=testyhat;
        testscenprobslong((w-1)*trials+t,:)=testscenprobs;
        testscenbaselong((w-1)*trials+t,:)=testscenbase;
        testscenexplong((w-1)*trials+t,:)=testscenexp;


        [objave1,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,q,xlong((w-1)*m+1:w*m,(t-1)*n+1:t*n),yprobs,5000,testyhat,testscenprobs);
        testobjavelong(w,t)=objave1;
        testobjlong((w-1)*trials+t,:)=objvals1;
        testvlong((w-1)*m*trials+(t-1)*m+1:(w-1)*m*trials+t*m,:)=vfull1;
        testzlong((w-1)*m*trials+(t-1)*m+1:(w-1)*m*trials+t*m,:)=zfull1;
        testwlong((w-1)*m*trials+(t-1)*m+1:(w-1)*m*trials+t*m,:)=wfull1;
        aveassignlong((w-1)*m+1:w*m,(t-1)*n+1:t*n)=aveassign1;


    end
end

%create matlab data file
stem= sprintf('phase3wageeffect%s.mat',notes);

filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_3\' stem];
save(filename);

    
