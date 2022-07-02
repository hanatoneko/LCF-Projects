function[obj,dup,rej,v,w,z]=menu_performance_indepy(C,D,r,q,x,y)

%%% this code calculates the performance of a single test scenario. This is
%%% done by finding the optimal feasible assignment for the platform utilities etc in the 
%%%objective function given the single scenario of driver selections, then
%%%calculating the desired metrics to return 


%%% inputs:  C and D are m x n arrays from the formulation, r is the m x 1 vector match
%%% bonus (i.e. the objective function is Cv +rw-Dz where w is the binary vector representing 
%%% matched requests). For the formulations where compensation 
%%% is variable and part of the solution in addition to the menu (SOL-IT, SOL-FR, etc), the
%%% compensation for each driver-request pair should be built into C. q is a n x 1 vector of
%%% how many requests each driver can be assigned, x is the binary menu (m x n), and y is the binary driver selections for the scenario (m x n)

%%% outputs: obj is the objective function of the optimal assignemnt, dup
%%% is the number of requests accepted by an unhappy driver in the opt
%%% assign, rej is the number of unmatched requests in the opt assign, v, w
%%% and z are the assignment, rejections, and unhappy driver variables of
%%% the opt assign. For w, entry i is 1 if request i is unmatched

% Options=sdpsettings('solver','cplex','verbose',0,'cachesolvers',1);


[m,n]=size(C);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%I believe this code is from when i was running a different problem type on
%cplex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % %%%%%% find optimal v (and get z, w)
%  v = sdpvar(m,n,'full');
% % w = sdpvar(m,1);
% z = sdpvar(m,n,'full');
% % 
% % %%%%%%% build objective functions
% obj =ones(1,m)*(C.*v)*ones(n,1)-ones(1,m)*(D.*z)*ones(n,1)- r'*(ones(m,1)-v*ones(n,1));
% 
% %%%%%%%%% Constraints %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Const=[];
% 
% 
% %%% simplified v constraint
% 
% Const=[Const, v*ones(n,1) <= ones(m,1)];
% 
% %%% can't assign a request to driver j if they didn't accept the request
% 
% Const=[Const, v <= y.*x];
% 
% 
% %%% limit number of requests that can be assigned to driver j
% 
% Const=[Const, ones(1,m)*v <= alpha];
% 
% %%% z constraint
% 
% Const=[Const,z>=-2*ones(m,n)+ y + x + ones(m,n)-ones(m,m)*v];
% 
% %%% non-negativity
% Const=[Const,v>=0,z>=0];
% 
% %%%%%%%%%%% solve
% solvesdp(Const,-obj,Options);
% 
% %%% calculate z and w
% obj=value(obj);
% v=value(v);
% z=value(z);
% w=ones(m,1)-v*ones(n,1);
% 
% dup = nnz(z);
% rej = nnz(w);

%includes sum_j v <=1, sum_i v<= q, z constraint 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%build the optimization model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rbig=r*ones(1,n);
obj=vertcat(-C(:)-rbig(:),D(:));
A=zeros(m*n+m+n,2*m*n);
A(1:m,1:m*n)=repmat(eye(m),1,n);
A(m+1:m+n,1:m*n)=kron(eye(n),ones(1,m));
A(m+n+1:m+n+m*n,1:m*n)=kron(eye(n),-ones(m,m));
A(m+n+1:m+n+m*n,m*n+1:2*m*n)=-eye(m*n);
b=ones(m*n+m+n,1);
b(m+1:m+n,1)=q;
b(m+n+1:m+n+m*n,1)=b(m+n+1:m+n+m*n,1)-x(:)-y(:);

%upper and lower bounds
lb=zeros(2*m*n,1);
selects=x.*y;
ub=vertcat(selects(:),ones(m*n,1));
c1=char(ones([1 m*n])*('B'));
c2=char(ones([1 m*n])*('C'));
ctype=[c1 c2] ;
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

%%% solve
soln = cplexmilp(obj,A,b,Aeq,beq,sostype,sosind,soswt,lb,ub,ctype);
if size(soln,1)<m*n
    soln
end

%the solution is a single vector of variables plus info like objective and
%time, so we first extract that information then convert the single
%variable vector into an array for each variable to output (and calculate w
%since in the optimization model we just model it implicitly through v)

v=reshape(soln(1:m*n,1),[m,n]);
z=reshape(soln(m*n+1:2*m*n,1),[m,n]);


obj=-obj'*soln;
w=ones(m,1)-v*ones(n,1);
dup = nnz(z);
rej = nnz(w);

