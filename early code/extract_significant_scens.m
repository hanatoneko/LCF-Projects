function[sigyhat,sigprobs]=extract_significant_scens(yhat,scenprobs)

scens=size(scenprobs,2);
m=size(yhat,1);
n=size(yhat,2)/scens;
mostsig=max(scenprobs);
sigindex=find(scenprobs>=mostsig/1000);
sigyhat=zeros(m,n*size(sigindex,1));
sigprobs=zeros(1,size(sigindex,1));
for k=1:size(sigindex,2)
    sigprobs(1,k)=scenprobs(sigindex(k));
    sigyhat(:,(k-1)*n+1:n*k)=yhat(:,(sigindex(k)-1)*n+1:n*sigindex(k));
end
