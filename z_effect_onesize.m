%function[]=z_effect_onesize(notes)

%this code does the unhappy driver (z) effect experiment (phase 4) that is used in
%the SLSF paper. For each problem instance, SLSF and SLSF-noZ are solved, and 
%performance analysis is conducted on each solution using the
%same 5000 test scenarios generated from the untion of the two menus. The values are 
%saved into a matlab data file with the notes string in the name.
 

notes='w100samps2'

m=20;
n=20;
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
Clong=zeros(m,n*trials);
Dlong=zeros(m,n*trials);
rlong=zeros(m,trials);
drandlong=zeros(m,n*trials);
Oilong=zeros(m,trials);
Dilong=zeros(m,trials);
Ojlong=zeros(n,trials);
Djlong=zeros(n,trials);
yprobslong=zeros(m,n*trials);

%slsf/slsf-noz training scenario input info
saayhatlong=zeros(m*trials,n*100);
saascenprobslong=zeros(trials,100);
saascenbaselong=zeros(trials,100);
saascenexplong=zeros(trials,100);

%%%% slsf soln info 
objlong=zeros(1,trials);
xlong=zeros(m,n*trials);
vlong=zeros(m*trials,n*100);
zlong=zeros(m*trials,n*100);
wlong=zeros(m*trials,100);
timeslong=zeros(1,trials);

%%% slsf-noz soln info
objlongnoz=zeros(1,trials);
xlongnoz=zeros(m,n*trials);
vlongnoz=zeros(m*trials,n*100);
wlongnoz=zeros(m*trials,100);
timeslongnoz=zeros(1,trials);

% perf analysis test scenario info
testyhatlong=zeros(m*trials,n*testsamps);
testscenprobslong=zeros(trials,testsamps);
testscenbaselong=zeros(trials,testsamps);
testscenexplong=zeros(trials,testsamps);

%slsf perf info
testobjavelong=zeros(1,trials);
testobjlong=zeros(trials,testsamps);
testvlong=zeros(m*trials,n*testsamps);
testzlong=zeros(m*trials,n*testsamps);
testwlong=zeros(m*trials,testsamps);
aveassignlong=zeros(m,n*trials);

%slsf-noz perf info
testobjavelongnoz=zeros(1,trials);
testobjlongnoz=zeros(trials,testsamps);
testvlongnoz=zeros(m*trials,n*testsamps);
testzlongnoz=zeros(m*trials,n*testsamps);
testwlongnoz=zeros(m*trials,testsamps);
aveassignlongnoz=zeros(m,n*trials);



for t=1:trials
    %generate and save problem instance parameter inputs
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
    
    %generate mutated training scenarios
    [yhat,scenprobs,newretention,scenbase,scenexp]=filter_scens(m,n,yprobs,0,0,0,1000000,'t',100);
    saayhatlong((t-1)*m+1:t*m,:)=yhat;
    saascenprobslong(t,:)=scenprobs;
    saascenbaselong(t,:)=scenbase;
    saascenexplong(t,:)=scenexp;
    
    
    %sove with no z
    tic
    [obj,gap,x1,v,w]=fixed_y_prob_cplex_dot_no_z(C,D,r,theta,q,yprobs,yhat,scenprobs,0,0,500,0.01,0);
    toc
    timeslongnoz(1,t)=toc;
    objlongnoz(1,t)=obj;
    xlongnoz(:,(t-1)*n+1:t*n)=x1;
    vlongnoz((t-1)*m+1:t*m,:)=v;
    wlongnoz((t-1)*m+1:t*m,:)=w;
   

    
    %solve with z
    tic
    [obj,gap,x2,v,z,w]=fixed_y_prob_cplex_dot(C,D,r,theta,q,yprobs,yhat,scenprobs,0,0,500,0.01,0);
    toc
    timeslong(1,t)=toc
    xunion=min(ones(m,n),x1+x2);
   
    objlong(1,t)=obj;
    xlong(:,(t-1)*n+1:t*n)=x2;
    vlong((t-1)*m+1:t*m,:)=v;
    zlong((t-1)*m+1:t*m,:)=z;
    wlong((t-1)*m+1:t*m,:)=w;

    

    
    %%%now for a performance analysis on our two menus
    %%% first calculate the full set of offered items so we can generate
    %%% scenarios

    %generate random test scenarios from the union of the slsf and slsf-noz menus
    [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(xunion.*yprobs,5000,0);
    testyhatlong((t-1)*m+1:t*m,:)=testyhat;
    testscenprobslong(t,:)=testscenprobs;
    testscenbaselong(t,:)=testscenbase;
    testscenexplong(t,:)=testscenexp;
    
    %slsf-noz performance analysis
    if sum(sum(x1))>0
        [objave1,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,q,x1,yprobs,5000,testyhat,testscenprobs);
        %zcount(t,1)=dupave1
        testobjavelongnoz(1,t)=objave1;
        testobjlongnoz(t,:)=objvals1;
        testvlongnoz((t-1)*m+1:t*m,:)=vfull1;
        testzlongnoz((t-1)*m+1:t*m,:)=zfull1;
        testwlongnoz((t-1)*m+1:t*m,:)=wfull1;
        aveassignlongnoz(:,(t-1)*n+1:t*n)=aveassign1;
        
    end
    
    %slsf performance analysis
    if sum(sum(x2))>0
        [objave2,objsd,dupave2,dupsd,rejave,rejsd,aveassign2,objvals2,vfull2,zfull2,wfull2]=sample_cases_performance_indepy(C,D,r,q,x2,yprobs,5000,testyhat,testscenprobs);      
        %zcount(t,2)=dupave2
        testobjavelong(1,t)=objave2;
        testobjlong(t,:)=objvals2;
        testvlong((t-1)*m+1:t*m,:)=vfull2;
        testzlong((t-1)*m+1:t*m,:)=zfull2;
        testwlong((t-1)*m+1:t*m,:)=wfull2;
        aveassignlong(:,(t-1)*n+1:t*n)=aveassign2;
    end

    
end

%create matlab data file
stem= sprintf('phase3zeffect%s.mat',notes);

filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_3\' stem];
save(filename);