function[obj,x]=network_fixed_y_prob(Gamma,pen,theta,yprobs)


addpath(genpath('C:\Users\hanna\OneDrive\Documents\MATLAB\yalmip'));
addpath('C:\Program Files\IBM\ILOG\CPLEX_Studio128\cplex\matlab\x64_win64')
addpath('C:\Program Files\IBM\ILOG\CPLEX_Studio128\cplex\examples\src\matlab')
[m,n]=size(pen);



Options=sdpsettings('solver','cplex','verbose',0);


%%% create variables
x = sdpvar(m,n,'full');
f = sdpvar(m,n,'full');

%alpha = sdpvar(m,n*s,'full');
%beta = sdpvar(m,n*s,'full');

%%%%%%% build objective function
obj = sum(sum(x.*Gamma + f.*pen ));


%%%%%%%%% Constraints %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Const=[];

%%%% outflow equals menu size
Const=[Const, ones(1,m)*x==theta*ones(1,n)];

%%%% flow conservatin
Const=[Const, x*ones(n,1)==f*ones(n,1)];

%%%% flow capacities
Const=[Const, x>=zeros(m,n), x<=ones(m,n),f>=zeros(m,n), f<=ones(m,n)];

%%%%%%%%%%% solve
solvesdp(Const,-obj,Options);

obj=value(obj);
x=value(x);
f=value(f);




