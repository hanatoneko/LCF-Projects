function[obj,v]=performance_max(C,D,r,q,x,yprobs)
%%% finds the maximum possible objective value out of all possible
%%% scenarios for a given menu. This was used for the theoretical bound
%%% 'error bar' stuff but was shown to have a much better observed error
%%% than the theoretical error bounds
[m,n]=size(C);

%includes sum_j v <=1, sum_i v<= q, z constraint 
rbig=r*ones(1,n);
obj=-C(:)-rbig(:);
A=zeros(m+n,m*n);
A(1:m,1:m*n)=repmat(eye(m),1,n);
A(m+1:m+n,1:m*n)=kron(eye(n),ones(1,m));
b=ones(m+n,1);
b(m+1:m+n,1)=q;
lb=zeros(m*n,1);
ub=vertcat(x(:));

ctype=char(ones([1 m*n])*('C'));

%ctype=zeros(2*m*n);
% ctype=string(ctype);
% ctype(1:m*n,1)=repmat('B',m*n,1);
% ctype(m*n+1:2*m*n,1)=repmat('C',m*n,1);
% for k=1:m*n
%     ctype(k)="B";
% end
% for k=1:m*n
%     ctype(m*n+k)="C";
% end

Aeq=[];
beq=[];
sostype='';
sosind=[];
soswt=[];

soln = cplexmilp(obj,A,b,Aeq,beq,sostype,sosind,soswt,lb,ub,ctype);
v=reshape(soln(1:m*n,1),[m,n]);



obj=-obj'*soln;
w=ones(m,1)-v*ones(n,1);
rej = nnz(w);

