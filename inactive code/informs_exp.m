
m=20;
n=20;
s=10; %number of variable scenarios
sfixed=10; %%number of fixed scenarios
mincomp=0.8;
slsfperc=0.8;
premium=0.75*ones(m,n);
trials=100;
test=0;
numtests=1;
notes='';
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio129\cplex\matlab\x64_win64'));
timelims=200;
sampsizes=[5,10,20,50,80,100,150];
lcfgap=0.05;
fixedmenu=1; %%% 
fixedscens=1;
lcfscentype='r'
useslsfscens=0;
equalscenwts=1;
iterative=1;
guessbest=1;
noziter=0;
slsfscens=100;
guessbestmetric='o';
cumperf=1;
ell=1;
testsamps=5000;
regression=0;
if iterative==1
    iterations=10;
    randiters=0;
    perfeveryiter=0;
    runtimes=zeros(numtests,trials);
    %numtests=iterations;
    if guessbest==1
        guessbestiter=zeros(numtests,trials);
        bestest=zeros(numtests,trials);
        
        returnedobjs=zeros(numtests,trials);
        %estobjs=zeros(iterations+1,trials);
        minitestsize=200;
        doubletest=1; 
        xbest=zeros(m,n);
        ubest=zeros(m,n);
        pbest=zeros(m,n);
        ptruebest=zeros(m,n);
        
    end
   
end
smoltestsize=200;
lcfsimobjs=zeros(numtests,trials);
lcfobjs=zeros(numtests,trials);
estslsfobjs=zeros(numtests,trials);
estrejs=zeros(numtests,trials);
slsfobjs=zeros(numtests,trials);
lcfrejs=zeros(numtests,trials);
slsfrejs=zeros(numtests,trials);
lcfunhap=zeros(numtests,trials);
slsfunhap=zeros(numtests,trials);
menusizes=zeros(numtests,trials);
gaps=zeros(numtests,trials);
runtimes=zeros(numtests,trials);
slsfavecomp=zeros(numtests,trials);
slsfaveperccomp=zeros(numtests,trials);
slsfavetotprofit=zeros(numtests,trials);
slsfpercposprofit=zeros(numtests,trials);
slsfaveextratime=zeros(numtests,trials);
slsfaverejfare=zeros(numtests,trials);
lcfavecomp=zeros(numtests,trials);
lcfaveperccomp=zeros(numtests,trials);
lcfavetotprofit=zeros(numtests,trials);
lcfpercposprofit=zeros(numtests,trials);
lcfaveextratime=zeros(numtests,trials);
lcfaverejfare=zeros(numtests,trials);
pquants=zeros(trials,5);
compquants=zeros(trials,5);
nontrivialvals=zeros(numtests,trials);
compportion80=zeros(numtests,trials);
compportionmin=zeros(numtests,trials);
avepij=zeros(numtests,trials);
pijover5=zeros(numtests,trials);
pijequal1=zeros(numtests,trials);
failedsecond=zeros(iterations,trials);
testedtwice=zeros(iterations,trials);
iters=zeros(numtests,trials);
meanfare=zeros(numtests,trials);


%variables from generating parameters
Chatlong=zeros(m,n*trials);
Clong=zeros(m,n*trials);
Dlong=zeros(m,n*trials);
rlong=zeros(m,trials);
farelong=zeros(m,n*trials);
yprobslong=zeros(m,n*trials);
slsfcomplong=zeros(m,n*trials);
alphavalslong=zeros(m,n*trials);
betavalslong=zeros(m,n*trials);
Oilong=zeros(m,trials);
Dilong=zeros(m,trials);
Ojlong=zeros(n,trials);
Djlong=zeros(n,trials);
OjOiminslong=zeros(m,n*trials);
extradrivingtimelong=zeros(m,n*trials);
drandlong=zeros(m,n*trials);

%save values from  slsf soln

x_slsf=zeros(m,n*trials);
runtimes_slsf=zeros(1,trials);

%performance analysis values
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

%save values from lcf  soln

xbestlong=zeros(m,n*trials);
ptruebestlong=zeros(m,n*trials);
pbestlong=zeros(m,n*trials);
ubestlong=zeros(m,n*trials);
cumcomplong=zeros(m,n*trials);

%performance analysis values
testyhat_lcf=zeros(m*trials,n*testsamps);
testscenprobs_lcf=zeros(trials,testsamps);
testscenbase_lcf=zeros(trials,testsamps);
testscenexp_lcf=zeros(trials,testsamps);

testobjs_lcf=zeros(trials,testsamps);
testobjave_lcf=zeros(1,trials);
testdupave_lcf=zeros(1,trials);
testrejave_lcf=zeros(1,trials);
testv_lcf=zeros(m*trials,n*testsamps);
testz_lcf=zeros(m*trials,n*testsamps);
testw_lcf=zeros(m*trials,testsamps);
aveassign_lcf=zeros(m,n*trials);


for t=1:trials

    [Chat,C,D,r,fare,qlong,yprobs,slsfcomp,alphavals,beta,Oi,Di,Oj,Dj,OjOimins,extradrivingtime,drand]=generate_params_compmodel(m,n,slsfperc);
    meanfare(ell,t)=mean(mean(fare));
    Chatlong(:,(t-1)*n+1:t*n)=Chat;
    Clong(:,(t-1)*n+1:t*n)=C;
    Dlong(:,(t-1)*n+1:t*n)=D;
    rlong(:,t)=r;
    farelong(:,(t-1)*n+1:t*n)=fare;
    yprobslong(:,(t-1)*n+1:t*n)=yprobs;
    slsfcomplong(:,(t-1)*n+1:t*n)=slsfcomp;
    alphavalslong(:,(t-1)*n+1:t*n)=alphavals;
    betavalslong(:,(t-1)*n+1:t*n)=beta;
    Oilong(:,t)=Oi;
    Dilong(:,t)=Di;
    Ojlong(:,t)=Oj;
    Djlong(:,t)=Dj;
    OjOiminslong(:,(t-1)*n+1:t*n)=OjOimins;
    extradrivingtimelong(:,(t-1)*n+1:t*n)=extradrivingtime;
    drandlong(:,t)=drand;
  


 %%% solve slsf 
 [yhat,scenprobs,newretention,scenbase,scenexp]=filter_scens(m,n,yprobs,0,0,0,1000000,'t',100);
 tic
 [obj2,gap2,x2,v2,z2,w2]=fixed_y_prob_cplex_dot(C,D,r,5,q,yprobs,yhat,scenprobs,0,0,30,.01,0);
 toc
 if nnz(x2)< 2*n
  tic
 [obj2,gap2,x2,v2,z2,w2]=fixed_y_prob_cplex_dot(C,D,r,5,q,yprobs,yhat,scenprobs,0,0,60,.01,0);
 toc
 end
 runtimes(ell,t)=toc;
x_slsf(:,(t-1)*n+1:t*n)=x2;
runtimes_slsf(1,t)=toc;

  %%% solve compensation model plus analysis
  if fixedmenu==1

    x=x2;
     if fixedscens==0
        tic
        [obj,gap,v,w,yhat,p,ptrue,u,psi]=comp_model_fixed_menu(Chat,x,q,s,fare,alphavals,beta,premium,mincomp,timelims,lcfgap,0);
         %[obj,gap,v,vfull,w,yhat,p,ptrue,u,psi]=comp_model_no_v_fixed_menu(Chat,x,q,s,fare,alphavals,beta,premium,mincomp,timelims,lcfgap,0);
       
        toc
     else
         
         if lcfscentype=='m'
         
             if useslsfscens==1
                 lcfyhat=yhat(:,1:sfixed*n);
             else
                [lcfyhat,scenprobs,newretention,scenbase,scenexp]=filter_scens(m,n,x.*yprobs,0,0,0,1000000,'t',sfixed);
             end
             
             if equalscenwts==0
                fscenprobs=scenprobs(1:sfixed)/sum(scenprobs(1:sfixed))*sfixed;
             else
                 fscenprobs=ones(1,sfixed);
             end
             
         else
             [lcfyhat,scenprobs,scenbase,scenexp]=indepy_generate_scens(x.*yprobs,sfixed,0);
             fscenprobs=ones(1,sfixed);
         end
         
         
         
          
            
         tic
         [obj,gap,v,w,yhat,p,ptrue,u,psi]=comp_model_w_scens_fixed_menu(Chat,x,q,s,lcfyhat,fscenprobs,fare,alphavals,beta,premium,mincomp,timelims,lcfgap,0);
         %[obj,gap,v,vfull,w,yhat,p,ptrue,u,psi]=comp_model_no_v_w_scens_fixed_menu(Chat,x,q,s,yhat(:,1:sfixed*n),fscenprobs,fare,alphavals,beta,premium,mincomp,timelims,lcfgap,0);
         
         toc
     end
    %%% performance anlysis of slsf
    if guessbest==1
         [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x2.*yprobs,minitestsize,0);
         
        
      [objave2est,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,q,x2,yprobs,minitestsize,testyhat,testscenprobs);
      if guessbestmetric=='o'
        bestest(ell,t)=objave2est;
      else
          bestest(ell,t)=-rejave;
      end
      
      estslsfobjs(ell,t)=objave2est;
     end
     [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x2.*yprobs,5000,0);
       testyhat_slsf((t-1)*m+1:t*m,:)=testyhat;
        testscenprobs_slsf(t,:)=testscenprobs;
        testscenbase_slsf(t,:)=testscenbase;
        testscenexp_slsf(t,:)=testscenexp;
      [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,q,x2,yprobs,5000,testyhat,testscenprobs);
      slsfobjs(ell,t)=objave2
      slsfrejs(ell,t)=rejave
      slsfunhap(ell,t)=dupave1
      testobjs_slsf(t,:)=objvals1;
        testobjave_slsf(1,t)=objave2;
        testdupave_slsf(1,t)=dupave1;
        testrejave_slsf(1,t)=rejave;
        testv_slsf((t-1)*m+1:t*m,:)=vfull1;
        testz_slsf((t-1)*m+1:t*m,:)=zfull1;
        testw_slsf((t-1)*m+1:t*m,:)=wfull1;
        aveassign_slsf(:,(t-1)*n+1:t*n)=aveassign1;
        
      [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare]=quality_metrics(fare,slsfcomp,extradrivingtime,vfull1,wfull1)
      slsfavecomp(ell,t)=avecomp;
        slsfaveperccomp(ell,t)=aveperccomp
        slsfavetotprofit(ell,t)=avetotprofit
        slsfpercposprofit(ell,t)=percposprofit
        slsfaveextratime(ell,t)=aveextratime
        slsfaverejfare(ell,t)=averejfare
         compportion80(ell,t)=0;
         if mincomp<80
            compportionmin(ell,t)=1;
         end
     avepij(ell,t)=mean(mean(yprobs.*x2))
    pijover5(ell,t)=size(find(yprobs.*x2>=0.5),1)
    pijequal1(ell,t)=size(find(yprobs.*x2==1),1)
    menusizes(ell,t)=nnz(x2)/n

      
    runtimes(ell,t)=runtimes(ell,t)+toc;
    
        if iterative==1
          oldcomp=slsfcomp;
          

          [C,yprobs,newcomp]=generate_comp_iter(alphavals+u,oldcomp,alphavals,fare,OjOimins,extradrivingtime,drand,'c');

          oldcomp=newcomp;
            
          if iterations>1
          for k=1:iterations-1
              if guessbest==1
                  [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*ptrue,minitestsize,0);
                  [objave1est,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(Chat-u-alphavals,D,zeros(m,1),q,x,ptrue,minitestsize,testyhat,testscenprobs); 
                  if guessbestmetric=='o'
                      compareest=objave1est;
                  else
                      compareest=-rejave;
                  end
                  if compareest>bestest(ell,t)
                      if doubletest==1
                          %%% do another test to see if it's higher
                          %%% than slsf est obj
                          %testedtwice(k,t)=1;
                          %oldobj=objave1est;
                          [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*ptrue,minitestsize,0);
                           [objave1est,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(Chat-u-alphavals,D,zeros(m,1),q,x,ptrue,minitestsize,testyhat,testscenprobs); 
                            %objave1est=(objave1est+oldobj);
                            if guessbestmetric=='o'
                              compareest=objave1est;
                          else
                              compareest=-rejave;
                            end
                      end
                       if compareest>bestest(ell,t)
                              bestest(ell,t)=compareest 
                               guessbestiter(ell,t)=k
                               xbest=x;
                               ubest=u;
                               ptruebest=ptrue;
                               pbest=p;
                       else
                           %failedsecond(k,t)=1;
                        end
                  end
              end

              %%% find new menu 
              [yhat,scenprobs,newretention,scenbase,scenexp]=filter_scens(m,n,yprobs,0,0,0,1000000,'t',slsfscens);
              if noziter==0
                  tic
                    [obj2,gap2,x,v2,z2,w2]=fixed_y_prob_cplex_dot(C,D,r,5,q,yprobs,yhat,scenprobs,0,0,30,.01,0);
                  toc
              else
                  tic
                [obj2,gap2,x,v2,w2]=fixed_y_prob_cplex_dot_no_z(C,D,r,5,q,yprobs,yhat,scenprobs,0,0,30,.01,0);
                toc
              end
              
              if nnz(x2)< 2*n 
                  [yhat,scenprobs,newretention,scenbase,scenexp]=filter_scens(m,n,yprobs,0,0,0,1000000,'t',slsfscens);
                if noziter==0
                  tic
                    [obj2,gap2,x,v2,z2,w2]=fixed_y_prob_cplex_dot(C,D,r,5,q,yprobs,yhat,scenprobs,0,0,30,.01,0);
                  toc
                else
                  tic
                [obj2,gap2,x,v2,w2]=fixed_y_prob_cplex_dot_no_z(C,D,r,5,q,yprobs,yhat,scenprobs,0,0,30,.01,0);
                toc
                end
             end
            runtimes(ell,t)=runtimes(ell,t)+toc;
              oldmenu=x;

              %%% find new comps
              if fixedscens==0
                tic
                [obj,gap,v,w,yhat,p,ptrue,u,psi]=comp_model_fixed_menu(Chat,x,q,s,fare,alphavals,beta,premium,mincomp,timelims,lcfgap,0);
               %  [obj,gap,w,yhat,p,ptrue,u,psi]=comp_model_no_v_fixed_menu(Chat,x,q,s,fare,alphavals,beta,premium,mincomp,timelims,lcfgap,0);
               
                toc
              else
                  
                  if lcfscentype=='m'

                     if useslsfscens==1
                         lcfyhat=yhat(:,1:sfixed*n);
                     else
                        [lcfyhat,scenprobs,newretention,scenbase,scenexp]=filter_scens(m,n,x.*yprobs,0,0,0,1000000,'t',sfixed);
                     end

                     if equalscenwts==0
                        fscenprobs=scenprobs(1:sfixed)/sum(scenprobs(1:sfixed))*sfixed;
                     else
                         fscenprobs=ones(1,sfixed);
                     end

                 else
                     [lcfyhat,scenprobs,scenbase,scenexp]=indepy_generate_scens(x.*yprobs,sfixed,0);
                     fscenprobs=ones(1,sfixed);
                 end
               
                 tic
                 [obj,gap,v,w,yhat,p,ptrue,u,psi]=comp_model_w_scens_fixed_menu(Chat,x,q,s,lcfyhat,fscenprobs,fare,alphavals,beta,premium,mincomp,timelims,lcfgap,0);
                 %[obj,gap,v,vfull,w,yhat,p,ptrue,u,psi]=comp_model_no_v_w_scens_fixed_menu(Chat,x,q,s,yhat(:,1:sfixed*n),fscenprobs,fare,alphavals,beta,premium,mincomp,timelims,lcfgap,0);
                 toc
             end
                runtimes(ell,t)=runtimes(ell,t)+toc;
              %%% calculate new cumulative comps 
              [C,yprobs,newcomp]=generate_comp_iter(alphavals+u,oldcomp,alphavals,fare,OjOimins,extradrivingtime,drand,'c');
            
            oldcomp=newcomp;
            
          end
          end
      end
  else
        [obj,gap,x,v,w,yhat,p,ptrue,u,psi]=comp_model(Chat,5,0,q,s,fare,alphavals,beta,premium,mincomp,150,lcfgap,0);
        %[obj,gap,x,w,yhat,p,ptrue,u,psi]=comp_model_no_v(Chat,5,0,q,s,fare,alphavals,beta,premium,mincomp,150,lcfgap,0);
  end

  gaps(numtests,t)=gap
  cumcomplong(:,(t-1)*n+1:t*n)=newcomp;  
  
     %nontrivialvals(numtests,t)=nnz(ptrue.*x)-size(find(ptrue.*x>=1),1);
    
    %  %%% pefromance analys for LCF
    if guessbest==1
      [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*ptrue,minitestsize,0);
      [objave1est,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(Chat-u-alphavals,D,zeros(m,1),q,x,ptrue,minitestsize,testyhat,testscenprobs); 
      %estobjs(iterations+1,t)=objave1est
      if guessbestmetric=='o'
          compareest=objave1est;
      else
          compareest=-rejave;
      end
            if compareest>bestest(ell,t)
                if doubletest==1
                    %test again agains slsf
                    %testedtwice(iterations,t)=1;
                    %oldobj=objave1est;
                    [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*ptrue,minitestsize,0);
                    [objave1est,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(Chat-u-alphavals,D,zeros(m,1),q,x,ptrue,minitestsize,testyhat,testscenprobs); 
                    %objave1est=(objave1est+oldobj);
                    if guessbestmetric=='o'
                      compareest=objave1est;
                  else
                      compareest=-rejave;
                    end
                end
                if compareest>bestest(ell,t)
                  bestest(ell,t)=compareest 
                   guessbestiter(ell,t)=iterations
                   xbest=x;
                   ubest=u;
                   ptruebest=ptrue;
                   pbest=p;
                else
                   %failedsecond(iterations,t)=1;
                end
           end
    end

 if guessbest==1
     if guessbestiter(ell,t)==0
        returnedobjs(ell,t)=slsfobjs(ell,t)
        lcfrejs(ell,t)=slsfrejs(ell,t)
        lcfunhap(ell,t)=slsfunhap(ell,t)
             lcfavecomp(ell,t)=slsfavecomp(ell,t)
            lcfaveperccomp(ell,t)=slsfaveperccomp(ell,t)
            lcfavetotprofit(ell,t)=slsfavetotprofit(ell,t)
            lcfpercposprofit(ell,t)=slsfpercposprofit(ell,t)
            lcfaveextratime(ell,t)=slsfaveextratime(ell,t)
            lcfaverejfare(ell,t)=slsfaverejfare(ell,t)
            
     else
         if perfeveryiter==1
%              returnedobjs(ell,t)=lcfobjs(guessbestiter(ell,t),t)
%              lcfrejs(ell,t)=slsfrejs(ell,t)
%              lcfavecomp(ell,t)=slsfavecomp(ell,t)
%             lcfaveperccomp(ell,t)=slsfaveperccomp(ell,t)
%             lcfavetotprofit(ell,t)=slsfavetotprofit(ell,t)
%             lcfpercposprofit(ell,t)=slsfpercposprofit(ell,t)
%             lcfaveextratime(ell,t)=slsfaveextratime(ell,t)
%             lcfaverejfare(ell,t)=slsfaverejfare(ell,t)
         else
             nontrivialvals(ell,t)=nnz(ptruebest.*xbest)-size(find(ptruebest.*xbest>=1),1);
             xbestlong(:,(t-1)*n+1:t*n)=xbest;
            ptruebestlong(:,(t-1)*n+1:t*n)=ptruebest;
            pbestlong(:,(t-1)*n+1:t*n)=pbest;
            ubestlong(:,(t-1)*n+1:t*n)=ubest;
            
             [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(xbest.*ptruebest,min(5000,2^nontrivialvals(ell,t)),0);
             testyhat_lcf((t-1)*m+1:t*m,:)=testyhat;
            testscenprobs_lcf(t,:)=testscenprobs;
            testscenbase_lcf(t,:)=testscenbase;
            testscenexp_lcf(t,:)=testscenexp;
            
            [objave1,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull2,zfull1,wfull2]=sample_cases_performance_indepy(Chat-ubest-alphavals,D,zeros(m,1),q,xbest,ptruebest,5000,testyhat,testscenprobs); 
            returnedobjs(ell,t)=objave1
            lcfrejs(ell,t)=rejave
            lcfunhap(ell,t)=dupave1
            testobjs_lcf(t,:)=objvals1;
            testobjave_lcf(1,t)=objave1;
            testdupave_lcf(1,t)=dupave1;
            testrejave_lcf(1,t)=rejave;
            testv_lcf((t-1)*m+1:t*m,:)=vfull2;
            testz_lcf((t-1)*m+1:t*m,:)=zfull1;
            testw_lcf((t-1)*m+1:t*m,:)=wfull2;
            aveassign_lcf(:,(t-1)*n+1:t*n)=aveassign1;
            [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare]=quality_metrics(fare,ubest+alphavals,extradrivingtime,vfull2,wfull2);
          lcfavecomp(ell,t)=avecomp
            lcfaveperccomp(ell,t)=aveperccomp
            lcfavetotprofit(ell,t)=avetotprofit
            lcfpercposprofit(ell,t)=percposprofit
            lcfaveextratime(ell,t)=aveextratime
            lcfaverejfare(ell,t)=averejfare
             compportion80(ell,t)=size(find((ubest+alphavals).*xbest./fare > 0.8),1)/(nnz(xbest));
             compportionmin(ell,t)=size(find((ubest+alphavals).*xbest./fare > mincomp),1)/(nnz(xbest));
             avepij(ell,t)=mean(mean(ptruebest.*xbest))
            pijover5(ell,t)=size(find(ptruebest.*xbest>=0.5),1)
            pijequal1(ell,t)=size(find(ptruebest.*xbest==1),1)
            menusizes(ell,t)=nnz(xbest)/n
         end

    end

 end
end



%lcfsimobjs
if iterative==1
    if guessbest==1
        if cumperf==1
            lcfiterbetter=size(find(returnedobjs>slsfobjs),1)/(numtests*trials)
            lcfiterworse=size(find(returnedobjs<slsfobjs),1)/(numtests*trials)
            avepercbetter=mean(mean((returnedobjs./slsfobjs)-ones(numtests,trials)))
            lcfrejbetter=size(find(lcfrejs<slsfrejs),1)/(numtests*trials)
            lcfrejworse=size(find(lcfrejs>slsfrejs),1)/(numtests*trials)
            avepercrejbetter=mean(mean(ones(numtests,trials)-(lcfrejs./slsfrejs)))
            lcfiterave=mean(mean(returnedobjs))
            slsfave=mean(mean(slsfobjs))
            
              %avepercbetter=mean(mean(returnedobjs))/mean(mean(slsfobjs))-1              
               averuntime=mean(mean(runtimes))
                avelcfrejs=mean(mean(lcfrejs))
                 aveslsfrejs=mean(mean(slsfrejs))
                 avelcfunhap=mean(mean(lcfunhap))
                 aveslsfunhap=mean(mean(slsfunhap))
                percbetter=(returnedobjs./slsfobjs)-ones(numtests,trials)
                meanfare
                avelcfavecomp=mean(mean(lcfavecomp))
                aveslsfavecomp=mean(mean(slsfavecomp))
                avelcfaveperccomp=mean(mean(lcfaveperccomp))
                aveslsfaveperccomp=mean(mean(slsfaveperccomp))
                avelcfavetotprofit=mean(mean(lcfavetotprofit))
                aveslsfavetotprofit=mean(mean(slsfavetotprofit))
                avelcfpercposprofit=mean(mean(lcfpercposprofit))
                %aveslsfpercposprofit=mean(mean(slsfpercposprofit))
                %avelcfaveextratime=mean(mean(lcfaveextratime))
                %aveslsfaveextratime=mean(mean(lcfaveextratime))
                %avelcfaverejfare=mean(mean(lcfaverejfare))
                %aveslsfaverejfare=mean(mean(slsfaverejfare))

        end
        returnedobjs
        slsfobjs
    end
end
slsfavecomp
lcfavecomp
lcfaveperccomp

lcfavetotprofit
slsfavetotprofit
%lcfpercposprofit
%slsfpercposprofit
%lcfaveextratime
%slsfaveextratime
%lcfaverejfare
%slsfaverejfare
returnedobjs
slsfobjs
%lcfobjs

%estobjs
%lcfsimobjs
lcfrejs
slsfrejs
lcfunhap
slsfunhap
%estrejs
menusizes
avepij
pijover5
pijequal1
%iters
runtimes
%gaps
%nontrivialvals
% avelcfobj=mean(mean(returnedobjs))
% aveslsfobj=mean(mean(slsfobjs))

if iterative==1
 

    if guessbest==1       
          bestest 
           guessbestiter  
           estslsfobjs
           if doubletest==1
               testedtwice
               failedsecond
           end
    end
    %percent of offers that are above 80% or above the min offer

     compportion80 
     compportionmin
       
else
  pquants
    compquants  
end


stem= sprintf('informs_exp%s.mat',notes);

filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Paper_experiments\' stem];
save(filename,'-v7.3');