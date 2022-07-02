function[x0]=initialpoint(yprobs,yhat)
%builds an initial point xo that is a vector [x v z] to input to cplex
%this initial point is given by the assignment that maximizes the expected
%number of accepted requests (max one req per driver and one offer per req)
%then v is computed for each scenario (z is all zeros)

%%% build constraint matrices
[m,n]=size(yprobs);
s=size(yhat,2)/n;

A=repmat(speye(m),1,n);
b= ones(m,1);

Anew=kron(speye(n),ones(1,m));
bnew=ones(n,1);

A=vertcat(A,Anew);
b=vertcat(b,bnew);

ctype=char(ones([1 m*n])*('B'));
Aeq=[];
beq=[];
sostype='';
sosind=[];
soswt=[];
lb=zeros(m*n,1);
ub=ones(m*n,1);

xlong = cplexmilp(-yprobs(:),A,b,Aeq,beq,sostype,sosind,soswt,lb,ub,ctype);
x=repmat(reshape(xlong,[m,n]),1,s);
v=x.*yhat;
x0=vertcat(xlong,v(:),zeros(m*n*s,1));


