function[obj,v2,x2,y2,w2,z2]=single_level_new_yconst(C,D,r,U,theta,add_utility)


addpath(genpath('C:\Users\hanna\OneDrive\Documents\MATLAB\yalmip'));
addpath('C:\Program Files\IBM\ILOG\CPLEX_Studio128\cplex\matlab\x64_win64')
addpath('C:\Program Files\IBM\ILOG\CPLEX_Studio128\cplex\examples\src\matlab')
[m,n]=size(C);



%Options = sdpsettings('solver','sdpa', 'sdpa.maxiteration',10,'verbose',0);
Options=sdpsettings('solver','cplex');
%cpxControl.ITLIM = 100;

%%% create variables
v = sdpvar(m,n,'full');
w = sdpvar(m,1,'full');
x = binvar(m,n,'full');
y = binvar(m,n,'full');
z = sdpvar(m,n,'full');

%%%%%%% build objective function
Obj = 0;
if add_utility==1
    for i=1:m
       Obj = Obj + C(i,:)*(v(i,:))' - D(i,:)*(z(i,:))' + 3*U(i,:)*(y(i,:))';
    end
else
    for i=1:m
       Obj = Obj + C(i,:)*(v(i,:))' - D(i,:)*(z(i,:))'; 
    end
end
Obj = Obj - r'*w;


%%%%%%%%% Outer constraints %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Const=[];

%%% menu size
for j=1:n
    Const=[Const, ones(1,m)*x(:,j) == theta];
end

%%% z constraint (driver accepts but is rejected)
for i=1:m
    for j=1:n
        Const=[Const, y(i,j)-v(i,j) <= z(i,j)];
    end
end

%%% unfulfilled requests
for i=1:m
    Const=[Const, 1-v(i,:)*ones(n,1) <= w(i)];
end

%%% simplified v constraint
for i=1:m
    Const=[Const, v(i,:)*ones(n,1) <= 1];
end


%%% can't assign a request to driver j if they didn't accept the request
for i=1:m
    for j=1:n
        Const=[Const, v(i,j) <= y(i,j)];
    end
end

%%% max number of choices
for j=1:n
    Const=[Const, ones(1,m)*y(:,j) <= 1];
end

%%% y range min
for i=1:m
    for j=1:n
        Const=[Const, y(i,j) >= 0];
    end
end

%%% y range max (real requests)
for i=1:m
    for j=1:n
        Const=[Const, y(i,j) <= x(i,j)];
    end
end


%%% each driver can't pick something that wasn't also accepted by at least
%%% one other driver
for i=1:m
    for j=1:n
        Const=[Const, y(i,j) <= y(i,:)*ones(n,1)-y(i,j)];
    end
end

Const=[Const, v>=0];%w>=0,z>=0];

%%%%%%%%%%% solve
solvesdp(Const,-Obj,Options);

obj=value(Obj);
x2=value(x);
v2=value(v);
y2=value(y);
z2=value(z);
w2=value(w);


