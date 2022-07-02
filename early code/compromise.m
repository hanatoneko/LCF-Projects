function[obj,v2,x2,xno2,y2,w2,z2]=compromise(C,d,r,a,U,Sorted,theta)
addpath(genpath('C:\Users\hanna\OneDrive\Documents\MATLAB\yalmip'));

%%% I believe this was when I was confused as to why Shahab's code was
%%% working and mine wasn't so I made a hybrid formulation that had my new
%%% v variables but also for ex kept his duplicate penalties as a vector
%%% instead of having different values for every request and driver
[m,n]=size(C);
[q,n]=size(U);
N=q-m;

Options = sdpsettings('solver','sdpa', 'sdpa.maxiteration',10);
Options=sdpsettings('solver','cplex','bilevel.algorithm','external');

v = sdpvar(m,n,'full');
w = sdpvar(m,1,'full');
x = binvar(m,n,'full');
xno = binvar(1,n,'full');
y = sdpvar((m+N),n,'full')
z = sdpvar(m,1,'full');

%%%%%%% build objective functions
Outobj = 0;
Inobj = 0;
for i=1:m
   Outobj = Outobj + C(i,:)*(v(i,:))';
   Inobj = Inobj + U(i,:)*(y(i,:))';
end

Outobj = Outobj - (d')*z - r'*w;
Inobj = Inobj + U(m+1,:)*(y(m+1,:))';

%%%%%%%%% Outer constraints %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Outconst=[];

%%% number of requests sent out
% for i=1:m
%     Outconst=[Outconst, x(i,:)*ones(n,1) <= a(i)];
% end

%%% make sure no-choice is offered
Outconst=[Outconst, xno*ones(n,1) == n];

%%% menu size
for j=1:n
    Outconst=[Outconst, ones(1,m)*x(:,j) == theta];
end

%%% z constraint (the number of extra drivers that accepted a request) also
%%% non-negativity bound
for i=1:m
    Outconst=[Outconst, y(i,:)*ones(n,1) <= z(i)+1, z(i)>=0];
end

%%% unfulfilled requests
for i=1:m
    Outconst=[Outconst, 1-v(i,:)*ones(n,1) <= w(i)];
end

%%% assignment based on cij and dij

for i=1:m
    set=[];
    for j=1:n
        %first get the index of the next highest element of row i of C+D
        current=Sorted(i,j);
        set=[set,current];
        for k=1:n
            %check if k> current j, i.e. is k in set
            isgreater=0;
            for p=1:j % the length of set will be j so we're checking each entry
                if set(p)==k
                    isgreater=1;
                    continue
                end    
            end
            if isgreater==0
                Outconst=[Outconst, v(i,k) <= 1-y(i,current)];                
            end
        end
    end
end

%%% can't assign a request to driver j if they didn't accept the request
for i=1:m
    for j=1:n
        Outconst=[Outconst, v(i,j) <= y(i,j)];
    end
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
    Inconst=[Inconst, y(N+m,j) <= xno(1,j)];
end

%%%%%%%%%%% solve
solvebilevel(Outconst,-Outobj,Inconst,-Inobj,y);

obj=value(Outobj);
x2=value(x);
xno2=value(xno);
v2=value(v);
y2=value(y);
z2=value(z);
w2=value(w);


