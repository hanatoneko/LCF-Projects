function[success,error,true_sorted,heur_sorted]=compare_assmts_same_scens(C,D,r,q,x,yprobs,samples,trials)
%%% saasamps is the number of samples used for saa to make the menus
%%% SUCCESS is the weighted portion of scenarios where the approx assign
%%% was opt. ERROR is opt-assign, i.e. it's not divided by the opt
%%% objective since it could be negative or zero
%%% OPTQUANTS is the quantile info on the optimal obj vals since we can't
%%% scale the error
[m,n]=size(C);

heur=zeros(trials,1);
true_sampled=zeros(trials,1);
success=zeros(trials,1);
error=zeros(trials,1);



for t=1:trials
    %%% performance analysis

    %%% for heuristic %%%%%%%%%%%%%%%%%%%%%%%
    %%%initialize vals
    optobjvals = zeros(samples,1);
    [yhat,weights]=performance_analysis_scens(x,yprobs,samples,0);
    


    %%%%%%%%%%%%%%%%% sample scenarios and run performance analysis

    for k=1:samples
        y= yhat(:,(k-1)*n+1:k*n);

           %%% performance analysis
          [obj,dup,rej,v,w,z]=approx_assgn(C,D,r,x,y);
          heurobjvals(k,1)=obj;
          
          [obj,dup,rej,v,w,z]=menu_performance_indepy(C,D,r,q,x,y);
          optobjvals(k,1)=obj;

    end
    
    true_sampled(t,1) = (optobjvals')*weights'/sum(weights);
    heur(t,1) = (heurobjvals')*weights'/sum(weights);
    success(t,1)=1-(min(ceil(optobjvals-heurobjvals),zeros(samples,1)))'*weights'/sum(weights);
    error=(optobjvals-heurobjvals)'*weights'/sum(weights);
end

%%%
%%% assume last opt assign test set is most valid so sort based on those
%%% entries
[true_sorted, true_order] = sort(true_sampled);
heur_sorted = heur(true_order,:);






