function[avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare]=quality_metrics(fare,comp,extradrivingtime,vfull,wfull)

%this code calculates some quality metrics of the test scenarios from a
%solution's performance analysis. The averages are calculated as the
%average across the test scenarios, and the test scenarios are weighted
%equally

%%% inputs: fare is m x n of the fare, comp is m x n of the compensation
%%% offers, extradrivingtime is m x n of the extra driving time for driver
%%% j if they are matched with request i, vfull is the full test v array,
%%% that is, the assignment of every test scenario (m x n arrays
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

compfull=repmat(comp,1,testscensize).*vfull;
avecomp=sum(sum(compfull))/nnz(compfull);
aveperccomp=sum(sum(compfull./repmat(fare,1,testscensize)))/nnz(compfull);
profitfull=(repmat(fare,1,testscensize)+1.85*ones(m,n*testscensize)-repmat(comp,1,testscensize)).*vfull;
avetotprofit=sum(sum(profitfull))/testscensize;
profitperscen=zeros(1,testscensize);
for s=1:testscensize
    profitperscen(1,s)=sum(sum(profitfull(:,(s-1)*n+1:s*n)));
end

percposprofit=size(find(profitperscen>0),2)/testscensize;
extratimefull=repmat(extradrivingtime,1,testscensize).*vfull;
aveextratime=sum(sum(extratimefull))/nnz(extratimefull);
rejfull=repmat(fare(:,1),1,testscensize).*wfull;
averejfare=sum(sum(rejfull))/nnz(rejfull);
