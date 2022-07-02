m=20;
n=20;
s=10;
sfixed=10;
mincomp=0.8;
slsfcomp=0.8;
trials=5;
test=0;
lcfgap=0.01;
premium=0.75*ones(m,n);
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio129\cplex\matlab\x64_win64'));
%timelims=[60,150,200,300,500];
timelims=200;
sampsizes=[5,10,20,50,80,100,150];
if test=='t'
    numtests=size(timelims,2);
elseif test=='s'
    numtests=size(sampsizes,2);
elseif test==0
    numtests=1;
end
fixedmenu=1;
iterative=1;
guessbest=1;
perfeveryiter=1; %%%%%%%%% MUST =1 for this program
fixedscens=1;
useslsfscens=0;
equalscenwts=1;
cumperf=1;
guessbestmetric='r';
if iterative==1
    iterations=7;
    menudiffs=zeros(iterations-1,trials);
    cumcompdiffs=zeros(iterations,trials);
    numtests=iterations;
    if guessbest==1
        guessbestiter=zeros(1,trials);
        bestest=zeros(1,trials);
        returnedobjs=zeros(1,trials);
        estobjs=zeros(iterations+1,trials);
        minitestsize=200;
        doubletest=1; 
        if doubletest==1
            failedsecond=zeros(iterations,trials);
            testedtwice=zeros(iterations,trials);
        end
        
    end
   
end
lcfsimobjs=zeros(numtests,trials);
lcfobjs=zeros(numtests,trials);
slsfobjs=zeros(1,trials);
lcfrejs=zeros(numtests,trials);
slsfrejs=zeros(1,trials);
menusizes=zeros(numtests,trials);
gaps=zeros(numtests,trials);
runtimes=zeros(numtests,trials);
slsfavecomp=zeros(numtests,trials);
slsfaveperccomp=zeros(numtests,trials);
slsfavetotprofit=zeros(numtests,trials);
slsfpercposprofit=zeros(numtests,trials);
slsfaveextratime=zeros(numtests,trials);
lcfavecomp=zeros(numtests,trials);
lcfaveperccomp=zeros(numtests,trials);
lcfavetotprofit=zeros(numtests,trials);
lcfpercposprofit=zeros(numtests,trials);
lcfaveextratime=zeros(numtests,trials);
pquants=zeros(trials,5);
compquants=zeros(trials,5);
nontrivialvals=zeros(numtests,trials);
compportion80=zeros(numtests,trials);
compportionmin=zeros(numtests,trials);



if test==0
    for t=1:trials

        [Chat,C,D,r,fare,q,yprobs,alphavals,beta,Oi,Di,Oj,Dj,OjOimins,extradrivingtime,drand]=generate_params_compmodel(m,n,slsfcomp);
  



     %%% solve slsf and performance analysis
     [yhat,scenprobs,newretention,scenbase,scenexp]=filter_scens(m,n,yprobs,0,0,0,1000000,'t',100);
     tic
     [obj2,gap2,x2,v2,z2,w2]=fixed_y_prob_cplex_dot(C,D,r,5,q,yprobs,yhat,scenprobs,0,0,30,.01,0);
     toc
     
     if guessbest==1
         [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x2.*yprobs,minitestsize,0);
      [objave2est,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,q,x2,yprobs,minitestsize,testyhat,testscenprobs);
            if guessbestmetric=='o'
            bestest(1,t)=objave2est;
          else
              bestest(1,t)=-rejave;
          end
      estobjs(1,t)=objave2est;
     end
      
      
    
      [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x2.*yprobs,5000,0);
      [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,q,x2,yprobs,5000,testyhat,testscenprobs);
      slsfobjs(1,t)=objave2
      slsfrejs(1,t)=rejave
        [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare]=quality_metrics(fare,slsfcomp*fare,extradrivingtime,vfull1,wfull1)
        slsfavecomp(1,t)=avecomp;
        slsfaveperccomp(1,t)=aveperccomp;
        slsfavetotprofit(1,t)=avetotprofit;
        slsfpercposprofit(1,t)=percposprofit;
        slsfaveextratime(1,t)=aveextratime;

      %%% solve compensation model plus analysis
      if fixedmenu==1
        runtimes(1,t)=toc;
        x=x2;
        if fixedscens==0
            tic
            [obj,gap,v,w,yhat,p,ptrue,u,psi]=comp_model_fixed_menu(Chat,x,q,s,fare,alphavals,beta,premium,mincomp,150,.1,0);
            toc
        else
            if useslsfscens==0
                 lcfyhat=yhat(:,1:sfixed*n);
             else
                 [lcfyhat,scenprobs,newretention,scenbase,scenexp]=filter_scens(m,n,yprobs,0,0,0,1000000,'t',sfixed);
             end
             if equalscenwts==0
                    fscenprobs=scenprobs(1:sfixed)/sum(scenprobs(1:sfixed))*sfixed;
             else
                 fscenprobs=ones(1,sfixed);
             end
         tic
            [obj,gap,v,w,yhat,p,ptrue,u,psi]=comp_model_w_scens_fixed_menu(Chat,x,q,s,lcfyhat,fscenprobs,fare,alphavals,beta,premium,mincomp,timelims,lcfgap,0);
        toc
           
        end
          runtimes(1,t)=runtimes(1,t)+toc;
            if iterative==1
              oldcomp=0.8*fare;
              oldmenu=x2;
              
              [C,yprobs,newcomp]=generate_comp_iter(alphavals+u,oldcomp,alphavals,fare,OjOimins,extradrivingtime,drand,'c');
              cumcompdiffs(1,t)=nnz(newcomp-0.8*fare);
              oldcomp=newcomp;
              
              for k=1:iterations-1
                  %small performance anlysis
                  if guessbest==1
                      [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*ptrue,minitestsize,0);
                      [objave1est,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(Chat-u-alphavals,D,zeros(m,1),q,x,ptrue,min(minitestsize,2^nontrivialvals(1,t)),testyhat,testscenprobs); 
                      estobjs(k+1,t)=objave1est 
                      if guessbestmetric=='o'
                          compareest=objave1est;
                      else
                          compareest=-rejave;
                      end
                      if compareest>bestest(1,t)
                          if doubletest==1
                              %%% do another test to see if it's higher
                              %%% than slsf est obj
                              testedtwice(k,t)=1;
                              [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*ptrue,minitestsize,0);
                               [objave1est,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(Chat-u-alphavals,D,zeros(m,1),q,x,ptrue,min(minitestsize,2^nontrivialvals(1,t)),testyhat,testscenprobs); 
                                if guessbestmetric=='o'
                                      compareest=objave1est;
                                  else
                                      compareest=-rejave;
                                end

                           end
                           if compareest>bestest(1,t)
                                      bestest(1,t)=compareest 
                                       guessbestiter(1,t)=k
                               else
                                   failedsecond(k,t)=1;
                              end
                       end
                  end
                  if perfeveryiter==1
                      lcfsimobjs(k,t)=obj
                      %percent of offers that are above 80% or above the min offer
                        compportion80(k,t)=size(find(newcomp./fare > 0.8),1)/(m*n);
                         compportionmin(k,t)=size(find(newcomp./fare > mincomp),1)/(m*n);
                      %%% 5000 performance analysis of iteration
                      
                      
                      nontrivialvals(k,t)=nnz(ptrue.*x)-size(find(ptrue.*x>=1),1);
                       if 2^nontrivialvals(k,t)<5000
                            [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*ptrue,'all',0);
                        else
                            [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*ptrue,5000,0);
                        end
                     [objave1,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(Chat-u-alphavals,D,zeros(m,1),q,x,ptrue,min(5000,2^nontrivialvals(1,t)),testyhat,testscenprobs); 

                     lcfobjs(k,t)=objave1
                     lcfrejs(k,t)=rejave
                      gaps(k,t)=gap
                      menusizes(k,t)=nnz(x)/n
                      [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare]=quality_metrics(fare,u+alphavals,extradrivingtime,vfull1,wfull1)
                  lcfavecomp(k,t)=avecomp;
                    lcfaveperccomp(k,t)=aveperccomp;
                    lcfavetotprofit(k,t)=avetotprofit;
                    lcfpercposprofit(k,t)=percposprofit;
                    lcfaveextratime(k,t)=aveextratime;
                  end
                 
                  
                  %%% find new menu 
                  [yhat,scenprobs,newretention,scenbase,scenexp]=filter_scens(m,n,yprobs,0,0,0,1000000,'t',100);
                  tic
                    [obj2,gap2,x,v2,z2,w2]=fixed_y_prob_cplex_dot(C,D,r,5,q,yprobs,yhat,scenprobs,0,0,30,.01,0);
                    toc
                    runtimes(1,t)=runtimes(1,t)+toc;
                  menudiffs(k,t)=nnz(x-oldmenu);
                  oldmenu=x;
                  
                  %%% find new comps
                  if fixedscens==0
                      tic
                        [obj,gap,v,w,yhat,p,ptrue,u,psi]=comp_model_fixed_menu(Chat,x,q,s,fare,alphavals,beta,premium,mincomp,30,.1,0);
                        toc
                  else
                       if useslsfscens==0
                             lcfyhat=yhat(:,1:sfixed*n);
                         else
                             [lcfyhat,scenprobs,newretention,scenbase,scenexp]=filter_scens(m,n,yprobs,0,0,0,1000000,'t',sfixed);
                         end
                         if equalscenwts==0
                                fscenprobs=scenprobs(1:sfixed)/sum(scenprobs(1:sfixed))*sfixed;
                         else
                             fscenprobs=ones(1,sfixed);
                         end
                         tic
                            [obj,gap,v,w,yhat,p,ptrue,u,psi]=comp_model_w_scens_fixed_menu(Chat,x,q,s,lcfyhat,fscenprobs,fare,alphavals,beta,premium,mincomp,timelims,lcfgap,0);
                        toc
                  end
                  runtimes(1,t)=runtimes(1,t)+toc;
                  %%% calculate new cumulative comps 
                  [C,yprobs,newcomp]=generate_comp_iter(alphavals+u,oldcomp,alphavals,fare,OjOimins,extradrivingtime,drand,'c');
                cumcompdiffs(k+1,t)=nnz(newcomp-0.8*fare);
                oldcomp=newcomp;
              end
          end
      else
          if fixedscens==0
              tic
            [obj,gap,x,v,w,yhat,p,ptrue,u,psi]=comp_model(Chat,5,0,q,s,fare,alphavals,beta,premium,mincomp,timelims,.1,0);
            toc
            runtimes(1,t)=toc;
          else
              tic
              [obj,gap,x,v,w,yhat,p,ptrue,u,psi]=comp_model_w_scens(Chat,5,0,q,s,yhat(:,1:sfixed*n),fare,alphavals,beta,ones(m,n),mincomp,timelims,.1,0);
              toc
              runtimes(1,t)=toc;
          end
      end
      gaps(numtests,t)=gap

      
      
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
         menusizes(numtests,t)=nnz(x)/n
         if iterative==0
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
         nontrivialvals(numtests,t)=nnz(ptrue.*x)-size(find(ptrue.*x>=1),1);

        %  %%% pefromance analys for LCF
        if guessbest==1
          [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*ptrue,minitestsize,0);
          [objave1est,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(Chat-u-alphavals,D,zeros(m,1),q,x,ptrue,min(minitestsize,2^nontrivialvals(1,t)),testyhat,testscenprobs); 
          estobjs(iterations+1,t)=objave1est
            if guessbestmetric=='o'
                  compareest=objave1est;
              else
                  compareest=-rejave;
              end
              if compareest>bestest(1,t)
                  if doubletest==1
                      %%% do another test to see if it's higher
                      %%% than slsf est obj
                      testedtwice(iterations,t)=1;
                      [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*ptrue,minitestsize,0);
                       [objave1est,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(Chat-u-alphavals,D,zeros(m,1),q,x,ptrue,min(minitestsize,2^nontrivialvals(1,t)),testyhat,testscenprobs); 
                        if guessbestmetric=='o'
                              compareest=objave1est;
                          else
                              compareest=-rejave;
                        end
                      
                  end
                if compareest>bestest(1,t)
                              bestest(1,t)=compareest 
                               guessbestiter(1,t)=iterations
                       else
                           failedsecond(iterations,t)=1;
                      end
               end
               
        end
        if perfeveryiter==1
            if 2^nontrivialvals(numtests,t)<5000
                [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*ptrue,'all',0);
            else
                [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*ptrue,5000,0);
            end
             [objave1,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(Chat-u-alphavals,D,zeros(m,1),q,x,ptrue,min(5000,2^nontrivialvals(1,t)),testyhat,testscenprobs); 

             lcfobjs(numtests,t)=objave1
             lcfrejs(numtests,t)=rejave
             lcfsimobjs(numtests,t)=obj
           [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare]=quality_metrics(fare,u+alphavals,extradrivingtime,vfull1,wfull1)
          lcfavecomp(numtests,t)=avecomp;
            lcfaveperccomp(numtests,t)=aveperccomp;
            lcfavetotprofit(numtests,t)=avetotprofit;
            lcfpercposprofit(numtests,t)=percposprofit;
            lcfaveextratime(numtests,t)=aveextratime;
            
        else
            
        end
     if iterative==1
        compportion80(numtests,t)=size(find(newcomp./fare > 0.8),1)/(m*n);
        compportionmin(numtests,t)=size(find(newcomp./fare > mincomp),1)/(m*n);
     end
     if guessbest==1
         if guessbestiter(1,t)==0
            returnedobjs(1,t)=slsfobjs(1,t)
            returnedrejs(1,t)=slsfrejs(1,t)
         else
            returnedobjs(1,t)=lcfobjs(guessbestiter(1,t),t)
            returnedrejs(1,t)=lcfrejs(guessbestiter(1,t),t)
           
        end

     end
    end
    
    %lcfsimobjs
    if iterative==1
        if guessbest==1
            returnedobjs
        end
    end
    avelcfobj=mean(lcfobjs)
    aveslsfobj=mean(slsfobjs)
    averuntimes=mean(runtimes)
    lcfobjs
    returnedrejs
    slsfobjs
    lcfrejs
    returnedrejs
    slsfrejs
    lcfavecomp
slsfavecomp
lcfaveperccomp
slsfaveperccomp
lcfavetotprofit
slsfavetotprofit
lcfpercposprofit
slsfpercposprofit
lcfaveextratime
slsfaveextratime
    menusizes
    %gaps
    %nontrivialvals
    
    if iterative==1
        menudiffs
        cumcompdiffs
        
        if guessbest==1       
              bestest 
               guessbestiter  
               estobjs
               if doubletest==1
                   testedtwice
                   failedsecond
               end
        end
        %percent of offers that are above 80% or above the min offer
         runtimes     
         compportion80 
         compportionmin
        %plot performance of each iteration
        red=[0.6350 0.0780 0.1840];
        orange=[0.8500 0.3250 0.0980];
        yellow=[0.9290 0.6940 0.1250];
        green=[0.4660 0.6740 0.1880];
        blue=[0 0.4470 0.7410];
        purple=[0.4940 0.1840 0.5560];
        colors=[purple;blue;green;yellow;orange;red];
        symbols=['-^ ';':o ';'--+';'-x ';'-.d';'--v']; 
        if guessbest==1
            if guessbestmetric=='o'
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
                plot(1:iterations,lcfrejs(:,t),symbols(t,:),'color',colors(7-t,:),'LineWidth',1);
                hold on
                alpha 0.5
                plot(1:iterations,slsfrejs(1,t)*ones(iterations,1),symbols(t,:),'color',colors(7-t,:),'LineWidth',1);
                hold on
                plot(1:iterations,returnedrejs(1,t)*ones(iterations,1),symbols(t,:),'color',colors(7-t,:),'LineWidth',2);
                hold on
                alpha 1
               end  
                
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
            
    else
      pquants
        compquants  
    end
   
    
else
    
    
    for t=1:trials
     [Chat,C,D,r,fare,q,yprobs,alphavals,beta,Oi,Di,Oj,Dj,OjOimins,extradrivingtime,drand]=generate_params_compmodel(m,n);

     
     %%% solve slsf and performance analysis
     [yhat,scenprobs,newretention,scenbase,scenexp]=filter_scens(m,n,yprobs,0,0,0,1000000,'t',s);
     [obj2,gap2,x2,v2,z2,w2]=fixed_y_prob_cplex_dot(C,D,r,5,q,yprobs,yhat,scenprobs,0,0,500,.01,0);
      [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x2.*yprobs,5000,0);
      [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,q,x2,yprobs,5000,testyhat,testscenprobs);
      slsfobjs(1,t)=objave2
      slsfrejs(1,t)=rejave
     for i=1:numtests
         %%% solve compensation model plus analysis
          if fixedmenu==1
            x=x2;
             if test=='t' 
              [obj,gap,v,w,yhat,p,ptrue,u,psi]=comp_model_fixed_menu(Chat,x,q,s,fare,alphavals,beta,premium,mincomp,timelims(1,i),.1,0);
             elseif test=='s'
                 tic
                 [obj,gap,v,w,yhat,p,ptrue,u,psi]=comp_model_fixed_menu(Chat,x,q,sampsizes(1,i),fare,alphavals,beta,premium,mincomp,timelims(1,1),.1,0);
                toc
                runtimes(i,t)=toc
             end
          else
              if test=='t'
              [obj,gap,x,v,w,yhat,p,ptrue,u,psi]=comp_model(Chat,5,0,q,s,fare,alphavals,beta,premium,mincomp,timelims(1,i),.1,0);
              elseif test=='s'
                  tic
                 [obj,gap,x,v,w,yhat,p,ptrue,u,psi]=comp_model(Chat,5,0,q,sampsizes(1,i),fare,alphavals,beta,premium,mincomp,timelims(1,1),.1,0);
                  toc
                  runtimes(i,t)=toc
              end 
          end

            gaps(i,t)=gap


             menusizes(i,t)=nnz(x)/n
             nontrivialvals(i,t)=nnz(ptrue.*x)-size(find(ptrue.*x>=1),1);

            %  %%% pefromance analys for LCF
            if obj==0
                lcfrejs(i,t)=20
                continue
            else
                if 2^nontrivialvals(i,t)<5000
                    [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*ptrue,'all',0);
                else
                    [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*ptrue,5000,0);
                end
             [objave1,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(Chat-u-alphavals,D,zeros(m,1),q,x,ptrue,min(5000,2^nontrivialvals(1,t)),testyhat,testscenprobs);
             lcfobjs(i,t)=objave1
             lcfrejs(i,t)=rejave
            end
     end


    end
    if test=='t'
        timelims
    elseif test=='s'
        sampsizes
        runtimes
    end
    lcfobjs
   slsfobjs
    lcf_sub_slsf=lcfobjs-repmat(slsfobjs,numtests,1)
    lcfrejs
    slsfrejs
    menusizes
    gaps


    lcfobjaves=mean(lcfobjs,2)
end
