%%% this code runs and the experiments of alternative methods (CLOS-5,
%%% CLOS-1, DET-5, DET-1, and DET-5le, where DET-5le wasn't used in the paper but it's 
%%% DET-5 except instead of requiring the menu size to be theta, we require it's just less 
%%% than or equal to theta. I think the DET-5le menus ended up being the same as DET-1 or something),
%%% i.e. for each problem instance solve each of the
%%% alternative methods and conduct performance analysis, then
%%% a matlab data file is created saving all matlab variables, the file
%%% title is 'lcf_exp_heur1' plus any other notes in the notes string,
%%% the variables for each experiment end with the experiment name (e.g. _clos1) , and 
%%%(most of) the performance analysis variables/values start with 'test' 


%%% load the problem instance input parameter info
load('C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_2\slsfpaper_paramandslsf1.mat');

%point to the folder containing CPLEX
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio129\CPLEX_Studio\cplex\matlab\x64_win64'));

trials = 10;
notes = '';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% construct variables/values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% when the variable/value is the same for all scenarios (e.g. x, p), the
%%% arrays for each trial are concatenated horizontally. When there is a
%%% variable set for each scenario, the m x n arrays for the same problem
%%% instances are concatenated horizontally across the scenarios, then the
%%% arrays representing all scenarios for each problem instance are concatenated vertically

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CLOS-5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save values from  closest 5 soln

x_clos5=zeros(m,n*trials);
runtimes_clos5=zeros(1,trials);

%performance analysis values for closest 5
closest5wtnontrivials = zeros(1,trials); %number of menu entries with nontrivial pij
scens2use_clos5 = zeros(1,trials);  %%% if there are fewer distinct scenarios than testsamps, test all scenarios
testyhat_clos5=zeros(m*trials,n*testsamps);
testscenprobs_clos5=zeros(trials,testsamps);
testscenbase_clos5=zeros(trials,testsamps);
testscenexp_clos5=zeros(trials,testsamps);

testobjs_clos5=zeros(trials,testsamps);
testobjave_clos5=zeros(1,trials);
testdupave_clos5=zeros(1,trials);
testrejave_clos5=zeros(1,trials);
testv_clos5=zeros(m*trials,n*testsamps);
testz_clos5=zeros(m*trials,n*testsamps);
testw_clos5=zeros(m*trials,testsamps);
aveassign_clos5=zeros(m,n*trials);

 avecomp_clos5=zeros(1,trials); %average compensation paid to matched drivers
aveperccomp_clos5=zeros(1,trials); %average compensation divided by the fare paid to matched drivers
avetotprofit_clos5=zeros(1,trials); % average profit made across the test scenarios
percposprofit_clos5=zeros(1,trials); %portion of test scenarios that have a positive profit
aveextratime_clos5=zeros(1,trials); %average extra driving time for matched drivers
averejfare_clos5=zeros(1,trials); %average fare of unmatched requests

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CLOS-1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%save values from  closest 1 soln

x_clos1=zeros(m,n*trials);
runtimes_clos1=zeros(1,trials);

%performance analysis values for closest 1
closest1wtnontrivials = zeros(1,trials); %number of menu entries with nontrivial pij
scens2use_clos1 = zeros(1,trials);  %%% if there are fewer distinct scenarios than testsamps, test all scenarios
testyhat_clos1=zeros(m*trials,n*testsamps);
testscenprobs_clos1=zeros(trials,testsamps);
testscenbase_clos1=zeros(trials,testsamps);
testscenexp_clos1=zeros(trials,testsamps);

testobjs_clos1=zeros(trials,testsamps);
testobjave_clos1=zeros(1,trials);
testdupave_clos1=zeros(1,trials);
testrejave_clos1=zeros(1,trials);
testv_clos1=zeros(m*trials,n*testsamps);
testz_clos1=zeros(m*trials,n*testsamps);
testw_clos1=zeros(m*trials,testsamps);
aveassign_clos1=zeros(m,n*trials); %for a problem instance, it's an m x n array where entry ij is the portion of 
% test scenarios in which request i is assigned to driver j


 avecomp_clos1=zeros(1,trials);
aveperccomp_clos1=zeros(1,trials);
avetotprofit_clos1=zeros(1,trials);
percposprofit_clos1=zeros(1,trials);
aveextratime_clos1=zeros(1,trials);
averejfare_clos1=zeros(1,trials);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DET-5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%save values from slsf scen generation and DET-5 soln
yhat_det5=zeros(m*trials,n);
simobjs_det5=zeros(1,trials);
x_det5=zeros(m,n*trials);
v_det5=zeros(m*trials,n);
z_det5=zeros(m*trials,n);
w_det5=zeros(m*trials,1);
runtimes_det5=zeros(1,trials);
gaps_det5=zeros(1,trials);

%performance analysis values det5
testyhat_det5=zeros(m*trials,n*testsamps);
testscenprobs_det5=zeros(trials,testsamps);
testscenbase_det5=zeros(trials,testsamps);
testscenexp_det5=zeros(trials,testsamps);

testobjs_det5=zeros(trials,testsamps);
testobjave_det5=zeros(1,trials);
testdupave_det5=zeros(1,trials);
testrejave_det5=zeros(1,trials);
testv_det5=zeros(m*trials,n*testsamps);
testz_det5=zeros(m*trials,n*testsamps);
testw_det5=zeros(m*trials,testsamps);
aveassign_det5=zeros(m,n*trials);%for a problem instance, it's an m x n array where entry ij is the portion of 
% test scenarios in which request i is assigned to driver j
runtimes_perf_det5=zeros(1,trials);


%quality metrics for det5
avecomp_det5=zeros(1,trials);
aveperccomp_det5=zeros(1,trials);
avetotprofit_det5=zeros(1,trials);
percposprofit_det5=zeros(1,trials);
aveextratime_det5=zeros(1,trials);
averejfare_det5=zeros(1,trials);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DET-1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%save values from slsf scen generation and DET-1 soln
yhat_det1=zeros(m*trials,n);
simobjs_det1=zeros(1,trials);
x_det1=zeros(m,n*trials);
v_det1=zeros(m*trials,n);
z_det1=zeros(m*trials,n);
w_det1=zeros(m*trials,1);
runtimes_det1=zeros(1,trials);
gaps_det1=zeros(1,trials);

%performance analysis values det1
det1wtnontrivials = zeros(1,trials); %number of menu entries with nontrivial pij
scens2use_det1 = zeros(1,trials);
testyhat_det1=zeros(m*trials,n*testsamps);
testscenprobs_det1=zeros(trials,testsamps);
testscenbase_det1=zeros(trials,testsamps);
testscenexp_det1=zeros(trials,testsamps);

testobjs_det1=zeros(trials,testsamps);
testobjave_det1=zeros(1,trials);
testdupave_det1=zeros(1,trials);
testrejave_det1=zeros(1,trials);
testv_det1=zeros(m*trials,n*testsamps);
testz_det1=zeros(m*trials,n*testsamps);
testw_det1=zeros(m*trials,testsamps);
aveassign_det1=zeros(m,n*trials);%for a problem instance, it's an m x n array where entry ij is the portion of 
% test scenarios in which request i is assigned to driver j
runtimes_perf_det1=zeros(1,trials);


%quality metrics for det1
avecomp_det1=zeros(1,trials);
aveperccomp_det1=zeros(1,trials);
avetotprofit_det1=zeros(1,trials);
percposprofit_det1=zeros(1,trials);
aveextratime_det1=zeros(1,trials);
averejfare_det1=zeros(1,trials);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DET-5le
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%save values from slsf scen generation and DET-5 less than or equal to theta soln
yhat_det5le=zeros(m*trials,n);
simobjs_det5le=zeros(1,trials);
x_det5le=zeros(m,n*trials);
v_det5le=zeros(m*trials,n);
z_det5le=zeros(m*trials,n);
w_det5le=zeros(m*trials,1);
runtimes_det5le=zeros(1,trials);
gaps_det5le=zeros(1,trials);

%performance analysis values det5le
det5lewtnontrivials = zeros(1,trials); %number of menu entries with nontrivial pij
scens2use_det5le = zeros(1,trials);  %%% if there are fewer distinct scenarios than testsamps, test all scenarios
testyhat_det5le=zeros(m*trials,n*testsamps);
testscenprobs_det5le=zeros(trials,testsamps);
testscenbase_det5le=zeros(trials,testsamps);
testscenexp_det5le=zeros(trials,testsamps);

testobjs_det5le=zeros(trials,testsamps);
testobjave_det5le=zeros(1,trials);
testdupave_det5le=zeros(1,trials);
testrejave_det5le=zeros(1,trials);
testv_det5le=zeros(m*trials,n*testsamps);
testz_det5le=zeros(m*trials,n*testsamps);
testw_det5le=zeros(m*trials,testsamps);
aveassign_det5le=zeros(m,n*trials);%for a problem instance, it's an m x n array where entry ij is the portion of 
% test scenarios in which request i is assigned to driver j
runtimes_perf_det5le=zeros(1,trials);


%quality metrics for det5le
avecomp_det5le=zeros(1,trials);
aveperccomp_det5le=zeros(1,trials);
avetotprofit_det5le=zeros(1,trials);
percposprofit_det5le=zeros(1,trials);
aveextratime_det5le=zeros(1,trials);
averejfare_det5le=zeros(1,trials);



for t=1:trials
    C=Clong(:,(t-1)*n+1:t*n);
    D=Dlong(:,(t-1)*n+1:t*n);
    r=rlong(:,t);
    fare=farelong(:,(t-1)*n+1:t*n);
    yprobs=yprobslong(:,(t-1)*n+1:t*n);
    slsfcomp=slsfcomplong(:,(t-1)*n+1:t*n);
    extradrivingtime=extradrivingtimelong(:,(t-1)*n+1:t*n);
    OjOimins=OjOiminslong(:,(t-1)*n+1:t*n);


     
  
      
      %%% calculate closest 5 menu & perf analysis (in terms of driver
      %%% origin distance from rider origin
      
        tic
        [obj,x6]=max_weight_menu(-OjOimins,5);
        toc
        x_clos5(:,(t-1)*n+1:t*n)=x6;
        runtimes_clos5(1,t)=toc;


       closest5wtnontrivials(1,t)=nnz(yprobs.*x6)-size(find(yprobs.*x6>=1),1)
       scens2use_clos5(1,t) = min(5000,2^closest5wtnontrivials(1,t));
      [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x6.*yprobs,scens2use_clos5(1,t),0);
      testyhat_clos5((t-1)*m+1:t*m,1:scens2use_clos5(1,t)*n)=testyhat;
        testscenprobs_clos5(t,1:scens2use_clos5(1,t))=testscenprobs;
        testscenbase_clos5(t,1:scens2use_clos5(1,t))=testscenbase;
        testscenexp_clos5(t,1:scens2use_clos5(1,t))=testscenexp;
      
      [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,qlong,x6,yprobs,scens2use_clos5(1,t),testyhat,testscenprobs);
      testobjs_clos5(t,1:scens2use_clos5(1,t))=objvals1;
        testobjave_clos5(1,t)=objave2;
        testdupave_clos5(1,t)=dupave1;
        testrejave_clos5(1,t)=rejave;
        testv_clos5((t-1)*m+1:t*m,1:scens2use_clos5(1,t)*n)=vfull1;
        testz_clos5((t-1)*m+1:t*m,1:scens2use_clos5(1,t)*n)=zfull1;
        testw_clos5((t-1)*m+1:t*m,1:scens2use_clos5(1,t))=wfull1;
        aveassign_clos5(:,(t-1)*n+1:t*n)=aveassign1;
        
        [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare]=quality_metrics(fare,slsfcomp,extradrivingtime,vfull1,wfull1);
          avecomp_clos5(1,t)=avecomp;
            aveperccomp_clos5(1,t)=aveperccomp;
            avetotprofit_clos5(1,t)=avetotprofit;
            percposprofit_clos5(1,t)=percposprofit;
            aveextratime_clos5(1,t)=aveextratime;
            averejfare_clos5(1,t)=averejfare ;
      
          %%% calculate closest 1 menu & perf analysis (in terms of driver
      %%% origin distance from rider origin
      
        tic
        [obj,x6]=max_weight_menu(-OjOimins,1)
        toc
        x_clos1(:,(t-1)*n+1:t*n)=x6;
        runtimes_clos1(1,t)=toc;

       closest1wtnontrivials(1,t)=nnz(yprobs.*x6)-size(find(yprobs.*x6>=1),1)
       scens2use_clos1(1,t) = min(5000,2^closest1wtnontrivials(1,t));
      [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x6.*yprobs,scens2use_clos1(1,t),0);
      testyhat_clos1((t-1)*m+1:t*m,1:scens2use_clos1(1,t)*n)=testyhat;
        testscenprobs_clos1(t,1:scens2use_clos1(1,t))=testscenprobs;
        testscenbase_clos1(t,1:scens2use_clos1(1,t))=testscenbase;
        testscenexp_clos1(t,1:scens2use_clos1(1,t))=testscenexp;
      
      [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,qlong,x6,yprobs,scens2use_clos1(1,t),testyhat,testscenprobs);
      testobjs_clos1(t,1:scens2use_clos1(1,t))=objvals1;
        testobjave_clos1(1,t)=objave2;
        testdupave_clos1(1,t)=dupave1;
        testrejave_clos1(1,t)=rejave;
        testv_clos1((t-1)*m+1:t*m,1:scens2use_clos1(1,t)*n)=vfull1;
        testz_clos1((t-1)*m+1:t*m,1:scens2use_clos1(1,t)*n)=zfull1;
        testw_clos1((t-1)*m+1:t*m,1:scens2use_clos1(1,t))=wfull1;
        aveassign_clos1(:,(t-1)*n+1:t*n)=aveassign1;
        
        [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare]=quality_metrics(fare,slsfcomp,extradrivingtime,vfull1,wfull1);
          avecomp_clos1(1,t)=avecomp;
            aveperccomp_clos1(1,t)=aveperccomp;
            avetotprofit_clos1(1,t)=avetotprofit;
            percposprofit_clos1(1,t)=percposprofit;
            aveextratime_clos1(1,t)=aveextratime;
            averejfare_clos1(1,t)=averejfare;
            
           
     %solve det-5 
     
    tic
    [obj6,gap6,x6,v6,z6,w6]=fixed_y_prob_cplex_dot(C,D,r,5,qlong,yprobs,round(yprobs),1,1,0,60,.01,0);
    toc
    
    
    simobjs_det5(1,t)=obj6;
    x_det5(:,(t-1)*n+1:t*n)=x6;
    v_det5((t-1)*m+1:t*m,:)=v6;
    z_det5((t-1)*m+1:t*m,:)=z6;
    w_det5((t-1)*m+1:t*m,:)=w6;
    runtimes_det5(1,t)=toc;
    gaps_det5(1,t)=gap6;
    
    
    
    
    % det5 performance analysis
     det5wtnontrivials(1,t)=nnz(yprobs.*x6)-size(find(yprobs.*x6>=1),1)
       scens2use_det5(1,t) = min(5000,2^det5wtnontrivials(1,t));
      [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x6.*yprobs,scens2use_det5(1,t),0);
      
    tic
    [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x6.*yprobs,scens2use_det5(1,t),0);
    toc
    testyhat_det5((t-1)*m+1:t*m,:)=testyhat;
    testscenprobs_det5(t,:)=testscenprobs;
    testscenbase_det5(t,:)=testscenbase;
    testscenexp_det5(t,:)=testscenexp;
    runtimes_perf_det5(1,t)=toc;

    [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,qlong,x6,yprobs,scens2use_det5(1,t),testyhat,testscenprobs);
      testobjs_det5(t,1:scens2use_det5(1,t))=objvals1;
        testobjave_det5(1,t)=objave2;
        testdupave_det5(1,t)=dupave1;
        testrejave_det5(1,t)=rejave;
        testv_det5((t-1)*m+1:t*m,1:scens2use_det5(1,t)*n)=vfull1;
        testz_det5((t-1)*m+1:t*m,1:scens2use_det5(1,t)*n)=zfull1;
        testw_det5((t-1)*m+1:t*m,1:scens2use_det5(1,t))=wfull1;
        aveassign_det5(:,(t-1)*n+1:t*n)=aveassign1;
    
    % det5 quality metrics
    [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare]=quality_metrics(fare,slsfcomp,extradrivingtime,vfull,wfull)
    avecomp_det5(1,t)=avecomp;
    aveperccomp_det5(1,t)=aveperccomp;
    avetotprofit_det5(1,t)=avetotprofit;
    percposprofit_det5(1,t)=percposprofit;
    aveextratime_det5(1,t)=aveextratime;
    averejfare_det5(1,t)=averejfare;
          
            
      %solve det-1        
    tic
    [obj6,gap6,x6,v6,z6,w6]=fixed_y_prob_cplex_dot(C,D,r,1,qlong,yprobs,round(yprobs),1,1,0,60,.01,0);
    toc
    
    
    simobjs_det1(1,t)=obj6;
    x_det1(:,(t-1)*n+1:t*n)=x6;
    v_det1((t-1)*m+1:t*m,:)=v6;
    z_det1((t-1)*m+1:t*m,:)=z6;
    w_det1((t-1)*m+1:t*m,:)=w6;
    runtimes_det1(1,t)=toc;
    gaps_det1(1,t)=gap6;
     
     det1wtnontrivials(1,t)=nnz(yprobs.*x6)-size(find(yprobs.*x6>=1),1)
       scens2use_det1(1,t) = min(5000,2^det1wtnontrivials(1,t));
      [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x6.*yprobs,scens2use_det1(1,t),0);
      testyhat_det1((t-1)*m+1:t*m,1:scens2use_det1(1,t)*n)=testyhat;
        testscenprobs_det1(t,1:scens2use_det1(1,t))=testscenprobs;
        testscenbase_det1(t,1:scens2use_det1(1,t))=testscenbase;
        testscenexp_det1(t,1:scens2use_det1(1,t))=testscenexp;
      
      [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,qlong,x6,yprobs,scens2use_det1(1,t),testyhat,testscenprobs);
      testobjs_det1(t,1:scens2use_det1(1,t))=objvals1;
        testobjave_det1(1,t)=objave2;
        testdupave_det1(1,t)=dupave1;
        testrejave_det1(1,t)=rejave;
        testv_det1((t-1)*m+1:t*m,1:scens2use_det1(1,t)*n)=vfull1;
        testz_det1((t-1)*m+1:t*m,1:scens2use_det1(1,t)*n)=zfull1;
        testw_det1((t-1)*m+1:t*m,1:scens2use_det1(1,t))=wfull1;
        aveassign_det1(:,(t-1)*n+1:t*n)=aveassign1;
        
        [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare]=quality_metrics(fare,slsfcomp,extradrivingtime,vfull1,wfull1);
          avecomp_det1(1,t)=avecomp;
            aveperccomp_det1(1,t)=aveperccomp;
            avetotprofit_det1(1,t)=avetotprofit;
            percposprofit_det1(1,t)=percposprofit;
            aveextratime_det1(1,t)=aveextratime;
            averejfare_det1(1,t)=averejfare;
            
         %solve det-5le        
    tic
    [obj,gap,x,v,z,w]=fixed_y_prob_cplex_dot(C,D,r,5,qlong,yprobs,round(yprobs),1,0,0,60,.01,0);
    toc
    
    
    simobjs_det5le(1,t)=obj;
    x_det5le(:,(t-1)*n+1:t*n)=x;
    v_det5le((t-1)*m+1:t*m,:)=v;
    z_det5le((t-1)*m+1:t*m,:)=z;
    w_det5le((t-1)*m+1:t*m,:)=w;
    runtimes_det5le(1,t)=toc;
    gaps_det5le(1,t)=gap;
     
     det5lewtnontrivials(1,t)=nnz(yprobs.*x)-size(find(yprobs.*x>=1),1)
       scens2use_det5le(1,t) = min(5000,2^det5lewtnontrivials(1,t));
      [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*yprobs,scens2use_det5le(1,t),0);
      testyhat_det5le((t-1)*m+1:t*m,1:scens2use_det5le(1,t)*n)=testyhat;
        testscenprobs_det5le(t,1:scens2use_det5le(1,t))=testscenprobs;
        testscenbase_det5le(t,1:scens2use_det5le(1,t))=testscenbase;
        testscenexp_det5le(t,1:scens2use_det5le(1,t))=testscenexp;
      
      [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,qlong,x,yprobs,scens2use_det5le(1,t),testyhat,testscenprobs);
      testobjs_det5le(t,1:scens2use_det5le(1,t))=objvals1;
        testobjave_det5le(1,t)=objave2;
        testdupave_det5le(1,t)=dupave1;
        testrejave_det5le(1,t)=rejave;
        testv_det5le((t-1)*m+1:t*m,1:scens2use_det5le(1,t)*n)=vfull1;
        testz_det5le((t-1)*m+1:t*m,1:scens2use_det5le(1,t)*n)=zfull1;
        testw_det5le((t-1)*m+1:t*m,1:scens2use_det5le(1,t))=wfull1;
        aveassign_det5le(:,(t-1)*n+1:t*n)=aveassign1;
        
        [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare]=quality_metrics(fare,slsfcomp,extradrivingtime,vfull1,wfull1);
          avecomp_det5le(1,t)=avecomp;
            aveperccomp_det5le(1,t)=aveperccomp;
            avetotprofit_det5le(1,t)=avetotprofit;
            percposprofit_det5le(1,t)=percposprofit;
            aveextratime_det5le(1,t)=aveextratime;
            averejfare_det5le(1,t)=averejfare;
      
      
end
 
stem= sprintf('slsfpaper_exp_heur1%s.mat',notes);

filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_2\' stem];
save(filename,'-v7.3');

