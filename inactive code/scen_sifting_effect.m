function[testobjs,times,xdiffs,perckeep,menuave,menuposave]=scen_sifting_effect(probsizes,ratios)
%the input is the different problem sizes to test, one entry is
%'m,n,theta,samples.' Time limit is 500s and optimality gap is 0.01.
%The solutions are calculated with and without using
%z in the optimization. Then test scenarios are used to calculate the objs 
%for each menu when the saa samples are the full set of samples and when
%only samples within a factor of 1000 of the most likely scenario are
%included. Perckeep are the percentage of the scenarios kept for the second
%round of saa


testobjs=zeros(size(probsizes,1),1+size(ratios,1));
times=zeros(size(probsizes,1),1+size(ratios,1));
xdiffs=zeros(size(probsizes,1),size(ratios,1));
menuave=zeros(size(probsizes,1),1+size(ratios,1));
menuposave=zeros(size(probsizes,1),1+size(ratios,1));
perckeep=zeros(size(probsizes,1),size(ratios,1));

for t=1:size(probsizes,1)
    m=probsizes(t,1);
    n=probsizes(t,2);
    theta=probsizes(t,3);
    samples=probsizes(t,4);
    xvals=zeros(m,n*size(ratios,1));
    [C,D,r,q,yprobs,Oi,Di,Oj,Dj,drand]=generate_params(m,n,1);
    [yhat,scenprobs]=indepy_generate_scens(yprobs,samples,0);
   
    %sove with original yhat
    tic
    [obj1,gap,x1,v,w]=fixed_y_prob_cplex_dot(C,D,r,theta,q,yprobs,yhat,scenprobs,0,0,500,0.01,0);
    toc
    times(t,1)=toc;
    menuave(t,1)=nnz(x1)/n
    menuposave(t,1)=nnz(x1)/nnz(sum(x1));

    
    
    %solve with filtered yhat for each retention level
    for k=1:size(ratios,1)
        
        [newyhat,newprobs,retention]=filter_scens(m,n,yprobs,yhat,scenprobs,ratios(k,1),'a',0);
        perckeep(t,k)=retention
        if perckeep(t,k)==1
            times(t,k+1)=times(t,1);
            xvals(:,(k-1)*n+1:k*n)=x1;
            menuave(t,k+1)=nnz(x1)/n
            menuposave(t,k+1)=nnz(x1)/nnz(sum(x1))
        else
            tic
            [obj,gap,x2,v,z,w]=fixed_y_prob_cplex_dot(C,D,r,theta,q,yprobs,newyhat,newprobs,0,0,500,0.01,0);
            toc
            times(t,k+1)=toc
            xunion=min(ones(m,n),x1+x2);
            xvals(:,(k-1)*n+1:k*n)=x2;
            xdiffs(t,k)=nnz(x1-x2)
            menuave(t,k+1)=nnz(x2)/n
            menuposave(t,k+1)=nnz(x2)/nnz(sum(x2))
        end

    end 

    
    %%%now for a performance analysis on our two menus
    %%% first calculate the full set of offered items so we can generate
    %%% scenarios
    

    nontrivial=size(find(yprobs<1 & xunion==1),1);
    [yhat,weights]=performance_analysis_scens(xunion,yprobs,min(2^nontrivial,5000),0);
    if sum(sum(x1))>0
        [objave1,objsd,dupave1,dupsd,rejave,rejsd,aveassign,objvals]=sample_cases_performance_indepy(C,D,r,q,x1,yprobs,samples,yhat,weights);
        testobjs(t,1)=objave1
    end
    for k=1:size(ratios,1)
        if sum(sum(xvals(:,(k-1)*n+1:k*n)))>0
            if perckeep(t,k)==1
                testobjs(t,k+1)=objave1;
            else
                [objave2,objsd,dupave2,dupsd,rejave,rejsd,aveassign,objvals]=sample_cases_performance_indepy(C,D,r,q,xvals(:,(k-1)*n+1:k*n),yprobs,samples,yhat,weights);
                testobjs(t,k+1)=objave2
            end
        end
    end

    
end