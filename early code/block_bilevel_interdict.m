function[obj,v2,x2,y2,w2,z2]=block_bilevel_interdict(m,n,cbint,Abint,bbint,Cbint,gbint,Fbint)

addpath(genpath('C:\Users\hanna\OneDrive\Documents\MATLAB\yalmip'));
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio128\cplex\matlab\x64_win64'));
Options=sdpsettings('solver','cplex','bilevel.algorithm','external','cachesolvers',1);
% cplex = cplexoptimset('cplex');
% cplex.output.clonelog = 0;


x = binvar(m*n,1);
y = sdpvar(3*m*n+m,1);

Outobj = cbint'*y; 

Outconst = [Abint*x >= bbint];
Inconst =  [Cbint*y >= gbint - Fbint*x];

solvebilevel(Outconst,-Outobj,Inconst,Outobj,y,Options);


% take the long vector of variables and arrange them into the
% easily-readable separate variable matrices
obj=value(Outobj);
v2 = zeros(m,n);
w2 = value(y(3*m*n+1:3*m*n+m));
x2 = zeros(m,n);
y2 = zeros(m,n);
z2 =  zeros(m,n);
for j=1:n
    v2(:,j) = value(y((j-1)*m+1: j*m));
    y2(:,j) = value(y(m*n+(j-1)*m+1: (j+n)*m));
    x2(:,j) = value(x((j-1)*m+1: j*m));
    z2(:,j) = value(y(2*m*n+(j-1)*m+1: (j+2*n)*m));
end

