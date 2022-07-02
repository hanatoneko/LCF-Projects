function[simobjs,testobjs,times,xdiffs,menuave,menuposave]=theta_effect(probsizes,samples)
%the input is the different problem sizes to test, one entry is
%'m,n.' Time limit is 500s and optimality gap is 0.01.
%The solutions are calculated with four different theta sizes  and four
%different sample sizes.
%menuave is the average menu size, menuposave is the average menu size
%among drivers who were offered a nonempty menu
samp=size(samples,1);
simobjs=zeros(size(probsizes,1)*4,samp);
testobjs=zeros(size(probsizes,1)*4,samp);
times=zeros(size(probsizes,1)*4,samp);
xdiffs=zeros(size(probsizes,1)*4,samp-1);
menuave=zeros(size(probsizes,1)*4,samp);
menuposave=zeros(size(probsizes,1)*4,samp);

for t=1:size(probsizes,1)
    m=probsizes(t,1);
    n=probsizes(t,2);
    theta=[2;ceil(m/3);floor(2*m/3);m];
    [C,D,r,q,yprobs,Oi,Di,Oj,Dj,drand]=generate_params(m,n,1);
    %x stores all menus from a given m and n, since we want the same
    %scens across theta sizes and we want to compare menu differences
    %between menus with different sample sizes
    x=zeros(m*4,n*samp);
    for s=1:samp
        [yhat,scenprobs]=indepy_generate_scens(yprobs,samples(s,1),0);
        for i=1:4 
   
        %solve with the current sample size and theta

        tic
        [obj,gap,x1,v,w]=fixed_y_prob_cplex_dot(C,D,r,theta(i,1),q,yprobs,yhat,scenprobs,0,0,500,0.01,0);
        toc
        
        x((i-1)*4*m+1:(i-1)*4*m+m,(s-1)*n+1:s*n)=x1;
        times((t-1)*4+i,s)=toc
        simobjs((t-1)*4+i,s)=obj
        menuave((t-1)*4+i,s)=nnz(x1)/n
        menuposave((t-1)*4+i,s)=nnz(x1)/nnz(sum(x1))
        end
    end
    


    
    %%%now for a performance analysis on all menus for current m,n
    %%% first calculate the full set of offered items so we can generate
    %%% scenarios
    
    %first compute the union of all offered pairs
    xunion=zeros(m,n);
    for i=1:4
        for s=1:samp
            xunion=xunion+x((i-1)*4*m+1:(i-1)*4*m+m,(s-1)*n+1:s*n);
        end
    end
    xunion=min(ones(m,n),xunion);
        %simplify menu
    for i=1:m
            for j=1:n
                if abs(xunion(i,j))<0.1
                    xunion(i,j)=0;
                end
                if abs(xunion(i,j)-1)<0.1
                    xunion(i,j)=1;
                end
            end
    end
    nontrivial=size(find(yprobs<1 & xunion<=0.5),1);   
    [yhat,weights]=performance_analysis_scens(xunion,yprobs,min(2^nontrivial,50),0);
    for i=1:4
        for s=1:samp
            if sum(sum(x((i-1)*4*m+1:(i-1)*4*m+m,(s-1)*n+1:s*n)))>0
                [objave1,objsd,dupave1,dupsd,rejave,rejsd,aveassign,objvals]=sample_cases_performance_indepy(C,D,r,q,x((i-1)*4*m+1:(i-1)*4*m+m,(s-1)*n+1:s*n),yprobs,5000,yhat,weights);
                testobjs((t-1)*4+i,s)=objave1;
                %%% for xdiffs we'll just measure each menu against the menu
                %%% with the next most samples (i.e. see how many changes there
                %%% were with the sample increase)
                if s>1
                    xdiffs((t-1)*4+i,s-1)=nnz(x((i-1)*4*m+1:(i-1)*4*m+m,(s-1)*n+1:s*n)-x((i-1)*4*m+1:(i-1)*4*m+m,(s-2)*n+1:(s-1)*n));
                end
            end
        end
    end

    testobjs
    xdiffs

    
end