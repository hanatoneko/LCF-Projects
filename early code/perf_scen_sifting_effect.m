function[testobjs,error,perckeep]=perf_scen_sifting_effect(sizes,barsizes)
%the input is the different problem sizes to test, one entry is
%'m,n,theta,test sample size.' Time limit is 500s and optimality gap is 0.01.
%A menu is found, then, we do performance analysis for an initial set of 
%test scenarios as well as performance with a subset of those scenarios that is 
%guaranteed to have a pre-specified diameter for the objective average
%error bars. This can be done for multiple subsets with different error bar
%sizes. We'll record the obj average calculated for each, as well as the
%number of scenarios retained.
%Perckeep are the percentage of the scenarios kept for the second
%round of saa


testobjs=zeros(size(sizes,1),size(barsizes,1)+1);
perckeep=zeros(size(sizes,1),size(barsizes,1));
for t=1:size(sizes,1)
    m=sizes(t,1);
    n=sizes(t,2);
    theta=sizes(t,3);
    [C,D,r,q,yprobs,Oi,Di,Oj,Dj,drand]=generate_params(m,n,1);
    [yhat,scenprobs]=indepy_generate_scens(yprobs,100,0);
   
    %get a menu
    
    [obj,gap,x,v,z,w]=fixed_y_prob_cplex_dot(C,D,r,theta,q,yprobs,yhat,scenprobs,0,0,500,0.01,0);
    

    

%%%% calculate and save obj val for full set of performance scens   

    nontrivial=size(find(yprobs<1 & x==1),1);
    [yhat,weights]=performance_analysis_scens(x,yprobs,min(2^nontrivial,sizes(t,4)),0);
    if sum(sum(x))>0
        [objave1,objsd,dupave1,dupsd,rejave,rejsd,aveassign,objvals]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,50,yhat,weights);
        testobjs(t,1)=objave1
    end
    
    for k=1:size(barsizes,1)
        [fullyhat,fullweights,trunkyhat,trunkweights,perc]=error_bar_filter(C,D,r,q,x,yprobs,yhat,weights,barsizes(k,1));
        perckeep(t,k)=perc
        testobjs(t,k+1)=objvals'*fullweights'/sum(fullweights)
    end
    
error=zeros(size(testobjs,1),size(barsizes,1));
for i=1:size(barsizes,1)
    error(:,i)=testobjs(:,i+1)-testobjs(:,1);
end



    
end