function[obj,x2,v2,z2,w2]=fixed_y_prob_linear(C,D,r,theta,y,p)


addpath(genpath('C:\Users\hanna\OneDrive\Documents\MATLAB\yalmip'));
addpath('C:\Program Files\IBM\ILOG\CPLEX_Studio128\cplex\matlab\x64_win64')
addpath('C:\Program Files\IBM\ILOG\CPLEX_Studio128\cplex\examples\src\matlab')
[m,n]=size(C);
s=size(y,2)/n;


Options=sdpsettings('solver','cplex');


%%% create variables
x = binvar(m,n,'full');
v = sdpvar(m,n*s,'full');
z = sdpvar(m,n*s,'full');
alpha = sdpvar(m,n*s,'full');
beta = sdpvar(m,n*s,'full');

%%%%%%% build objective function
Obj = 0;

for k=1:s
    for i=1:m
        Obj = Obj + p(1,s)*( C(i,:)*(v(i,(k-1)*n+1:(k-1)*n+n))' - D(i,:)*z(i,(k-1)*n+1:(k-1)*n+n)'-r(i)*(1-(v(i,(k-1)*n+1:(k-1)*n+n)*ones(n,1))) );
    end
end



%%%%%%%%% Constraints %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Const=[];

%%% menu size
Const=[Const, ones(1,m)*x == theta*ones(1,n)];


%%% can't assign something not offered
for k=1:s
    Const=[Const, v(:,(k-1)*n+1:(k-1)*n+n) <= x];
end

%%% can't assign something not accepted
Const=[Const, v <= y];


%%% can only assign each request once
for k=1:s
    Const=[Const, v(:,(k-1)*n+1:(k-1)*n+n)*ones(n,1) <= ones(m,1)];
end

%%% max one request per driver
for k=1:s
    Const=[Const, ones(1,m)*v(:,(k-1)*n+1:(k-1)*n+n) <= ones(1,n)];
end

%%% was the request offered and selected?
for k=1:s
    Const=[Const, alpha(:,(k-1)*n+1:(k-1)*n+n) >= -ones(m,n) + y(:,(k-1)*n+1:(k-1)*n+n) + x];
end

%%% was the request [offered and selected] ^ not assigned?
Const=[Const, beta>= -ones(size(y)) + alpha + (ones(size(y))-v)];


%%% z constraint (driver accepts but is rejected)
for k=1:s
    Const=[Const, z(:,(k-1)*n+1:(k-1)*n+n) >=beta(:,(k-1)*n+1:(k-1)*n+n) - ones(m,m)*v(:,(k-1)*n+1:(k-1)*n+n)];
end

%%% cutting plane
for k=1:s
   Const = [Const, ones(1,m)*z(:,(k-1)*n+1:(k-1)*n+n)*ones(n,1) >= (ones(1,m)*alpha(:,(k-1)*n+1:(k-1)*n+n)*ones(n,1))/theta - ones(1,m)*v(:,(k-1)*n+1:(k-1)*n+n)*ones(n,1)];
end


%%% nonnegativity
Const=[Const, v>=0, z>=0];

%%%%%%%%%%% solve
solvesdp(Const,-Obj,Options);

obj=value(Obj);
x2=value(x);
v2=value(v);
z2=value(z);
%alpha=value(alpha);
%beta=value(beta);
w2=zeros(m,s);
for k=1:s
       w2(:,k)= ones(m,1)-v(:,1+(k-1)*n:k*n)*ones(n,1);
end


