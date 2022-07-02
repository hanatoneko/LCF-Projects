function[testobjs,randerror,muterror,times,menunzs]=perf_scen_mutation_and_random(probsizes)
%the input is the different problem sizes to test, one entry is
%'m,n,theta.' A menu is calculated using 50 (random) saa samples. Time limit is 500s and optimality gap is 0.01.
%Then, we do performance analysis for either the exhaustive
% scenario set or 200,000 scens (one set of random and one set of mutated) for larger
% problems. Then for we'll record the obj average for 1000 random scens and
% 1000 mutated scens. We'll do 3 trials of the 1000 scens for each type

numprobs=size(probsizes,1);


testobjs=zeros(numprobs,9);
randerror=zeros(numprobs,7);
muterror=zeros(numprobs,7);
times=zeros(numprobs,9);
menunzs=zeros(numprobs,1);
for t=1:numprobs
    m=probsizes(t,1);
    n=probsizes(t,2);
    theta=probsizes(t,3);
    
    while true
        [C,D,r,q,yprobs,Oi,Di,Oj,Dj,drand]=generate_params(m,n,1);
        [yhat,scenprobs,newretention,scenbase,scenexp]=filter_scens(m,n,yprobs,0,0,0,1000,'t',10);

        %get a menu

        [obj,gap,x,v,z,w]=fixed_y_prob_cplex_dot(C,D,r,theta,q,yprobs,yhat,scenprobs,0,0,500,0.01,0);
        nontrivial=size(find(yprobs<1 & x==1),1);
        menunzs(t,1)=nnz(x)
        if nontrivial>11
            break
        end
        
        
    end
%%% calculate exhaustive or 200,000 for each type 
    
    testobjs(t,1)=nontrivial;
    times(t,1)=nontrivial;
    randerror(t,1)=nontrivial;
    muterror(t,1)=nontrivial;
    if nontrivial<19
        %do exhaustive
        tic
        [objaver,objsd,dupave,dupsd,rejave,rejsd,aveassign,objvals]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,'all',0,0);
        toc
        testobjs(t,2)=objaver
        times(t,2)=toc


    else
        %do 200,000 random scens
        tic
        [objaver,objsd,dupave,dupsd,rejave,rejsd,aveassign,objvals]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,200000,0,0);
        toc
        testobjs(t,2)=objaver
        times(t,2)=toc

        
        %do 200,000 mutated scens
        
        [newyhat,newprobs,newretention,scenbase,scenexp]=filter_scens(m,n,yprobs.*x,0,0,0,1000000,'t',200000);
        if nnz(newyhat>0)
            tic
            [objavem,objsd,dupave,dupsd,rejave,rejsd,aveassign,objvals]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,200000,newyhat,newprobs);
            toc
         testobjs(t,3)=objavem
        times(t,3)=toc
        end
       

    end
%%%% calculate and save obj val for 1000 rand scens and 1000 mutated scens 3x each and compare with larger test results  

     
    for k=1:3
        %do 1,000 random scens 
        tic
        [objave2,objsd,dupave,dupsd,rejave,rejsd,aveassign,objvals]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,1000,0,0);
        toc
        testobjs(t,3+k)=objave2
        times(t,3+k)=toc
        randerror(t,k+1)=objaver-objave2
        if testobjs(t,3)~=0
            muterror(t,k+1)=objavem-objave2
        end

        
        %do 1,000 mutated scens
        
        [newyhat,newprobs,newretention,scenbase,scenexp]=filter_scens(m,n,yprobs.*x,0,0,0,1000000,'t',1000);
        if nnz(newyhat>0)
            tic
                [objave3,objsd,dupave,dupsd,rejave,rejsd,aveassign,objvals]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,1000,newyhat,newprobs);       
            toc
            testobjs(t,k+6)=objave3
            times(t,k+6)=toc
            randerror(t,k+4)=objaver-objave3
            if testobjs(t,3)~=0
                muterror(t,k+4)=objavem-objave3
            end
         end    
    end
    


    
end