function[obj,v2,x2,y2,w2,z2]=bilevel_interdict(C,D,r,U,theta)
addpath(genpath('C:\Users\hanna\OneDrive\Documents\MATLAB\yalmip'));

[m,n]=size(C);


Options=sdpsettings('solver','cplex','bilevel.algorithm','external','cachesolvers',1);

v = sdpvar(m,n,'full');
w = sdpvar(m,1);
x = binvar(m,n,'full');
y = sdpvar(m,n,'full');
z = sdpvar(m,n,'full');

%%%%%%% build objective functions
Outobj = 0;
for i=1:m
   Outobj = Outobj + C(i,:)*(v(i,:))' - D(i,:)*(z(i,:))';
end

Outobj = Outobj - r'*w;


%%%%%%%%% Outer constraints %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% menu size
Outconst=[];
for j=1:n
    Outconst=[Outconst,ones(1,m)*x(:,j) == theta];
end






%%%%%%%%%%%% inner constraints &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
Inconst=[];

%%% can't assign a request to driver j if they didn't accept the request
for i=1:m
    for j=1:n
        Inconst=[Inconst, v(i,j) <= y(i,j)];
    end
end

%%% simplified v constraint
% for i=1:m
%     Inconst=[Inconst, v(i,:)*ones(n,1) <= 1];
% end

for i=1:m
    for j=1:n
        Inconst=[Inconst, v(i,:)*ones(n,1) >= y(i,j)];
    end
end

%Inconst=[Inconst, v>=0];

%%% z constraint (driver accepts but is rejected)
for i=1:m
    for j=1:n
        Inconst=[Inconst, y(i,j)-v(i,j) >= z(i,j)];
    end
end

%%% w unfulfilled requests
for i=1:m
    Inconst=[Inconst, 1-v(i,:)*ones(n,1) >= w(i)];
end


%%% max number of choices
for j=1:n
    Inconst=[Inconst, ones(1,m)*y(:,j) <= 1];
end

%%% y range min
for i=1:m
    for j=1:n
        Inconst=[Inconst, y(i,j) >= 0];
    end
end

%%% y range max
for i=1:m
    for j=1:n
        Inconst=[Inconst, y(i,j) <= x(i,j)];
    end
end


%%%%%%%%%%% solve

solvebilevel(Outconst,-Outobj,Inconst,Outobj,[y v z w],Options);


obj=value(Outobj);
x2=value(x);
v2=value(v);
y2=value(y);
z2=value(z);
w2=value(w);


