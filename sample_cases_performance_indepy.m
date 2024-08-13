function[objave,objsd,dupave,dupsd,rejave,rejsd,aveassign,objvals,vfull,zfull,wfull]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,testsamples,yhat,weights)
[m,n]=size(x);

%%% this code does the performance analysis of a solution for each of a set of
%%% inptutted test scenario and reports back the performance averages as
%%% well as the assignments information etc for each scenario.

%%% inputs: C and D are m x n arrays of those parameters, r is the m x 1 vector match
%%% bonus (i.e. the objective function is Cv +rw-Dz--so for SOL-IT and
%%% SOL-FR just let C=Chat-alpha-u and let r=0),  q is a col vector of how many requests each driver can be assigned,
%%%  x is m x n array of the menu, yprobs is the pij array, testsamples is
%%%  the number of test scenarios, this can be a number or the string 'all'
%%%  if you want to test over the exhaustive set of test scenarios, yhat is
%%%  the set of test scenarios of driver selections, each m x n scenario is
%%%  concatenated horizontally to the next scenario, weights is a 1 x
%%%  testsampls vector of the scenario liklihoods. If testsamples is 'all',
%%%  let yhat and weights just be 0.

%%% outputs: objave is the weighted average objective across the test
%%% scenarios (weights are scenario likelihood), objsd is the weighted standard
%%% deviation of the objective across the scenarios, dupave is the weighted average 
%number of unhappy driver requests (number of positive z_ij) across the test
%%% scenarios (weights are scenario likelihood), dupsd is the weighted standard
%%% deviation of the number of unhappy driver requests across the scenarios, 
%%% rejave is the weighted average number of unmatched requests (number of positive w_i) across the test
%%% scenarios (weights are scenario likelihood), rejsd is the weighted standard
%%% deviation of the number of unmatched requests across the scenarios,
%%% aveassign is an m x n array where entry ij is the portion of test
%%% scenarios in which request i is assigned to driver j, objvals is a 1 x
%%% testsamples vector of the objective values of each test scenario,
%%% vfull is the full test v array, that is, the assignment of every test scenario (m x n arrays
%%% concatenated horizontally), wfull is the unmatched request arrays
%%% of all of the test scenarios, concatenated horizontally, and zfull is
%%% the unhappy driver requests (z variable) of each test scenario,
%%% concatenated vertically
             

if size(yhat,2)==1
    %if testsamples is 'all' (so yhat=0), generate all distinct test
    %scenarios and scenario liklihoods
    nontrivial=size(find(yprobs<1 & x==1),1);

    if testsamples=='all'
        totscen=2^nontrivial;
    else
        totscen=testsamples;
    end
    %[yhat,weights]=performance_analysis_scens(x,yprobs,testsamples,0);
    [yhat,weights,scenbase,scenexp]=indepy_generate_scens(x.*yprobs,testsamples,0);
    
    
else
    totscen=size(yhat,2)/n;
end

%%%initialize vals
objvals = zeros(totscen,1);
dupvals = zeros(totscen,1);
rejvals = zeros(totscen,1);
vfull=zeros(m,n*totscen);
zfull=zeros(m,n*totscen);
wfull=zeros(m,totscen);
aveassign = zeros(m,n);



%%%%%%%%%%%%%%%%% for each test scenario run performance analysis

for k=1:totscen
    y= yhat(:,(k-1)*n+1:k*n);

   
       %%% performance analysis
   %   [obj,dup,rej,v,w,z]=approx_assgn(C,D,r,x,y);
    [obj,dup,rej,v,w,z]=menu_performance_indepy(C,D,r,q,x,y); 
    %alpha here is the alpha that says how many times something can be
    %assigned, not the network weight
%     if csv==1
%     fprintf(fid, '%f,%d,%d\n', obj,dup,rej) ;
%     end
    objvals(k,1)=obj;
    dupvals(k,1)=dup;
    rejvals(k,1)=rej;
    aveassign=aveassign + v*weights(1,k);
    vfull(:,(k-1)*n+1:k*n)=v;
    zfull(:,(k-1)*n+1:k*n)=z;
    wfull(:,k)=w;
end
 
weights=weights';

%calculate the average of the metrics
objave = (objvals')*weights/sum(weights);
objsd = std(objvals,weights);
dupave = (dupvals')*weights/sum(weights);
dupsd = std(dupvals,weights);
rejave = (rejvals')*weights/sum(weights);
rejsd = std(rejvals,weights);
aveassign = aveassign/sum(weights);
