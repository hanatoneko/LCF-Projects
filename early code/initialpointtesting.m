function[simobjs,testobjs,times,xdiffs]=initialpointtesting(sizes)
%the input is the different problem sizes to test, one entry is
%'m,n,theta,samples.' The solutions are calculated with and without using
%an initial point with a time limit of 1000s and solving time and
%objectives are compared.

%%%%%%%%%%% I was unable to get the new cplex format to accept an initial
%%%%%%%%%%% point and it seemed from previous tests that an initial point
%%%%%%%%%%% doesn't affect much (at least the one we give it) so going
%%%%%%%%%%% forward we won't include an initial point
simobjs=zeros(size(sizes,1),3);
testobjs=zeros(size(sizes,1),3);
times=zeros(size(sizes,1),2);
xdiffs=zeros(size(sizes,1),2);
for t=1:size(sizes,1)
    m=sizes(t,1);
    n=sizes(t,2);
    theta=sizes(t,3);
    samples=sizes(t,4);
    [C,D,r,q,yprobs,Oi,Di,Oj,Dj,drand]=generate_params(m,n,1);
    [yhat,scenprobs]=indepy_generate_scens(yprobs,samples,0);
    
    tic
    [obj,x1,v,z,w]=fixed_y_prob(C,D,r,theta,q,yhat,scenprobs,0,0,[],500,00);
    toc
    times(t,1)=toc;
    simobjs(t,1)=obj;

    
    
    [x0]=initialpoint(yprobs,yhat);
    xinit=reshape(x0(1:m*n,1),[m,n]);
    tic
    [obj,x2,v,z,w]=fixed_y_prob(C,D,r,theta,q,yhat,scenprobs,0,0,x0,500,0);
    toc
    times(t,2)=toc
    simobjs(t,2)=obj
    x=min(ones(m,n),xinit+x1+x2);
    xdiffs(t,1)=nnz(x1-x2)
    xdiffs(t,2)=nnz(x2-xinit)
    
    %%% calculate  the simulated obj for the initial point
    inobj=zeros(m*n+2*m*n*samples,1);
    block=repmat(scenprobs,m*n,1);
    inobj(m*n+1:m*n+m*n*samples,1)=((repmat(C(:),samples,1)+repmat(r,n*samples,1)).*block(:))/sum(scenprobs);
    inobj(m*n+m*n*samples+1:m*n+2*m*n*samples,1)=repmat(-D(:),samples,1).*block(:)/sum(scenprobs);
    simobjs(t,3)=inobj'*x0;
    
    %%%now for a performance analysis on our two menus
    %%% first calculate the full set of offered items so we can generate
    %%% scenarios
    

    nontrivial=size(find(yprobs<1 & x==1),1);
    [yhat,weights]=performance_analysis_scens(x,yprobs,min(2^nontrivial,5000),0);
    [objave1,objsd,dupave,dupsd,rejave,rejsd]=sample_cases_performance_indepy(C,D,r,q,x1,yprobs,samples,yhat,weights);
    testobjs(t,1)=objave1
    [objave2,objsd,dupave,dupsd,rejave,rejsd]=sample_cases_performance_indepy(C,D,r,q,x2,yprobs,samples,yhat,weights);
    testobjs(t,2)=objave2
    [objave3,objsd,dupave,dupsd,rejave,rejsd]=sample_cases_performance_indepy(C,D,r,q,xinit,yprobs,samples,yhat,weights);
    testobjs(t,3)=objave3
    
end