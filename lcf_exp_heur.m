%%% this code, for each problem instance, solves each of the heuristic methods (clos1, clos5, lik1, lik5)
%%% and does performance analysis on each of those solution, then
%%% a matlab data file is created saving all matlab variables, the file
%%% title is 'lcf_exp_heur1' plus any other notes in the notes string,
%%% the variables for each experiment end with the experiment name (e.g. _clos1) , and 
%%%(most of) the performance analysis variables/values start with 'test' 

%%% load the problem instance input parameter info
load('C:\Users\horneh\Documents\LCF_Paper_experiments\parameter_values\paramandslsf1.mat');

%point to the folder containing CPLEX
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio129\CPLEX_Studio\cplex\matlab\x64_win64'));
trials = 100; %number of problem instances
notes = ''; %any notes you want to add to the outputted file title

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% construct variables/values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% when the variable/value is the same for all scenarios (e.g. x, p), the
%%% arrays for each trial are concatenated horizontally. When there is a
%%% variable set for each scenario, the m x n arrays for the same problem
%%% instances are concatenated horizontally across the scenarios, then the
%%% arrays representing all scenarios for each problem instance are concatenated vertically

%%%%%%%%%%%%%%%%%%%%%%%%%%
%save values from  closest 5 heuristic soln

x_clos5=zeros(m,n*trials);
runtimes_clos5=zeros(1,trials); %runtime of the heuristic

%performance analysis values for closest 5
closest5wtnontrivials = zeros(1,trials); %number of menu entries with nontrivial pij
scens2use_clos5 = zeros(1,trials); %%% if there are fewer distinct scenarios than testsamps, test all scenarios
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
aveassign_clos5=zeros(m,n*trials); %for a problem instance, it's an m x n array where entry ij is the portion of 
% test scenarios in which request i is assigned to driver j

 avecomp_clos5=zeros(1,trials); %average compensation paid to matched drivers
aveperccomp_clos5=zeros(1,trials); %average compensation divided by the fare paid to matched drivers
avetotprofit_clos5=zeros(1,trials); % average profit made across the test scenarios
percposprofit_clos5=zeros(1,trials); %portion of test scenarios that have a positive profit
aveextratime_clos5=zeros(1,trials); %average extra driving time for matched drivers
averejfare_clos5=zeros(1,trials); %average fare of unmatched requests

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save values from  closest 1 soln

x_clos1=zeros(m,n*trials);
runtimes_clos1=zeros(1,trials); %runtime of the heuristic

%performance analysis values for closest 1
closest1wtnontrivials = zeros(1,trials); %number of menu entries with nontrivial pij
scens2use_clos1 = zeros(1,trials); %%% if there are fewer distinct scenarios than testsamps, test all scenarios
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

 avecomp_clos1=zeros(1,trials); %average compensation paid to matched drivers
aveperccomp_clos1=zeros(1,trials); %average compensation divided by the fare paid to matched drivers
avetotprofit_clos1=zeros(1,trials); % average profit made across the test scenarios
percposprofit_clos1=zeros(1,trials); %portion of test scenarios that have a positive profit
aveextratime_clos1=zeros(1,trials); %average extra driving time for matched drivers
averejfare_clos1=zeros(1,trials);  %average fare of unmatched requests

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save values from  most likely 5 

x_lik5=zeros(m,n*trials);
runtimes_lik5=zeros(1,trials);

%performance analysis values for most likely 5
likely5wtnontrivials = zeros(1,trials);
scens2use_lik5 = zeros(1,trials);
testyhat_lik5=zeros(m*trials,n*testsamps);
testscenprobs_lik5=zeros(trials,testsamps);
testscenbase_lik5=zeros(trials,testsamps);
testscenexp_lik5=zeros(trials,testsamps);

testobjs_lik5=zeros(trials,testsamps);
testobjave_lik5=zeros(1,trials);
testdupave_lik5=zeros(1,trials);
testrejave_lik5=zeros(1,trials);
testv_lik5=zeros(m*trials,n*testsamps);
testz_lik5=zeros(m*trials,n*testsamps);
testw_lik5=zeros(m*trials,testsamps);
aveassign_lik5=zeros(m,n*trials);

 avecomp_lik5=zeros(1,trials);
aveperccomp_lik5=zeros(1,trials);
avetotprofit_lik5=zeros(1,trials);
percposprofit_lik5=zeros(1,trials);
aveextratime_lik5=zeros(1,trials);
averejfare_lik5=zeros(1,trials);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save values from  most likely 1

x_lik1=zeros(m,n*trials);
runtimes_lik1=zeros(1,trials);

%performance analysis values for most likely 1
likely1wtnontrivials = zeros(1,trials);
scens2use_lik1 = zeros(1,trials);
testyhat_lik1=zeros(m*trials,n*testsamps);
testscenprobs_lik1=zeros(trials,testsamps);
testscenbase_lik1=zeros(trials,testsamps);
testscenexp_lik1=zeros(trials,testsamps);

testobjs_lik1=zeros(trials,testsamps);
testobjave_lik1=zeros(1,trials);
testdupave_lik1=zeros(1,trials);
testrejave_lik1=zeros(1,trials);
testv_lik1=zeros(m*trials,n*testsamps);
testz_lik1=zeros(m*trials,n*testsamps);
testw_lik1=zeros(m*trials,testsamps);
aveassign_lik1=zeros(m,n*trials);

 avecomp_lik1=zeros(1,trials);
aveperccomp_lik1=zeros(1,trials);
avetotprofit_lik1=zeros(1,trials);
percposprofit_lik1=zeros(1,trials);
aveextratime_lik1=zeros(1,trials);
averejfare_lik1=zeros(1,trials);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%solve each heuristic

for t=1:trials
    
    %store the parameter values for the problem instance into temporary
    %variables for convenience
    C=Clong(:,(t-1)*n+1:t*n);
    D=Dlong(:,(t-1)*n+1:t*n);
    r=rlong(:,t);
    fare=farelong(:,(t-1)*n+1:t*n);
    yprobs=yprobslong(:,(t-1)*n+1:t*n);
    slsfcomp=slsfcomplong(:,(t-1)*n+1:t*n);
    extradrivingtime=extradrivingtimelong(:,(t-1)*n+1:t*n);
    OjOimins=OjOiminslong(:,(t-1)*n+1:t*n);


     
  
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %%% closest 5 menu & perf analysis 
      %%% solve heuristic
        tic
        [obj,x6]=max_weight_menu(-OjOimins,5);
        toc
        x_clos5(:,(t-1)*n+1:t*n)=x6;
        runtimes_clos5(1,t)=toc;


       closest5wtnontrivials(1,t)=nnz(yprobs.*x6)-size(find(yprobs.*x6>=1),1)
       scens2use_clos5(1,t) = min(5000,2^closest5wtnontrivials(1,t));
       
       %generate random test scenarios
      [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x6.*yprobs,scens2use_clos5(1,t),0);
      testyhat_clos5((t-1)*m+1:t*m,1:scens2use_clos5(1,t)*n)=testyhat;
        testscenprobs_clos5(t,1:scens2use_clos5(1,t))=testscenprobs;
        testscenbase_clos5(t,1:scens2use_clos5(1,t))=testscenbase;
        testscenexp_clos5(t,1:scens2use_clos5(1,t))=testscenexp;
      
        %performance analysis
      [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,qlong,x6,yprobs,scens2use_clos5(1,t),testyhat,testscenprobs);
      testobjs_clos5(t,1:scens2use_clos5(1,t))=objvals1;
        testobjave_clos5(1,t)=objave2;
        testdupave_clos5(1,t)=dupave1;
        testrejave_clos5(1,t)=rejave;
        testv_clos5((t-1)*m+1:t*m,1:scens2use_clos5(1,t)*n)=vfull1;
        testz_clos5((t-1)*m+1:t*m,1:scens2use_clos5(1,t)*n)=zfull1;
        testw_clos5((t-1)*m+1:t*m,1:scens2use_clos5(1,t))=wfull1;
        aveassign_clos5(:,(t-1)*n+1:t*n)=aveassign1;
        
        %quality metrics
        [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare]=quality_metrics(fare,slsfcomp,extradrivingtime,vfull1,wfull1);
          avecomp_clos5(1,t)=avecomp;
            aveperccomp_clos5(1,t)=aveperccomp;
            avetotprofit_clos5(1,t)=avetotprofit;
            percposprofit_clos5(1,t)=percposprofit;
            aveextratime_clos5(1,t)=aveextratime;
            averejfare_clos5(1,t)=averejfare ;
      
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%% closest 1 menu & perf analysis 
        %solve
          tic
        [obj,x6]=max_weight_menu(-OjOimins,1)
        toc
        x_clos1(:,(t-1)*n+1:t*n)=x6;
        runtimes_clos1(1,t)=toc;

       closest1wtnontrivials(1,t)=nnz(yprobs.*x6)-size(find(yprobs.*x6>=1),1)
       scens2use_clos1(1,t) = min(5000,2^closest1wtnontrivials(1,t));
       
       %generate random test scenarios
      [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x6.*yprobs,scens2use_clos1(1,t),0);
      testyhat_clos1((t-1)*m+1:t*m,1:scens2use_clos1(1,t)*n)=testyhat;
        testscenprobs_clos1(t,1:scens2use_clos1(1,t))=testscenprobs;
        testscenbase_clos1(t,1:scens2use_clos1(1,t))=testscenbase;
        testscenexp_clos1(t,1:scens2use_clos1(1,t))=testscenexp;
      
        %perf analysis
      [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,qlong,x6,yprobs,scens2use_clos1(1,t),testyhat,testscenprobs);
      testobjs_clos1(t,1:scens2use_clos1(1,t))=objvals1;
        testobjave_clos1(1,t)=objave2;
        testdupave_clos1(1,t)=dupave1;
        testrejave_clos1(1,t)=rejave;
        testv_clos1((t-1)*m+1:t*m,1:scens2use_clos1(1,t)*n)=vfull1;
        testz_clos1((t-1)*m+1:t*m,1:scens2use_clos1(1,t)*n)=zfull1;
        testw_clos1((t-1)*m+1:t*m,1:scens2use_clos1(1,t))=wfull1;
        aveassign_clos1(:,(t-1)*n+1:t*n)=aveassign1;
        
        %quality mettics
        [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare]=quality_metrics(fare,slsfcomp,extradrivingtime,vfull1,wfull1);
          avecomp_clos1(1,t)=avecomp;
            aveperccomp_clos1(1,t)=aveperccomp;
            avetotprofit_clos1(1,t)=avetotprofit;
            percposprofit_clos1(1,t)=percposprofit;
            aveextratime_clos1(1,t)=aveextratime;
            averejfare_clos1(1,t)=averejfare;
          
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% most likely 5 menu & perf analysis 
        
        %solve heuristic
        tic
        [obj,x6]=max_weight_menu(yprobs,5);
        toc
        x_lik5(:,(t-1)*n+1:t*n)=x6;
        runtimes_lik5(1,t)=toc;

       likely5wtnontrivials(1,t)=nnz(yprobs.*x6)-size(find(yprobs.*x6>=1),1)
       scens2use_lik5(1,t) = min(5000,2^likely5wtnontrivials(1,t));
       
       %generate random test scenarios
      [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x6.*yprobs,scens2use_lik5(1,t),0);
      testyhat_lik5((t-1)*m+1:t*m,1:scens2use_lik5(1,t)*n)=testyhat;
        testscenprobs_lik5(t,1:scens2use_lik5(1,t))=testscenprobs;
        testscenbase_lik5(t,1:scens2use_lik5(1,t))=testscenbase;
        testscenexp_lik5(t,1:scens2use_lik5(1,t))=testscenexp;
      
        %performance analysis
      [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,qlong,x6,yprobs,scens2use_lik5(1,t),testyhat,testscenprobs);
      testobjs_lik5(t,1:scens2use_lik5(1,t))=objvals1;
        testobjave_lik5(1,t)=objave2;
        testdupave_lik5(1,t)=dupave1;
        testrejave_lik5(1,t)=rejave;
        testv_lik5((t-1)*m+1:t*m,1:scens2use_lik5(1,t)*n)=vfull1;
        testz_lik5((t-1)*m+1:t*m,1:scens2use_lik5(1,t)*n)=zfull1;
        testw_lik5((t-1)*m+1:t*m,1:scens2use_lik5(1,t))=wfull1;
        aveassign_lik5(:,(t-1)*n+1:t*n)=aveassign1;
        
        %quality metrics
        [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare]=quality_metrics(fare,slsfcomp,extradrivingtime,vfull1,wfull1);
          avecomp_lik5(1,t)=avecomp;
            aveperccomp_lik5(1,t)=aveperccomp;
            avetotprofit_lik5(1,t)=avetotprofit;
            percposprofit_lik5(1,t)=percposprofit;
            aveextratime_lik5(1,t)=aveextratime;
            averejfare_lik5(1,t)=averejfare;
            
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        %%% solve and perf analysis for most likely 1 request    
        tic
        [obj,x6]=max_weight_menu(yprobs,1);
        toc
        x_lik1(:,(t-1)*n+1:t*n)=x6;
        runtimes_lik1(1,t)=toc;
        
       likely1wtnontrivials(1,t)=nnz(yprobs.*x6)-size(find(yprobs.*x6>=1),1)
       scens2use_lik1(1,t) = min(5000,2^likely1wtnontrivials(1,t));
       
       % generate random test scenarios
      [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x6.*yprobs,scens2use_lik1(1,t),0);
      testyhat_lik1((t-1)*m+1:t*m,1:scens2use_lik1(1,t)*n)=testyhat;
        testscenprobs_lik1(t,1:scens2use_lik1(1,t))=testscenprobs;
        testscenbase_lik1(t,1:scens2use_lik1(1,t))=testscenbase;
        testscenexp_lik1(t,1:scens2use_lik1(1,t))=testscenexp;
      
        %perf analysis
      [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,qlong,x6,yprobs,scens2use_lik1(1,t),testyhat,testscenprobs);
      testobjs_lik1(t,1:scens2use_lik1(1,t))=objvals1;
        testobjave_lik1(1,t)=objave2;
        testdupave_lik1(1,t)=dupave1;
        testrejave_lik1(1,t)=rejave;
        testv_lik1((t-1)*m+1:t*m,1:scens2use_lik1(1,t)*n)=vfull1;
        testz_lik1((t-1)*m+1:t*m,1:scens2use_lik1(1,t)*n)=zfull1;
        testw_lik1((t-1)*m+1:t*m,1:scens2use_lik1(1,t))=wfull1;
        aveassign_lik1(:,(t-1)*n+1:t*n)=aveassign1;
        
        %quality metrics
        [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare]=quality_metrics(fare,slsfcomp,extradrivingtime,vfull1,wfull1);
          avecomp_lik1(1,t)=avecomp;
            aveperccomp_lik1(1,t)=aveperccomp;
            avetotprofit_lik1(1,t)=avetotprofit;
            percposprofit_lik1(1,t)=percposprofit;
            aveextratime_lik1(1,t)=aveextratime;
            averejfare_lik1(1,t)=averejfare;
      
      
      
end
 

%create matlab data file with all variables
stem= sprintf('lcf_exp_heur1%s.mat',notes);

filename =[ 'C:\Users\horneh\Documents\LCF_Paper_experiments\' stem];
save(filename,'-v7.3');

