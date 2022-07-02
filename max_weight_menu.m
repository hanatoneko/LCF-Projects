function[obj,x]=max_weight_menu(weights,theta)

%this code makes menu to maximize the weight of the menu, each driver must be recommended theta
%requests and each request must be offered to theta drivers and (code would need to adjust this number
%if the number of requests is different from the number of drivers).  This
%is how all four heuristic methods are solve (CLOS-1, CLOS-5, LIK-1,
%LIK-5), where the weights are (the negative of the) travel time or are the
%pij, respectively

%inputs: weights are an m x n matrix of the 'weight' of each driver-request
%pair, theta is the menu size

% Options=sdpsettings('solver','cplex','verbose',0,'cachesolvers',1);


[m,n]=size(weights);



obj=-weights(:);

%%% menu size max %%%%%%%%%%%%%%%%%%%
Anew=kron(speye(n),ones(1,m));
bnew=theta*ones(n,1);


Am=Anew;
bm=bnew;

%%% menu size min %%%%%%%%%%%%%%%%%%%%%%%
% Anew is just the negative of the previous Anew

bnew= -theta*ones(n,1);


Am=vertcat(Am,-Anew);
bm=vertcat(bm,bnew);

%%% can offer each item theta times (sum_j x_ij<=theta) %%%%%%%%%%%%%%%%%%%%%%%%%%%%


Anew=repmat(speye(m),1,n);
bnew= theta*ones(m,1);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% can offer each item theta times (sum_j x_ij>=theta) %%%%%%%%%%%%%%%%%%%%%%%%%%%%


Anew=repmat(-speye(m),1,n);
bnew= -theta*ones(m,1);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% variable upper and lower bounds
lb=zeros(m*n,1);
ub=ones(m*n,1);
c1=char(ones([1 m*n])*('B'));
ctype=[c1] ;

Aeq=[];
beq=[];
sostype='';
sosind=[];
soswt=[];

%solve cplex
soln = cplexmilp(obj,Am,bm,Aeq,beq,sostype,sosind,soswt,lb,ub,ctype);
x=reshape(soln,[m,n]); %reshape the solution x from a vector into a matrix


obj=-obj'*soln; %calculate objective


