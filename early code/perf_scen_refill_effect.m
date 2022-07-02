function[testobjs,error,times,searchtimes,menunzs]=perf_scen_refill_effect(probsizes,factors,testsizes)
%the input is the different problem sizes to test, one entry is
%'m,n,theta.' Time limit is 500s and optimality gap is 0.01.
%A menu is found, then, we do performance analysis for an initial set of 
%test scenarios as well as performance with a smaller set of scenearios generated
%by filterig scenarios not within a prespecified factor (multiple factors can be tested)
% and then redrawing new scenarios and filtering again until a the specified test sample size
% is reached. We'll record the obj average calculated for each and how long it 
%took for the search and refill process to complete.

numprobs=size(probsizes,1);
numfactors=size(factors,1);
numsamps=size(testsizes,1);

testobjs=zeros(numprobs*numfactors,numsamps+1);
error=zeros(numprobs*numfactors,numsamps);
times=zeros(numprobs*numfactors,numsamps+1);
searchtimes=zeros(numprobs*numfactors,numsamps);
menunzs=zeros(numprobs,1);
for t=1:numprobs
    m=probsizes(t,1);
    n=probsizes(t,2);
    theta=probsizes(t,3);
    [C,D,r,q,yprobs,Oi,Di,Oj,Dj,drand]=generate_params(m,n,1);
    [yhat,scenprobs]=indepy_generate_scens(yprobs,50,0);
   
    %get a menu
    
    [obj,gap,x,v,z,w]=fixed_y_prob_cplex_dot(C,D,r,theta,q,yprobs,yhat,scenprobs,0,0,500,0.01,0);
    menunzs(t,1)=nnz(x);
    

    

%%%% calculate and save obj val for full set of performance scens   

    nontrivial=size(find(yprobs<1 & x==1),1);
    [yhat,weights]=performance_analysis_scens(x,yprobs,min(2^nontrivial,5000),0);
    if sum(sum(x))>0
        tic
        [objave1,objsd,dupave1,dupsd,rejave,rejsd,aveassign,objvals]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,5000,yhat,weights);
        toc
        testobjs((t-1)*numfactors+1,1)=objave1
        times((t-1)*numfactors+1,1)=toc
    end
    
    for k=1:numsamps
        for ell=1:numfactors
            tic
            [newyhat,newprobs,retention]=filter_scens(m,n,yprobs.*x,yhat,weights,factors(ell,1),'r',testsizes(k,1));
            toc
            searchtimes((t-1)*numfactors+ell,k)=toc
            
            if nnz(newyhat)>0
                tic
                [objave2,objsd,dupave1,dupsd,rejave,rejsd,aveassign,objvals]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,50,newyhat,newprobs);
                toc
                testobjs((t-1)*numfactors+ell,1+k)=objave2
                times((t-1)*numfactors+ell,1+k)=toc
                error((t-1)*numfactors+ell,k)=objave1-objave2
            end
            
        end
    end
    


    
end