function[obj,v2,x2,y2,w2,z2]=vectorized_simple(m,n,cbar,Abar,Bbar,bbar,Ubar,Cbar,gbar,Fbar)

addpath(genpath('C:\Users\hanna\OneDrive\Documents\MATLAB\yalmip'));
Options=sdpsettings('solver','cplex','bilevel.algorithm','external','cachesolvers',1);

v = sdpvar(m*n,1);
w = sdpvar(m,1);
x = binvar(m*n,1);
y = sdpvar(m*n,1);
z = sdpvar(m*n,1);


Outobj = cbar(1:m*n)'*v+cbar(2*m*n+1:3*m*n)'*z+cbar(3*m*n+1:3*m*n+m)'*w;


% Abar(:,1:m*n)
% Abar(:,m*n+1:2*m*n)
% Abar(:,2*m*n+1:3*m*n)
% Abar(:,3*m*n+1:3*m*n+m)
%  Bbar
% bbar
%Outconst = [ Abar(:,1:m*n)*v +Abar(:,m*n+1:2*m*n)*x +Abar(:,2*m*n+1:3*m*n)*z + Abar(:,3*m*n+1:3*m*n+m)*w + Bbar*y >= bbar];
Outconst = [v>=0, ...
    Abar(1:2*n,m*n+1:2*m*n)*x >= bbar(1:2*n),...
    Abar(2*n+1:2*n+m*n,1:m*n)*v + Abar(2*n+1: 2*n+m*n,2*m*n+1:3*m*n)*z + Bbar(2*n+1: 2*n+m*n,:)*y>= bbar(2*n+1: 2*n+m*n)...
    Abar(2*n+m*n+1: m+ 2*n+m*n,1:m*n)*v + Abar(2*n+m*n+1: m+ 2*n+m*n,3*m*n+1:3*m*n+m)*w >= bbar(2*n+m*n+1: m+ 2*n+m*n),...
    Abar(m+ 2*n+m*n+1: 2*m+ 2*n+m*n ,1:m*n)*v >= bbar(m+ 2*n+m*n+1: 2*m+ 2*n+m*n ),...
    Abar( 2*m+ 2*n+m*n+1: 2*m+ 2*n+2*m*n,1:m*n)*v  + Bbar(2*m+ 2*n+m*n+1: 2*m+ 2*n+2*m*n,:)*y>= 0];

Inobj = Ubar'*y;

% Cbar
% gbar
% Fbar(:,m*n+1:2*m*n)
Inconst = [Cbar*y >= gbar - Fbar(:,m*n+1:2*m*n)*x];
%Inconst = [y>=0,y<=1];
solvebilevel(Outconst,-Outobj,Inconst,-Inobj,y,Options);

obj=value(Outobj);
v2 = zeros(m,n);
w2 = value(w);
x2 = zeros(m,n);
y2 = zeros(m,n);
z2 =  zeros(m,n);
for j=1:n
    v2(:,j) = value(v((j-1)*m+1: j*m));
    x2(:,j) = value(x((j-1)*m+1: j*m));
    y2(:,j) = value(y((j-1)*m+1: j*m));
    z2(:,j) = value(z((j-1)*m+1: j*m));
end

