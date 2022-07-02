function[obj,x2,xno2,y2,w2,z2]=origform(C,d,r,U,theta)
addpath(genpath('C:\Users\hanna\OneDrive\Documents\MATLAB\yalmip'));

[m,n]=size(C);
[q,n]=size(U);
N=q-m; %check if no-choice=1


%Options = sdpsettings('solver','sdpa', 'sdpa.maxiteration',10);
%opt = cplexoptimset('cplex'); 
%opt.mip.limits.nodes=20;
%options = cplexoptimset('Diagnostics', 'on', 'MaxNodes', 40000);
Options=sdpsettings('solver','cplex','bilevel.algorithm','external','cachesolvers',1);
%cpxControl.ITLIM = 100;
%[C,D,r,a,U,Sorted]=data_generation(m,n,N);

w = sdpvar(m,1);
x = binvar(m,n,'full');
xno = binvar(1,n); %we'll use a separate variable vector for the no-choice 
y = sdpvar((m+N),n,'full')
z = sdpvar(m,1);

%%%%%%% build objective functions
Outobj = 0;
Inobj = 0;
for i=1:m
   Outobj = Outobj + C(i,:)*(y(i,:))';
   Inobj = Inobj + U(i,:)*(y(i,:))';
end

Outobj = Outobj - (d')*z - (r')*w ;

Inobj = Inobj + U(m+1,:)*(y(m+1,:))';

%%%%%%%%% Outer constraints %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Outconst=[];

%%% number of drivers a request can be sent to
%  for i=1:m
%      Outconst=[Outconst, x(i,:)*ones(n,1) <= 5];
%  end

%%% make sure no-choice is offered
Outconst=[Outconst, xno*ones(n,1) == n];

%%% menu size
for j=1:n
    Outconst=[Outconst, ones(1,m)*x(:,j) == theta];
end

%%% z constraint (driver accepts but is rejected)
for i=1:m
    Outconst=[Outconst, y(i,:)*ones(n,1) <= z(i)+1];
end

%%% unfulfilled requests
for i=1:m
    Outconst=[Outconst, 1-y(i,:)*ones(n,1) <= w(i)];
end

%%% Bounds for z, w
for i=1:m
    Outconst=[Outconst, z(i)>=0, w(i)>=0];
end


%Outconst
%%%%%%%%%%%% inner constraints &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
Inconst=[];

%%% max number of choices
for j=1:n
    Inconst=[Inconst, ones(1,(m+1))*y(:,j) <= 1];
end

%%% min number of choices
for j=1:n
    Inconst=[Inconst, ones(1,(m+1))*y(:,j) >= 1];
end

%%% y range min
for i=1:m+N
    for j=1:n
        Inconst=[Inconst, y(i,j) >= 0];
    end
end

%%% y range max (real requests)
for i=1:m
    for j=1:n
        Inconst=[Inconst, y(i,j) <= x(i,j)];
    end
end

%%% y range max (no-request)
for j=1:n
    Inconst=[Inconst, y(N+m,j) <= 1];%xno(1,j)];
end

%%%%%%%%%%% solve
solvebilevel(Outconst,-Outobj,Inconst,-Inobj,y,Options);

obj=value(Outobj);
x2=value(x);
xno2=value(xno);
y2=value(y);
z2=value(z);
w2=value(w);


