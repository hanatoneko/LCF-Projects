function[fullyhat,fullweights,trunkyhat,trunkweights,perckeep]=error_bar_filter(C,D,r,q,x,yprobs,yhat,weights,bar)
%%% this is to filter performance analysis scenarios. The bar value is the
%%% acceptable diameter of the error bar. We calculate the highest possible
%%% objective value we could get for any possible scenario, and obtain a
%%% lower bound on the lowest value. The difference between these two
%%% numbers when, multiplied by the total weight of deleted scenarios,
%%% gives us the diameter of the error bar. Since the diameter is given, we
%%% use the max-min difference to determine how much weight of scenarios we
%%% can remove. The least likely scenario is then removed one at a time
%%% until the maximum weight we can remove has been met.

[m,n]=size(C);
s=size(yhat,2)/n;
%%%normalize weights in case they aren't already
weights=weights/sum(weights);

[objmax,v]=performance_max(C,D,r,q,x,yprobs);
[objmin,dup,rej,v,w,z]=performance_min(C,D,r,q,x,yprobs);


fullyhat=yhat;
fullweights=weights;
deleted=0;

available=bar/(objmax-objmin);

while true
    
    %%% find minimum value and index (and break ties if any)
    minweight=min(fullweights(fullweights>0));

    curr=find(fullweights==minweight);
    if size(curr,2)>1
        curr=curr(1,1);
    end
    
    %%% break if we can't afford removing another scenario
    if minweight>available
        break
    end
    
    %%% adjust yhats and weights
    deleted=deleted+1;
    fullyhat(:,(curr-1)*n+1:curr*n)=zeros(m,n);
    fullweights(1,curr)=0;
    available=available-minweight;
    
    
    
end
trunkweights=fullweights(fullweights>0);


%%% since we want to delete the correct entries for the truncated versions,
%%% we have to do it at the end.
indices=find(fullweights>0);
trunkyhat=zeros(m,n*size(indices,2));
for k=1:size(indices,2)
    curr=indices(1,k);
    trunkyhat(:,(k-1)*n+1:k*n)= yhat(:,(curr-1)*n+1:curr*n);
end

perckeep=(s-deleted)/s;




