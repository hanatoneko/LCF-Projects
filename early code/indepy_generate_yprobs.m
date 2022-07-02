function[yprobs]=indepy_generate_yprobs(m,n,ybase,yrand)

% numpicks is the number of options each driver is intereted in
% topkpicks is a numpick*n matrix with the indices of the top k picks for each driver
% yprobs is the m*n matrix with the probability that item i is accepted by driver j if offered
% y is the m*(samples*n) matrix of 1s and 0s telling what drivers accept for each scenario
% scenprobs is a 1*samples vector with the probability that each scenario occurs

yprobs=ybase*(m,n)+yrand*rand(m,n);
% range=[1:1:m];
% numpicks=ceil(m*kpercentage);
% yprobs=zeros(m,n);
% topkpicks=zeros(numpicks,n); %matrix of the indices of the requests driver j can accept
% for j=1:n
%     topkpicks(:,j)=randsample(range,numpicks)';
%     for i=1:numpicks
%         yprobs(topkpicks(i,j),j)=ybase+yrand*rand(1,1);
%     end
% end
% topkpicks=sort(topkpicks);

