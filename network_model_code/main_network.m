m=6;
n=6;
theta=3;
kpercentage=1; %the portion of requests that have a positive p_ij
samples=10; %numsamples
equal=0;
lwr=1;
alpha=m*ones(1,n);
addpath(genpath('C:\Users\hanna\OneDrive\Documents\MATLAB\yalmip'));
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio128\cplex\matlab\x64_win64'));

%yalmiptest();%sdpsettings('verbose',0,'solver','sedumi'))
%options = sdpsettings('cachesolvers',1);

% generate the data
[C,D,r,U]=data_generation(m,n)
[topkpicks,yprobs]=indepy_generate_yprobs(m,n,kpercentage);


%%% adjust popularity
%yprobs=min(ones(m,n),2*yprobs);
yprobs(1:2,:)=min(1.5*yprobs(1:2,:),ones(2,n));
yprobs(5:6,:)=.5*yprobs(5:6,:);
yprobs

C=  [ 0.9018    0.9173    0.8377    0.7417    1.0752    0.5430;
    0.5760    0.5497    1.4001    0.9039    0.5598    0.6690;
    0.7399    1.4027    0.8692    0.5965    0.7348    1.1491;
    0.6233    1.4448    0.6112    0.6320    0.8532    1.2317;
    0.6839    0.9909    1.2803    1.4421    1.3212    1.1477;
    0.7400    0.9893    0.8897    1.4561    0.5154    0.9509];



Gamma=2*yprobs+C;
pen=-1*ones(m,n);
pen(:,1)=C*ones(n,1);
pen(:,3)=-2*ones(m,1); 
pen(:,4)=-3*ones(m,1); 
pen(:,5)=-4*ones(m,1); 
pen(:,6)=-5*ones(m,1); 

%%% adjust popularity
pen(1:2,2:n)=1.5*pen(1:2,2:n);
pen(5:6,2:n)=.5*pen(5:6,2:n);
pen
[obj,x,f]=network_fixed_y_prob(Gamma,pen,theta,yprobs);
x

y = binornd(ones(m,n),yprobs)

[obj,dup,rej,v,w,z]=approx_assgn(C,D,r,x,y);
v
obj
[obj,dup,rej,v,w,z]=menu_performance_indepy(C,D,r,alpha,x,y);
v
obj

