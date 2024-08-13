function[y,scenprobs]=indepy_generate_scens(m,n,kpercentage,samples)

% numpicks is the number of options each driver is intereted in
% topkpicks is a numpick*n matrix with the indices of the top k picks for each driver
% yprobs is the m*n matrix with the probability that item i is accepted by driver j if offered
% y is the m*(samples*n) matrix of 1s and 0s telling what drivers accept for each scenario
% scenprobs is a 1*samples vector with the probability that each scenario occurs

scenprobs=ones(1,samples);
y=zeros(m,n*samples);
for k=1:samples
    y(:,(k-1)*n+1:(k-1)*n+n) = binornd(ones(m,n),yprobs);
    for i=1:numpicks
        for j=1:n
            if y(topkpicks(i,j),(k-1)*n+j) == 1
                scenprobs(1,k) = scenprobs(1,k)*yprobs(topkpicks(i,j),j);
            else
                scenprobs(1,k) = scenprobs(1,k)*(1-yprobs(topkpicks(i,j),j));
            end
        end
    end
end