function[testobjs,error,times,searchtimes,menunzs]=perf_scen_mutation_effect(probsizes,factors,testsizes)
%the input is the different problem sizes to test, one entry is
%'m,n,theta.' A menu is calculated using 50 (random) saa samples. Time limit is 500s and optimality gap is 0.01.
%Then, we do performance analysis for either the exhaustive
% scenario set or 5000 scens for larger
% problems. Then for specified filter sizes and sample sizes we
%We'll record the obj average calculated for each and how long it 
%took for the search and refill process to complete.

numprobs=size(probsizes,1);
numfactors=size(factors,1);
numsamps=size(testsizes,1);

testobjs=zeros(numprobs,numsamps*numfactors+2);
error=zeros(numprobs,numsamps*numfactors+1);
times=zeros(numprobs,numsamps*numfactors+2);
searchtimes=zeros(numprobs,numsamps*numfactors+1);
menunzs=zeros(numprobs,1);
for t=1:numprobs
    m=probsizes(t,1);
    n=probsizes(t,2);
    theta=probsizes(t,3);
    [C,D,r,q,yprobs,Oi,Di,Oj,Dj,drand]=generate_params(m,n,1);
    [yhat,scenprobs,scenbase,scenexp]=indepy_generate_scens(yprobs,50,0);
   
    %get a menu
    
    [obj,gap,x,v,z,w]=fixed_y_prob_cplex_dot(C,D,r,theta,q,yprobs,yhat,scenprobs,0,0,500,0.01,0);
    menunzs(t,1)=nnz(x)
    
%%% calculate exhaustive or 5000 
    nontrivial=size(find(yprobs<1 & x==1),1);
    if nontrivial<19
        %do exhaustive
        tic
        [objave,objsd,dupave,dupsd,rejave,rejsd,aveassign,objvals]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,'all',0,0);
        toc
        testobjs(t,2)=objave;
        times(t,2)=toc;
        testobjs(t,1)=nontrivial
        times(t,1)=nontrivial
        error(t,1)=nontrivial;
        searchtimes(t,1)=nontrivial;
    else
        %do 5000 random scens
        tic
        [objave,objsd,dupave,dupsd,rejave,rejsd,aveassign,objvals]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,5000,0,0);
        toc
        testobjs(t,1)=objave;
        times(t,1)=toc;
        testobjs(t,1)=0
        times(t,1)=0
        error(t,1)=0;
        searchtimes(t,1)=0;
    end
%%%% calculate and save obj val for each filterlevel-sample size pair   

     
    for k=1:numsamps
        for ell=1:numfactors
            tic
            [newyhat,newprobs,newretention,scenbase,scenexp]=filter_scens(m,n,yprobs.*x,0,0,0,factors(ell,1),'t',testsizes(k,1));
            toc
            searchtimes(t,(ell-1)*numsamps+k+1)=toc
            
            if nnz(newyhat)>0
                tic
                [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign,objvals]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,testsizes(k,1),newyhat,newprobs);
                toc
                testobjs(t,2+(ell-1)*numsamps+k)=objave2
                times(t,2+(ell-1)*numsamps+k)=toc
                error(t,(ell-1)*numsamps+k+1)=objave-objave2
            end
            
        end
    end
    


    
end