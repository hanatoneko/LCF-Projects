function[obj,v2,x2,y2,w2,z2]=block_vectorized_simple(m,n,cbar,Abar,Bbar,bbar,Ubar,Cbar,gbar,Fbar)

addpath(genpath('C:\Users\hanna\OneDrive\Documents\MATLAB\yalmip'));
Options=sdpsettings('solver','cplex','bilevel.algorithm','external','cachesolvers',1);


x = sdpvar(3*m*n+m,1);
xbin = binvar(m*n,1);
y = sdpvar(m*n,1);

Outobj = cbar'*x; 
Inobj = Ubar'*y;

Outconst = [Abar*x + Bbar*y >= bbar, xbin==x(m*n+1:2*m*n,1)];
Inconst =  [Cbar*y >= gbar - Fbar*x];

solvebilevel(Outconst,-Outobj,Inconst,-Inobj,y,Options);


% take the long vector of variables and arrange them into the
% easily-readable separate variable matrices
obj=value(Outobj);
v2 = zeros(m,n);
w2 = value(x(3*m*n+1:3*m*n+m));
x2 = zeros(m,n);
y2 = zeros(m,n);
z2 =  zeros(m,n);
for j=1:n
    v2(:,j) = value(x((j-1)*m+1: j*m));
    x2(:,j) = value(x(m*n+(j-1)*m+1: (j+n)*m));
    y2(:,j) = value(y((j-1)*m+1: j*m));
    z2(:,j) = value(x(2*m*n+(j-1)*m+1: (j+2*n)*m));
end

