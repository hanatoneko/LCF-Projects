
m=20;
n=20;
s=10;
sfixed=10;
mincomp=0.8;
slsfperc=0.8
premium=0.75*ones(m,n);
trials=5;
test=0;
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio129\cplex\matlab\x64_win64'));
%timelims=[60,150,200,300,500];
timelims=200;
sampsizes=[5,10,20,50,80,100,150];
lcfgap=0.05;
numtests=10;
fixedmenu=1;
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
regression=0;
if iterative==1
    iterations=7;
    randiters=0;
    perfeveryiter=1;
    runtimes=zeros(numtests,trials);
    %numtests=iterations;
    if guessbest==1
        guessbestiter=zeros(numtests,trials);
        bestest=zeros(numtests,trials);
        
        returnedobjs=zeros(numtests,trials);
        %estobjs=zeros(iterations+1,trials);
        minitestsize=400;
        doubletest=0; 
        xbest=zeros(m,n);
        ubest=zeros(m,n);
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

for ell=1:numtests
for t=1:trials

    [Chat,C,D,r,fare,q,yprobs,slsfcomp,alphavals,beta,Oi,Di,Oj,Dj,OjOimins,extradrivingtime,drand]=generate_params_compmodel(m,n,slsfperc);
    meanfare(ell,t)=mean(mean(fare))
    if randiters==1
        iterations=randi([1 7],1,1);
       iters(ell,t)=iterations;
    end


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
      [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,q,x2,yprobs,5000,testyhat,testscenprobs);
      slsfobjs(ell,t)=objave2
      slsfrejs(ell,t)=rejave
      slsfunhap(ell,t)=dupave1
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
                       else
                           %failedsecond(k,t)=1;
                        end
                  end
              end
%               if perfeveryiter==1
%                   lcfsimobjs(k,t)=obj
%                   %percent of offers that are above 80% or above the min offer
%                     compportion80(k,t)=size(find(newcomp./fare > 0.8),1)/(m*n);
%                      compportionmin(k,t)=size(find(newcomp./fare > mincomp),1)/(m*n);
%                   %%% performance analysis of iteration
%                    nontrivialvals(k,t)=nnz(ptrue.*x)-size(find(ptrue.*x>=1),1);
% 
%                   %nontrivialvals(k,t)=nnz(ptrue.*x)-size(find(ptrue.*x>=1),1);
%                    if 2^nontrivialvals(k,t)<5000
%                         [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*ptrue,'all',0);
%                     else
%                         [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*ptrue,5000,0);
%                     end
%                  [objave1,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(Chat-u-alphavals,D,zeros(m,1),q,x,ptrue,min(5000,2^nontrivialvals(1,t)),testyhat,testscenprobs); 
% 
%                  lcfobjs(k,t)=objave1
%                  lcfrejs(k,t)=rejave
%                   gaps(k,t)=gap
%                   menusizes(k,t)=nnz(x)/n
%               end


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

% [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*ptrue,smoltestsize,0);
% [objave1est,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(Chat-u-alphavals,D,zeros(m,1),q,x,ptrue,min(smoltestsize,2^nontrivialvals(1,t)),testyhat,testscenprobs); 
% estobjs(ell,t)=objave1est 
% estrejs(ell,t)=rejave


%     %%% filtering solution
    vsum=zeros(m,n);
    for scen=1:s
        vsum=vsum+v(:,(scen-1)*n+1:scen*n);
    end
    ysum=zeros(m,n);
    for scen=1:s
        ysum=ysum+yhat(:,(scen-1)*n+1:scen*n);
    end
%     xfiltered=x;
%     ufiltered=u;
%     xfiltered(x.*vsum==0)=zeros(size(x(x.*vsum==0)));
%     ufiltered(vsum==0)=zeros(size(u(vsum==0)));
      %%% calculate metrics
 %    menusizes(numtests,t)=nnz(x)/n
     %%%%% metric recording for regression 
     %percent of offers that are above 80% or above the min offer
   
    
    
     if iterative==0
          compportion80(ell,t)=size(find(newcomp./fare > 0.8),1)/(m*n);
         compportionmin(ell,t)=size(find(newcomp./fare > mincomp),1)/(m*n);
         avepij(ell,t)=mean(mean(yprobs))
        pijover5(ell,t)=size(find(yprobs>=0.5),1)
        pijequal1(ell,t)=size(find(yprobs==1),1)
        menusizes(ell,t)=nnz(x)/n
             plong=p(:).*x(:);
         plong(plong>(1/0.5+0.1))=zeros(size(plong(plong>1/0.5+0.1))); 
         pquants(t,1)=min(plong(plong>0));
          pquants(t,5)=max(plong(plong>0));
         pquants(t,2:4)=quantile(plong(plong>0),[0.25, 0.5, 0.75])'
         comp=(u.*x+alphavals.*x)./fare; 
         complong=comp(:); 
         compquants(t,1)=min(complong(complong>0));
          compquants(t,5)=max(complong(complong>0));
         compquants(t,2:4)=quantile(complong(complong>0),[0.25, 0.5, 0.75])'
     end
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
             [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(xbest.*ptruebest,min(5000,2^nontrivialvals(ell,t)),0);
            [objave1,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull2,zfull1,wfull2]=sample_cases_performance_indepy(Chat-ubest-alphavals,D,zeros(m,1),q,xbest,ptruebest,5000,testyhat,testscenprobs); 
            returnedobjs(ell,t)=objave1
            lcfrejs(ell,t)=rejave
            lcfunhap(ell,t)=dupave1
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
    %plot performance of each iteration
    if perfeveryiter==1
        red=[0.6350 0.0780 0.1840];
        orange=[0.8500 0.3250 0.0980];
        yellow=[0.9290 0.6940 0.1250];
        green=[0.4660 0.6740 0.1880];
        blue=[0 0.4470 0.7410];
        purple=[0.4940 0.1840 0.5560];
        colors=[purple;blue;green;yellow;orange;red];
        symbols=['-^ ';':o ';'--+';'-x ';'-.d';'--v']; 
        if guessbest==1
           for t=1:trials
            plot(1:iterations,lcfobjs(:,t),symbols(t,:),'color',colors(7-t,:),'LineWidth',1);
            hold on
            alpha 0.5
            plot(1:iterations,slsfobjs(1,t)*ones(iterations,1),symbols(t,:),'color',colors(7-t,:),'LineWidth',1);
            hold on
            plot(1:iterations,returnedobjs(1,t)*ones(iterations,1),symbols(t,:),'color',colors(7-t,:),'LineWidth',2);
            hold on
            alpha 1

           end
        else
            for t=1:trials
            plot(1:iterations,lcfobjs(:,t),symbols(t,:),'color',colors(7-t,:),'LineWidth',2);
            hold on
            alpha 0.5
            plot(1:iterations,slsfobjs(1,t)*ones(iterations,1),symbols(t,:),'color',colors(7-t,:),'LineWidth',1);
            hold on
            alpha 1

           end
        end


        ylabel("Objective Value")
        if trials==5
            if guessbest==1
                lg=legend('LCF T1','SLSF T1','Best T1','LCF T2','SLSF T2','Best T2','LCF T3','SLSF T3','Best T3','LCF T4','SLSF T4','Best T4','LCF T5','SLSF T5','Best T5');
            else
               lg=legend('LCF T1','SLSF T1','LCF T2','SLSF T2','LCF T3','SLSF T3','LCF T4','SLSF T4','LCF T5','SLSF T5');

            end
        end
        lg.Location='southeast';
          xlabel('Iteration')
         title('Objectve Value Estimate of Iteration')
    end
    %     tic
%     [b,bint,r] = regress(lcfobjs(:),metricdata)
%     toc
 %   regruntime=toc
 if regression==1
     metricdata=horzcat(estobjs(:),lcfsimobjs(:),estrejs(:),menusizes(:),avepij(:),pijover5(:),pijequal1(:),nontrivialvals(:),compportion80(:),compportionmin(:),iters(:));

        b =[    0.9406
        0.1286
        2.0104
       14.0556
     -125.8487
        0.4955
       -0.4088
       -0.6260
        6.4026
      -41.7502
       -0.6146];
    r=metricdata*b-lcfobjs(:);
        totregerr=sum(abs(r))
        estobjerr=sum(sum(abs(estobjs-lcfobjs)))

        maxval=ceil(max(max(horzcat(lcfobjs(:),metricdata*b))));
        minval=floor(min(min(horzcat(lcfobjs(:),metricdata*b))));

        plot(minval:maxval,minval:maxval,'LineWidth',2);
        hold on
        scatter(metricdata*b,lcfobjs(:))
        title('Regression Fit Quality')
        xlabel('metricdata*weights')
        ylabel('Test Objective')
 end
    
    
else
  pquants
    compquants  
end




% lcfiterbetter=size(find(returnedobjs(1:5,:)>slsfobjs(1:5,:)),1)/(5*trials)
%             lcfiterworse=size(find(returnedobjs<slsfobjs),1)/(5*trials)
%             lcfiterave=mean(mean(returnedobjs(1:5,:)))
%             slsfave=mean(mean(slsfobjs(1:5,:)))
%               avepercbetter=mean(mean(returnedobjs))/mean(mean(slsfobjs))-1
%                 avepercbetter=mean(mean((returnedobjs(1:5,:)./slsfobjs(1:5,:))-ones(5,trials)))
%                 averuntime=mean(mean(runtimes(1:5,:)))
%                 avelcfrejs=mean(mean(lcfrejs(1:5,:)))
%                  aveslsfrejs=mean(mean(slsfrejs(1:5,:)))
%                 percbetter=(returnedobjs(1:5,:)./slsfobjs(1:5,:))-ones(5,trials)