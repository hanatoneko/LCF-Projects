m=20;
n=20;
s=10;
sfixed=10;
theta=2;
mincomp=0.8
timelims=200;
lcfgap=0.1;
fmenu=1;
fscens=0;
fscenprobs=ones(1,sfixed);
numtests=20;
objs=zeros(1,numtests);
novobjs=zeros(1,numtests);
runtimes=zeros(1,numtests);
novruntimes=zeros(1,numtests);

for i=1:numtests

[Chat,C,D,r,fare,q,yprobs,alphavals,beta,buffer,Oi,Di,Oj,Dj,OjOimins,extradrivingtime,drand]=generate_params_compmodel(m,n);
 [yhat,scenprobs,newretention,scenbase,scenexp]=filter_scens(m,n,yprobs,0,0,0,1000000,'t',100);
if fmenu==1
     [yhat,scenprobs,newretention,scenbase,scenexp]=filter_scens(m,n,yprobs,0,0,0,1000000,'t',100);
     [obj2,gap2,x2,v2,z2,w2]=fixed_y_prob_cplex_dot(C,D,r,5,q,yprobs,yhat,scenprobs,0,0,30,.01,0);
    if fscens==1
          %%% no v
        tic
        [obj,gap,v,vfull,w,yhat,p,ptrue,u,psi]=comp_model_no_v_w_scens_fixed_menu(Chat,x2,q,s,yhat(:,1:sfixed*n),fscenprobs,fare,alphavals,beta,buffer,mincomp,timelims,lcfgap,0);
       toc
         novruntimes(1,i)=toc
        
        [C,yprobs,newcomp]=generate_comp_iter(alphavals+u,0.8*fare,alphavals,fare,OjOimins,extradrivingtime,drand,'c');
            
        [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*yprobs,2500,0);
        
      [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,5000,testyhat,testscenprobs);
      novobjs(1,i)=objave2
        
        %%% with v
        tic
       [obj,gap,v,w,yhat,p,ptrue,u,psi]=comp_model_w_scens_fixed_menu(Chat,x2,q,s,yhat(:,1:sfixed*n),fscenprobs,fare,alphavals,beta,buffer,mincomp,timelims,lcfgap,0);
       toc
         runtimes(1,i)=toc
        
        [C,yprobs,newcomp]=generate_comp_iter(alphavals+u,0.8*fare,alphavals,fare,OjOimins,extradrivingtime,drand,'c');
            
        [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*yprobs,2500,0);
        
      [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,5000,testyhat,testscenprobs);
      objs(1,i)=objave2
      
    else
          %%% no v
        tic
        [obj,gap,w,yhat,p,ptrue,u,psi]=comp_model_no_v_fixed_menu(Chat,x2,q,s,fare,alphavals,beta,buffer,mincomp,timelims,lcfgap,0);
        toc
         novruntimes(1,i)=toc
        
        [C,yprobs,newcomp]=generate_comp_iter(alphavals+u,0.8*fare,alphavals,fare,OjOimins,extradrivingtime,drand,'c');
            
        [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*yprobs,2500,0);
        
      [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,5000,testyhat,testscenprobs);
      novobjs(1,i)=objave2
        
        %%% with v
        tic
        [obj,gap,v,w,yhat,p,ptrue,u,psi]=comp_model_fixed_menu(Chat,x2,q,s,fare,alphavals,beta,buffer,mincomp,timelims,lcfgap,0);
        toc
         runtimes(1,i)=toc
        
        [C,yprobs,newcomp]=generate_comp_iter(alphavals+u,0.8*fare,alphavals,fare,OjOimins,extradrivingtime,drand,'c');
            
        [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*yprobs,2500,0);
        
      [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,5000,testyhat,testscenprobs);
      objs(1,i)=objave2

    end
else
    if fscens==1
        
         %%% no v
        tic
        [obj,gap,x,v,w,y,p,ptrue,u,psi]=comp_model_no_v_w_scens(Chat,5,0,q,s,yhat(:,1:sfixed*n),ones(1,sfixed),fare,alphavals,beta,buffer,mincomp,timelims,lcfgap,0)
         toc
         novruntimes(1,i)=toc
        
        [C,yprobs,newcomp]=generate_comp_iter(alphavals+u,0.8*fare,alphavals,fare,OjOimins,extradrivingtime,drand,'c');
            
        [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*yprobs,2500,0);
        
      [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,5000,testyhat,testscenprobs);
      novobjs(1,i)=objave2
        
        %%% with v
        tic
        [obj,gap,x,v,w,y,p,ptrue,u,psi]=comp_model_w_scens(Chat,5,0,q,s,yhat(:,1:sfixed*n),fare,alphavals,beta,buffer,mincomp,timelims,lcfgap,0)
        toc
         runtimes(1,i)=toc
        
        [C,yprobs,newcomp]=generate_comp_iter(alphavals+u,0.8*fare,alphavals,fare,OjOimins,extradrivingtime,drand,'c');
            
        [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*yprobs,2500,0);
        
      [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,5000,testyhat,testscenprobs);
      objs(1,i)=objave2
    else
        %solve and analyze nov
        tic
        [obj,gap,x,w,y,p,ptrue,u,psi]=comp_model_no_v(Chat,theta,0,q,s,fare,alphavals,beta,buffer,mincomp,timelims,lcfgap,0);
        toc
        novruntimes(1,i)=toc
        [C,yprobs,newcomp]=generate_comp_iter(alphavals+u,0.8*fare,alphavals,fare,OjOimins,extradrivingtime,drand,'c');
            
        [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*yprobs,2500,0);
        
      [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,5000,testyhat,testscenprobs);
      novobjs(1,i)=objave2
      
      %solve and analyze w/v
        tic
        [obj,gap,x,v,w,y,p,ptrue,u,psi]=comp_model(Chat,theta,0,q,s,fare,alphavals,beta,buffer,mincomp,timelims,lcfgap,0);
        toc
        runtimes(1,i)=toc
        
        [C,yprobs,newcomp]=generate_comp_iter(alphavals+u,0.8*fare,alphavals,fare,OjOimins,extradrivingtime,drand,'c');
            
        [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*yprobs,2500,0);
        
      [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,5000,testyhat,testscenprobs);
      objs(1,i)=objave2
    end
end
end
    
mean(objs)
mean(novobjs)
mean(runtimes)
mean(novruntimes)
objs
novobjs
runtimes
novruntimes
        
        
