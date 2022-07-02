function[obj,v2,x2,y2,w2,z2]=saa_bilevel(C,D,r,U,theta,equal,lwr)
addpath(genpath('C:\Users\hanna\OneDrive\Documents\MATLAB\yalmip'));

[m,n]=size(C);
s=size(U,2)/n;


Options=sdpsettings('solver','cplex','bilevel.algorithm','external','cachesolvers',1,'verbose',0);

v = sdpvar(m,n*s,'full');
x = binvar(m,n,'full');
y = sdpvar(m,n*s,'full')

%%%%%%% build objective functions
%%%make a repeatedly concatonated C, D, r (s copies)
C2=C;
D2=D;
r2=r;
for i=1:s-1
    C2=horzcat(C2,C);
    D2=horzcat(D2,D);
    r2=horzcat(r2,r);
end


Outobj = 0;
Inobj = 0;
for i=1:m
   Outobj = Outobj + C2(i,:)*(v(i,:))' - D2(i,:)*(y(i,:)-v(i,:))'
   for k=1:s
       Outobj = Outobj - r2(i,k)*(1-v(i,1+(k-1)*n:k*n)*ones(n,1));
   end
   Inobj = Inobj + U(i,:)*(y(i,:))';
end
Outobj = Outobj/s;


%%%%%%%%% Outer constraints %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Outconst=[];

%%% menu size
if equal==1
    for j=1:n
        Outconst=[Outconst, ones(1,m)*x(:,j) == theta];
    end
else
    for j=1:n
        Outconst=[Outconst, ones(1,m)*x(:,j) <= theta];
    end
    if lwr==1 
        for j=1:n
            Outconst=[Outconst, ones(1,m)*x(:,j) >= 1];
        end
    end
end




%%% simplified v constraint
for i=1:m
    for k=1:s
     Outconst=[Outconst, v(i,1+(k-1)*n:k*n)*ones(n,1) <= 1];
    end
end

%Outconst=[Outconst, v>=0];


%%% can't assign a request to driver j if they didn't accept the request
for i=1:m
    for j=1:n*s
        Outconst=[Outconst, v(i,j) <= y(i,j)];
    end
end


%%%%%%%%%%%% inner constraints &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
Inconst=[];

%%% max number of choices
for j=1:n*s
    Inconst=[Inconst, ones(1,m)*y(:,j) <= 1];
end

%%% min number of choices
% for j=1:n
%     Inconst=[Inconst, ones(1,m)*y(:,j) >= 0];
% end

%%% y range min
for i=1:m
    for j=1:n*s
        Inconst=[Inconst, y(i,j) >= 0];
    end
end

%%% y range max
for i=1:m
    for j=1:n
        for k=1:s
            Inconst=[Inconst, y(i,j+(k-1)*n) <= x(i,j)];
        end
    end
end


%%%%%%%%%%% solve
solvebilevel(Outconst,-Outobj,Inconst,-Inobj,y,Options);

obj=value(Outobj);
x2=value(x);
v2=value(v);
y2=value(y);
z2=value(y-v);
w2=zeros(m,s);
for k=1:s
       w2(:,k)= ones(m,1)-v(:,1+(k-1)*n:k*n)*ones(n,1);
end


