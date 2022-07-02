load('C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Paper_experiments\informs_exp.mat');
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio129\cplex\matlab\x64_win64'));
%timelims=[60,150,200,300,500];

%save values from  closest 5 soln

x_clos5=zeros(m,n*trials);
runtimes_clos5=zeros(1,trials);

%performance analysis values for closest 5
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

 avecomp_clos5=zeros(1,trials);
aveperccomp_clos5=zeros(1,trials);
avetotprofit_clos5=zeros(1,trials);
percposprofit_clos5=zeros(1,trials);
aveextratime_clos5=zeros(1,trials);
averejfare_clos5=zeros(1,trials);

%save values from  closest 1 soln

x_lik5=zeros(m,n*trials);
runtimes_lik5=zeros(1,trials);

%performance analysis values for closest 1
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
        [obj,x6]=max_weight_menu(-OjOimins,5)
        toc
        x_clos5(:,(t-1)*n+1:t*n)=x6;
        runtimes_clos5(1,t)=toc;

       closest5wtnontrivials(1,t)=nnz(yprobs.*x6)-size(find(yprobs.*x6>=1),1)
      [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x6.*yprobs,min(5000,2^closest5wtnontrivials(1,t)),0);
      testyhat_clos5((t-1)*m+1:t*m,:)=testyhat;
        testscenprobs_clos5(t,:)=testscenprobs;
        testscenbase_clos5(t,:)=testscenbase;
        testscenexp_clos5(t,:)=testscenexp;
      
      [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,qlong,x6,yprobs,min(5000,closest5wtnontrivials(1,t)),testyhat,testscenprobs);
      testobjs_clos5(t,:)=objvals1;
        testobjave_clos5(1,t)=objave2;
        testdupave_clos5(1,t)=dupave1;
        testrejave_clos5(1,t)=rejave;
        testv_clos5((t-1)*m+1:t*m,:)=vfull1;
        testz_clos5((t-1)*m+1:t*m,:)=zfull1;
        testw_clos5((t-1)*m+1:t*m,:)=wfull1;
        aveassign_clos5(:,(t-1)*n+1:t*n)=aveassign1;
        
        [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare]=quality_metrics(fare,slsfcomp,extradrivingtime,vfull1,wfull1);
          avecomp_clos5(1,t)=avecomp
            aveperccomp_clos5(1,t)=aveperccomp
            avetotprofit_clos5(1,t)=avetotprofit
            percposprofit_clos5(1,t)=percposprofit
            aveextratime_clos5(1,t)=aveextratime
            averejfare_clos5(1,t)=averejfare
      
            
            
            %%% calculate most likely 5 menu & perf analysis 
      
        tic
        [obj,x6]=max_weight_menu(yprobs,5)
        toc
        x_lik5(:,(t-1)*n+1:t*n)=x6;
        runtimes_lik5(1,t)=toc;

       likely5wtnontrivials(1,t)=nnz(yprobs.*x6)-size(find(yprobs.*x6>=1),1)
      [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x6.*yprobs,min(5000,2^likely5wtnontrivials(1,t)),0);
      testyhat_lik5((t-1)*m+1:t*m,:)=testyhat;
        testscenprobs_lik5(t,:)=testscenprobs;
        testscenbase_lik5(t,:)=testscenbase;
        testscenexp_lik5(t,:)=testscenexp;
      
      [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,qlong,x6,yprobs,min(5000,closest5wtnontrivials(1,t)),testyhat,testscenprobs);
      testobjs_lik5(t,:)=objvals1;
        testobjave_lik5(1,t)=objave2;
        testdupave_lik5(1,t)=dupave1;
        testrejave_lik5(1,t)=rejave;
        testv_lik5((t-1)*m+1:t*m,:)=vfull1;
        testz_lik5((t-1)*m+1:t*m,:)=zfull1;
        testw_lik5((t-1)*m+1:t*m,:)=wfull1;
        aveassign_lik5(:,(t-1)*n+1:t*n)=aveassign1;
        
        [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare]=quality_metrics(fare,slsfcomp,extradrivingtime,vfull1,wfull1);
          avecomp_lik5(1,t)=avecomp
            aveperccomp_lik5(1,t)=aveperccomp
            avetotprofit_lik5(1,t)=avetotprofit
            percposprofit_lik5(1,t)=percposprofit
            aveextratime_lik5(1,t)=aveextratime
            averejfare_lik5(1,t)=averejfare
      
      
      
end
 
stem= sprintf('informs_heur%s.mat',notes);

filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Paper_experiments\' stem];
save(filename,'-v7.3');

