function[obj,dup,rej,v,w,z]=performance_min(C,D,r,q,x,yprobs)
%%% finds a lower bound for the lowest possible objective value out of all possible
%%% scenarios for a given menu (since it would be difficult to find the exact 
%%% lower bound. This was used for the theoretical bound
%%% 'error bar' stuff but was shown to have a much better observed error
%%% than the theoretical error bounds
[m,n]=size(C);

%includes sum_j v <=1, sum_i v<= q, z constraint 
rbig=r*ones(1,n);
obj=vertcat(-C(:)-rbig(:),D(:));
A=zeros(2*m*n+m+n,2*m*n);
b=ones(2*m*n+m+n,1);

%%% each req assn at most once (sum_j v<=1 )
A(1:m,1:m*n)=repmat(eye(m),1,n);


%%% at most q assnm per driver   (sum_i v<=q )
A(m+1:m+n,1:m*n)=kron(eye(n),ones(1,m));
b(m+1:m+n,1)=q;

%%% z const, z can only be 1 if driver assigned nothing z<= (q-sum_i v)/q
A(m+n+1:m+n+m*n,1:m*n)=kron(eye(n),ones(m,m)); %%%% include q
for j=1:n
    A(m+n+(j-1)*m+1:m+n+m*j,(j-1)*m+1:m*j)= A(m+n+(j-1)*m+1:m+n+m*j,(j-1)*m+1:m*j)/q(j,1);
end
A(m+n+1:m+n+m*n,m*n+1:2*m*n)=eye(m*n);

%%% z const, zij can only be one if i was assigned to someone z<=sum_j v
A(m+n+m*n+1:m+n+2*m*n,1:m*n)=repmat(-eye(m),n,n);
A(m+n+m*n+1:m+n+2*m*n,m*n+1:2*m*n)=eye(m*n);
b(m+n+m*n+1:m+n+2*m*n,1)=zeros(m*n,1);



lb=zeros(2*m*n,1);
ub=vertcat(x(:),x(:));
ctype=char(ones([1 2*m*n])*('B'));

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

soln = cplexmilp(-obj,A,b,Aeq,beq,sostype,sosind,soswt,lb,ub,ctype);
v=reshape(soln(1:m*n,1),[m,n]);
z=reshape(soln(m*n+1:2*m*n,1),[m,n]);


obj=-obj'*soln;
w=ones(m,1)-v*ones(n,1);
dup = nnz(z);
rej = nnz(w);

