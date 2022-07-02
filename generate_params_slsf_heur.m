function[C,D,r,fare,q,yprobs,slsfcomp,Oi,Di,Oj,Dj,OjOimins,extradrivingtime,drand]=generate_params_slsf_heur(m,n)
%%% generates the input parameter arrays for SLSF/ SLSFnoZ (not including
%%% scenarios). The values follow the SLSF paper (except C and r are
%%% consolidated into just C). The parameters generated have the same value
%%% as generate_params, but saves extra values so we can use them for
%%% analysis (and saves the driver compensations as these are used for the
%%% heuristics used as a performance comparison)

%%% inputs: m=number of requests, n= number of drivers

%%% outputs: C and D are m x n arrays of those parameters, r is the m x 1 vector match
%%% bonus (i.e. the objective function is Cv +rw-Dz), 
%%%  q is a col vector of how many requests each driver can be assigned,
%%%  fare is m x n array of the trip-dependent fares,
%%% yprobs is the pij array, slsfcomp is the fixed wages (assumed fare*0.8) (m x n),
%%% Oj/Oi is drivers'/riders' origin nodes (column vectors),
%%% Dj/Di are destinations (column vectors), OjOimins is an m x n array of how long it 
%%% takes driver j to reach request i (in mins), extradrivingtime is an m x n array of the time in hours 
%%% of driver j's trip time if matched with request i minus the driving time of driver j's original trip,
%%% drand is the column vecor random component
%%% of D (one value per driver) that we return just in case we want it isolated later (D = fare +
%%% repmat( drand,m,1))




%%%load the chicago data then generate the desired number of OD trips  

    [arcdata,dem]=loadchicago_regional_proper();


%%% draw OD pairs for the requests and save those O and D nodes
[rtripindex] = randsample(size(dem,1),m,true,dem(:,3));
Oi=arcdata(dem(rtripindex,1));
Di=arcdata(dem(rtripindex,2));
%%% draw OD pairs for the drivers and save those O and D nodes
[dtripindex] = randsample(size(dem,1),n,true,dem(:,3));
Oj=arcdata(dem(dtripindex,1));
Dj=arcdata(dem(dtripindex,2));



%%% load the length and duration of shortest paths for all possible OD
%%% pairs this was calculated once using shortest path code
[miles,mins]=loadtripinfo();
tripinfo=cat(3,miles,mins);

%%% pull out trip info (miles and mins) for our drawn OD pairs
%%% for the driver trips
OjDj=zeros(n,2);
for j=1:n
    OjDj(j,:)=horzcat(miles(Oj(j),Dj(j)),mins(Oj(j),Dj(j)));
end

%for the request trips
OiDi=zeros(m,2);
for i=1:m
    OiDi(i,:)=horzcat(miles(Oi(i),Di(i)),mins(Oi(i),Di(i)));
end

%get the trip info for each driver driving to each request origin from
%their origin (OjOi), and driving from each request destination to their
%destination (DiDj)
%row is request, column is driver, and first entry is miles, second is minutes
OjOi=permute(tripinfo(Oj,Oi,:),[2 1 3]);

DiDj=tripinfo(Di,Dj,:);

% if center==0
%     [OjDj,OjOi,OiDi,DiDj]=trip_info(arcdata,Oi,Di,Oj,Dj);
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% calculating/generating the parameters %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% C value is the 'service fee' plus 20% of the fare minus 0.28*[the wait
%%% time for the driver to get to the request]

%%% pij (var name is yprobs) is determined by the ratio of the driver's compensation and their
%%% extra driving time. This ratio is their perceived wage per hour, so pij
%%% will be 0 for $10 an hour or less, and increase linearly until pij=1 if
%%% they are paid $25 an hour or more

OjOimins=OjOi(:,:,2);
fare=repmat(max(1.79*ones(m,1)+0.81*OiDi(:,1)+0.28*OiDi(:,2),3*ones(m,1)),1,n);
C=1.85*ones(m,n)+0.2*fare-0.28*0.2*OjOi(:,:,2);
wagemin=10;
wagemax=25;
extradrivingtime =(OjOi(:,:,2) + repmat(OiDi(:,2),1,n) + DiDj(:,:,2) -repmat(OjDj(:,2)',m,1))/60; %given in hours
yprobs=(0.8*fare./extradrivingtime -wagemin*ones(m,n))/(wagemax-wagemin);
%edit values that were above 1 or below 0
yprobs=min(yprobs,ones(m,n));
yprobs=max(yprobs,zeros(m,n));
extradrivingmiles =(OjOi(:,:,1) + repmat(OiDi(:,1),1,n) + DiDj(:,:,1) -repmat(OjDj(:,1)',m,1)) ;
slsfcomp = 0.8*fare;


drand=3*rand(1,n);
D=fare.*ones(m,n)+repmat(drand,m,1);
r=15*rand(m,1);
q=ones(n,1);
