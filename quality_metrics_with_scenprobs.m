function[avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare]=quality_metrics_with_scenprobs(fare,comp,extradrivingtime,scenprobs,vfull,wfull)

%this code calculates some quality metrics of the test scenarios from a
%solution's performance analysis. The averages are calculated as the
%average across the test scenarios, and the test scenarios are weighted
%relatively based on their liklihood of occuring

%%% inputs: fare is m x n of the fare, comp is m x n of the compensation
%%% offers, extradrivingtime is m x n of the extra driving time for driver
%%% j if they are matched with request i, scenprobs is 1x trials of the 
%scenario likelihoods, vfull is the full test v array,
%%% that is the assignment of every test scenario (m x n arrays
%%% concatenated horizontally), and wfull is the unmatched request arrays
%%% of all of the test scenarios, concatenated horizontally

%ouputs: each output is a 1 x trials arry where each entry is the average value of the problem instance. avecomp is the average
%compensation offer of the assigned driver-request pairs, aveperccomp is the average of
%[the compensation offer divided by the fare] of assigned driver-request pairs, avetotprofit
%is the average profit made by the platform, percposprofit is the portion of test scenarios in which the profit is positive 
%(this has always been 1 so far), aveextratime is the average extra driving
%time of matched drivers, and averejfare is the average fare of unmatched requests



[m,n]=size(fare);
testscensize=size(vfull,2)/n;
%scenprobsbig = kron(scenprobs, ones(m,n));

compfull = zeros(1,testscensize);
perccompfull = zeros(1,testscensize);
profitfull = zeros(1,testscensize);
extratimefull = zeros(1,testscensize);
rejfull = zeros(1,testscensize);


for s=1:testscensize
    compfull(1,s) = sum(sum(comp.*vfull(:,(s-1)*n+1:s*n)))/nnz(vfull(:,(s-1)*n+1:s*n));
    perccompfull(1,s) = sum(sum((comp./fare).*vfull(:,(s-1)*n+1:s*n)))/nnz(vfull(:,(s-1)*n+1:s*n));
    profitfull(1,s) = sum(sum((fare+1.85*ones(m,n)-comp).*vfull(:,(s-1)*n+1:s*n)));
    extratimefull(1,s) = sum(sum(extradrivingtime.*vfull(:,(s-1)*n+1:s*n)))/nnz(vfull(:,(s-1)*n+1:s*n));
    rejfull(1,s) = sum(sum(fare(:,1).*wfull(:,s)))/nnz(wfull(:,s));
end

avecomp = compfull*scenprobs'/sum(scenprobs);
aveperccomp = perccompfull*scenprobs'/sum(scenprobs);
avetotprofit = profitfull*scenprobs'/sum(scenprobs);
aveextratime = extratimefull*scenprobs'/sum(scenprobs);
averejfare = rejfull*scenprobs'/sum(scenprobs);
percposprofit=size(find(profitfull>0),2)/testscensize;