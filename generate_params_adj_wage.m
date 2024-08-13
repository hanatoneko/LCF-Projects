function[C,yprobs]=generate_params_adj_wage(m,n,wage,D,r,q,Oi,Di,Oj,Dj,drand)

%%% code used for trying the different wage levels in the SLSF paper, it
%%% will generate new versions of the two parameters (C and yprobs)
%%% affected by the different wage

%%% inputs: m, n, wage (in [0,1] e.g. 0.8 means they are paid 80% of the
%%% fare), D, r, q, Oi, Di, Oj, Dj, and drand are all the parameters
%%% outputted from generate_params



%%%load the chicago data then generate the desired number of OD trips 
    [arcdata,dem]=loadchicago_regional_proper();




%%% load the length and duration of shortest paths for all possible OD
%%% pairs (this was calculated once using shortest path code)
[miles,mins]=loadtripinfo();
tripinfo=cat(3,miles,mins);

%%% pull out trip info for our drawn OD pairs
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% calculating/generating the parameters %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% C value is the 'service fee' plus 20% of the fare minus 0.28*[the wait
%%% time for the driver to get to the request]

%%% pij (var name is yprobs) is determined by the ratio of the driver's compensation and their
%%% extra driving time. This ratio is their perceived wage per hour, so pij
%%% will be 0 for $13 an hour or less, and increase linearly until pij=1 if
%%% they are paid $30 an hour or more
fare=repmat(max(1.79*ones(m,1)+0.81*OiDi(:,1)+0.28*OiDi(:,2),3*ones(m,1)),1,n);
C=1.85*ones(m,n)+(1-wage)*fare-0.28*0.2*OjOi(:,:,2);

wagemin=10;
wagemax=25;
extradrivingtime =(OjOi(:,:,2) + repmat(OiDi(:,2),1,n) + DiDj(:,:,2) -repmat(OjDj(:,2)',m,1))/60; %given in hours
yprobs=(wage*fare./extradrivingtime -wagemin*ones(m,n))/(wagemax-wagemin);
%edit values that were above 1 or below 0
yprobs=min(yprobs,ones(m,n));
yprobs=max(yprobs,zeros(m,n));
extradrivingmiles =(OjOi(:,:,1) + repmat(OiDi(:,1),1,n) + DiDj(:,:,1) -repmat(OjDj(:,1)',m,1)) ;




