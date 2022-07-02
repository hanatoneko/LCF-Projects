function[obj,v2,x2,y2,w2,z2]=reduced_varis(C,D,r,U,theta)
addpath(genpath('C:\Users\hanna\OneDrive\Documents\MATLAB\yalmip'));

[m,n]=size(C);


Options=sdpsettings('solver','cplex','bilevel.algorithm','external','cachesolvers',1,'verbose',0);

v = sdpvar(m,n,'full');
x = binvar(m,n,'full');
y = sdpvar(m,n,'full')

%%%%%%% build objective functions
Outobj = 0;
Inobj = 0;
for i=1:m
   Outobj = Outobj + C(i,:)*(v(i,:))' - D(i,:)*(y(i,:)-v(i,:))'-r(i)*(1-v(i,:)*ones(n,1));
   Inobj = Inobj + U(i,:)*(y(i,:))';
end



%%%%%%%%% Outer constraints %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Outconst=[];

%%% menu size
for j=1:n
    Outconst=[Outconst, ones(1,m)*x(:,j) == theta];
end


%%% simplified v constraint
for i=1:m
    Outconst=[Outconst, v(i,:)*ones(n,1) <= 1];
end

%Outconst=[Outconst, v>=0];


%%% can't assign a request to driver j if they didn't accept the request
for i=1:m
    for j=1:n
        Outconst=[Outconst, v(i,j) <= y(i,j)];
    end
end


%%%%%%%%%%%% inner constraints &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
Inconst=[];

%%% max number of choices
for j=1:n
    Inconst=[Inconst, ones(1,m)*y(:,j) <= 1];
end

%%% min number of choices
% for j=1:n
%     Inconst=[Inconst, ones(1,m)*y(:,j) >= 0];
% end

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
solvebilevel(Outconst,-Outobj,Inconst,-Inobj,y,Options);


obj=value(Outobj);
x2=value(x);
v2=value(v);
y2=value(y);
z2=value(y-v);
w2=value(ones(m,1)-v*ones(n,1));


