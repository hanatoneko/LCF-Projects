m=20;
n=20;
s=10;
mincomp=0.6
trials=5;
test=0;
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio129\cplex\matlab\x64_win64'));
%timelims=[60,150,200,300,500];
timelims=30;

slsfobjs=zeros(1,trials);
slsfrandscenobjs=zeros(1,trials);
lcfobjs=zeros(1,trials);
randobjs=zeros(1,trials);
top5objs=zeros(1,trials);
top1wtobjs=zeros(1,trials);
top1wtnontrivials=zeros(1,trials);
closest5wtobjs=zeros(1,trials);
closest5wtnontrivials=zeros(1,trials);
closest1wtobjs=zeros(1,trials);
closest1wtnontrivials=zeros(1,trials);
for t=1:trials
    
    [Chat,C,D,r,fare,q,yprobs,alphavals,beta,buffer,Oi,Di,Oj,Dj,OjOimins,extradrivingtime,drand]=generate_params_compmodel(m,n);




     %%% solve slsf and performance analysis
     [yhat,scenprobs,newretention,scenbase,scenexp]=filter_scens(m,n,yprobs,0,0,0,1000000,'t',100);
     [obj2,gap2,x2,v2,z2,w2]=fixed_y_prob_cplex_dot(C,D,r,5,q,yprobs,yhat,scenprobs,0,0,100,.01,0);
    [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x2.*yprobs,5000,0);
      [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,q,x2,yprobs,5000,testyhat,testscenprobs);
      slsfobjs(1,t)=objave2
      
       %%% solve slsf with random equally weighted scens and performance analysis
     [yhat,scenprobs,scenbase,scenexp]=indepy_generate_scens(yprobs,100,0);
     [obj2,gap2,x2,v2,z2,w2]=fixed_y_prob_cplex_dot(C,D,r,5,q,yprobs,yhat,ones(1,100),0,0,100,.01,0);
    [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x2.*yprobs,5000,0);
      [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,q,x2,yprobs,5000,testyhat,testscenprobs);
      slsfrandscenobjs(1,t)=objave2
      
      
      
%       %%% solve lcf fixed menu and perf analysis
%     x=x2;
%         [obj,gap,v,w,yhat,p,ptrue,u,psi]=comp_model_fixed_menu(Chat,x,q,s,fare,alphavals,beta,buffer,mincomp,150,.1,0);
%          [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*ptrue,5000,0);
%      [objave1,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(Chat-u-alphavals,D,zeros(m,1),q,x,ptrue,min(5000,2^nontrivialvals(1,t)),testyhat,testscenprobs);    
%      lcfobjs(1,t)=objave1
%      
% %      %%% calculate random menu & perf analysis
% %      x3=zeros(m,n);
% %      for j=1:n
% %          menu=randperm(m,5);
% %          x3(menu,j)=ones(5,1);
% %      end
% %          
% %      [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x3.*yprobs,5000,0);
% %       [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,q,x3,yprobs,5000,testyhat,testscenprobs);
% %       randobjs(1,t)=objave2
% 
% 
%       
% %       %%% calculate top 5 menu & perf analysis
% %       x4=zeros(m,n);
% %       for j=1:n
% %          [B,menu]=maxk(yprobs(:,j),5);
% %          x4(menu,j)=ones(5,1);    
% %       end
% %       
% %       [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x4.*yprobs,5000,0);
% %       [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,q,x4,yprobs,5000,testyhat,testscenprobs);
% %       top5objs(1,t)=objave2
%       
% 
% 
%         %%% calculate top 1 menu (max weight) & perf analysis
% 
%        [obj,x5]=max_weight_menu(yprobs,1)
%        top1wtnontrivials(1,t)=nnz(yprobs.*x5)-size(find(yprobs.*x5>=1),1)
%       [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x5.*yprobs,min(5000,top1wtnontrivials(1,t)),0);
%       [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,q,x5,yprobs,min(5000,top1wtnontrivials(1,t)),testyhat,testscenprobs);
%       top1wtobjs(1,t)=objave2
%       
%       %%% calculate closest 5 menu & perf analysis (in terms of driver
%       %%% origin distance from rider origin
%       
% 
%         [obj,x6]=max_weight_menu(-OjOimins,5)
%        closest5wtnontrivials(1,t)=nnz(yprobs.*x6)-size(find(yprobs.*x6>=1),1)
%       [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x6.*yprobs,min(5000,closest5wtnontrivials(1,t)),0);
%       [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,q,x6,yprobs,min(5000,closest5wtnontrivials(1,t)),testyhat,testscenprobs);
%       closest5wtobjs(1,t)=objave2
%       
%        %%% calculate closest1 menu & perf analysis
%       
%       [obj,x7]=max_weight_menu(-OjOimins,1);
%       closest1wtnontrivials(1,t)=nnz(yprobs.*x7)-size(find(yprobs.*x7>=1),1)
%       [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x7.*yprobs,min(5000,closest1wtnontrivials(1,t)),0);
%       [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,q,x7,yprobs,min(5000,closest1wtnontrivials(1,t)),testyhat,testscenprobs);
%       closest1wtobjs(1,t)=objave2
      
      
end
     
slsfobjs
lcfobjs
randobjs
top5objs
top1wtobjs
top1wtnontrivials
closest5wtobjs
closest1wtobjs
closest1wtnontrivials
