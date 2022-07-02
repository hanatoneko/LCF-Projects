C =[    1.3147    0.7785    1.4572    1.2922    1.1787    1.2060;
    1.4058    1.0469    0.9854    1.4595    1.2577    0.5318;
    0.6270    1.4575    1.3003    1.1557    1.2431    0.7769;
    1.4134    1.4649    0.6419    0.5357    0.8922    0.5462;
    1.1324    0.6576    0.9218    1.3491    1.1555    0.5971;
    0.5975    1.4706    1.4157    1.4340    0.6712    1.3235];

yprobs =[    0.5926    0.3650    0.4315    0.7981    0.4999    0.7265;
    0.5366    0.3379    0.6010    0.3391    0.7553    0.6110;
    0.5749    0.7670    0.4556    0.5692    0.3422    0.3725;
    0.7154    0.6896    0.3828    0.3762    0.4299    0.5749;
    0.6080    0.3270    0.5643    0.7129    0.7000    0.5566;
    0.4758    0.5654    0.6270    0.5213    0.5157    0.4755];

yprobs1 =[    0.5230    0.4228    0.7441    0.4481    0.6331    0.7412;
    0.7457    0.6045    0.6837    0.6483    0.3688    0.5587;
    0.7425    0.7783    0.4763    0.4450    0.5492    0.4368;
    0.4976    0.4301    0.7507    0.3986    0.7450    0.3776;
    0.7362    0.3865    0.4926    0.3336    0.3006    0.5703;
    0.4911    0.3232    0.3380    0.3787    0.7425    0.5025];


converged=[ 0     0     0     0     0     1;
     0     0     0     0     1     0;
     0     1     0     0     0     0;
     1     0     0     0     0     0;
     0     0     0     1     0     0;
     0     0     1     0     0     0];
 
 %%%%%%%%%%% solve for opt assignment
 addpath(genpath('C:\Users\hanna\OneDrive\Documents\MATLAB\yalmip'));
 addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio128\cplex\matlab\x64_win64'));

 Options=sdpsettings('solver','cplex','verbose',0,'cachesolvers',1);


[m,n]=size(C);

% %%%%%% find optimal v (and get z, w)

 v = sdpvar(m,n,'full');
% w = sdpvar(m,1);
% z = sdpvar(m,n,'full');
% 
% %%%%%%% build objective functions
obj = 0;
for i=1:m
   obj = obj + yprobs1(i,:)*(v(i,:))';
  
end

%%%%%%%%% Constraints %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Const=[];


%%% simplified v constraint

Const=[Const, v*ones(n,1) <= ones(m,1)];

%%% limit number of requests that can be assigned to driver j

Const=[Const, ones(1,m)*v <= ones(1,n)];

%%% non-negativity
Const=[Const,v>=0];

%%%%%%%%%%% solve
solvesdp(Const,-obj,Options);

optassign=value(v)
