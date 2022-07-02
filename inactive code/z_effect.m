function[simobjs,testobjs,times,xdiffs,menuave,menuposave,zcount]=z_effect(sizes)
%the input is the different problem sizes to test, one entry is
%'m,n,theta,samples.' Time limit is 500s and optimality gap is 0.01.
%The solutions are calculated with and without using
%z in the optimization. Then test scenarios are used to calculate the objs 
%for each menu when z is counted so we can compare
%menuave is the average menu size, menuposave is the average menu size
%among drivers who were offered a nonempty menu

simobjs=zeros(size(sizes,1),2);
testobjs=zeros(size(sizes,1),2);
times=zeros(size(sizes,1),2);
xdiffs=zeros(size(sizes,1),1);
menuave=zeros(size(sizes,1),2);
menuposave=zeros(size(sizes,1),2);
zcount=zeros(size(sizes,1),2);
for t=1:size(sizes,1)
    m=sizes(t,1);
    n=sizes(t,2);
    theta=sizes(t,3);
    samples=sizes(t,4);
    [C,D,r,q,yprobs,Oi,Di,Oj,Dj,drand]=generate_params(m,n,1);
    [yhat,scenprobs]=indepy_generate_scens(yprobs,samples,0);
   
    %sove with no z
    tic
    [obj,gap,x1,v,w]=fixed_y_prob_cplex_dot_no_z(C,D,r,theta,q,yprobs,yhat,scenprobs,0,0,500,0.01,0);
    toc
    times(t,1)=toc;
    simobjs(t,1)=obj;
    menuave(t,1)=nnz(x1)/n
    menuposave(t,1)=nnz(x1)/nnz(sum(x1));

    
    
    %solve with z
    tic
    [obj,gap,x2,v,z,w]=fixed_y_prob_cplex_dot(C,D,r,theta,q,yprobs,yhat,scenprobs,0,0,500,0.01,0);
    toc
    times(t,2)=toc
    simobjs(t,2)=obj
    x=min(ones(m,n),x1+x2);
    xdiffs(t,1)=nnz(x1-x2)
    menuave(t,2)=nnz(x2)/n
    menuposave(t,2)=nnz(x2)/nnz(sum(x2))

    

    
    %%%now for a performance analysis on our two menus
    %%% first calculate the full set of offered items so we can generate
    %%% scenarios
    

    nontrivial=size(find(yprobs<1 & x==1),1);
    [yhat,weights]=performance_analysis_scens(x,yprobs,min(2^nontrivial,5000),0);
    if sum(sum(x1))>0
        [objave1,objsd,dupave1,dupsd,rejave,rejsd,aveassign,objvals]=sample_cases_performance_indepy(C,D,r,q,x1,yprobs,samples,yhat,weights);
        testobjs(t,1)=objave1
        zcount(t,1)=dupave1
    end
    if sum(sum(x2))>0
        [objave2,objsd,dupave2,dupsd,rejave,rejsd,aveassign,objvals]=sample_cases_performance_indepy(C,D,r,q,x2,yprobs,samples,yhat,weights);
        testobjs(t,2)=objave2
        zcount(t,2)=dupave2
    end

    
end