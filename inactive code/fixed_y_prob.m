function[obj,x,v,z,w]=fixed_y_prob(C,D,r,theta,q,yhat,scenprobs,equal,lwr,x0,timelim,display)

%bit='done generating yhat'
[m,n]=size(C);
s=size(yhat,2)/n; %number of samples


%options = cplexoptimset('mip.strategy.variableselect',3);
if timelim~='inf'
    if display~=0
        options = cplexoptimset('MaxTime',timelim,'TolXInteger',1);
%         options =cplexoptimset('cplex'); 
%         %options.display = 'on'; 
%         options.timelimit.set(100);                 
%         %options.mip.tolerances.mipgap=0.01;  
    else
        options = cplexoptimset('MaxTime',timelim,'Display',0);
    end
else
    options = cplexoptimset('Display',0);
end
%options = cplexoptimset('workmem', 8192.0,'mip.strategy.file', 2,'mip.strategy.variableselect',3 ) ;
%Options=sdpsettings('solver','cplex','verbose',0);


% %%% create variables
% x = binvar(m,n,'full');
% v = binvar(m,n*s,'full');
% z = sdpvar(m,n*s,'full');
% %alpha = sdpvar(m,n*s,'full');
% %beta = sdpvar(m,n*s,'full');
% 
% %%%%%%% build objective function
% Obj = 0;
% 
% for k=1:s
%     for i=1:m
%         Obj = Obj + scenprobs(1,k)*( C(i,:)*(v(i,(k-1)*n+1:(k-1)*n+n))' - D(i,:)*z(i,(k-1)*n+1:(k-1)*n+n)'-r(i)*(1-(v(i,(k-1)*n+1:(k-1)*n+n)*ones(n,1))) );
%     end
% end
% 
% Obj=Obj/(scenprobs*ones(s,1));
% 
% %%%%%%%%% Constraints %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Const=[];
% 
% %%% menu size
% if equal==1   
%     Const=[Const, ones(1,m)*x == theta*ones(1,n)];
% else
%     Const=[Const, ones(1,m)*x <= theta*ones(1,n)];
%     if lwr==1
%         Const=[Const, ones(1,m)*x >= ones(1,n)];
%     end
% end
% 
% %%% limit number of requests that can be assigned to driver j
% for k=1:s
%     Const=[Const, ones(1,m)*v(:,(k-1)*n+1:k*n) <= a];
% end
% 
% %%% menu can only contain requests supplier might accept
% for j=1:n
%     for i=1:m
%         if ~ismember(i,topkpicks(:,j))
%             Const=[Const, x(i,j)==0];
%             for k=1:s
%                 Const=[Const, z(i,(k-1)*n+j)==0];
%             end
%         end
%     end
% end
% 
% %%% can't assign something not offered
% for k=1:s
%     Const=[Const, v(:,(k-1)*n+1:(k-1)*n+n) <= x];
% end
% 
% %%% can't assign something not accepted
% Const=[Const, v <= y];
% 
% 
% %%% can only assign each request once
% for k=1:s
%     Const=[Const, v(:,(k-1)*n+1:(k-1)*n+n)*ones(n,1) <= ones(m,1)];
% end
% 
% %%% max one request per driver
% for k=1:s
%     Const=[Const, ones(1,m)*v(:,(k-1)*n+1:(k-1)*n+n) <= ones(1,n)];
% end
% 
% %%% z constraint (driver accepts but is rejected)
% for k=1:s
%     Const=[Const, z(:,(k-1)*n+1:(k-1)*n+n) >= -2*ones(m,n)+ y(:,(k-1)*n+1:(k-1)*n+n) + x + (ones(m,n)-ones(m,m)*v(:,(k-1)*n+1:(k-1)*n+n))];
% end
% 
% %%% nonnegativity
% Const=[Const, v>=0,z>=0];
% 
% %%%%%%%%%%% solve
% solvesdp(Const,-Obj,Options);
% 
% obj=value(Obj);
% x2=value(x);
% v2=value(v);
% z2=value(z);
% w2=zeros(m,s);
% for k=1:s
%        w2(:,k)= ones(m,1)-v(:,1+(k-1)*n:k*n)*ones(n,1);
% end

%%% objective
obj=zeros(m*n+2*m*n*s,1);
block=repmat(scenprobs,m*n,1);
obj(m*n+1:m*n+m*n*s,1)=((repmat(C(:),s,1)+repmat(r,n*s,1)).*block(:))/sum(scenprobs);
obj(m*n+m*n*s+1:m*n+2*m*n*s,1)=repmat(-D(:),s,1).*block(:)/sum(scenprobs);



%%% menu size max %%%%%%%%%%%%%%%%%%%
Anew=sparse(n,m*n+2*m*n*s);
Anew(:,1:m*n)=kron(speye(n),ones(1,m));
bnew=theta*ones(n,1);

A=Anew;
b=bnew;

%%% menu size min %%%%%%%%%%%%%%%%%%%%%%%
% Anew is just the negative of the previous Anew
if equal==1
    bnew=-theta*ones(n,1);
else
    bnew= -lwr*ones(n,1);
end

A=vertcat(A,-Anew);
b=vertcat(b,bnew);


%%% v bound (can only assign if offered and accepted) %%%%%%%%%%%%%%%
Anew=sparse(m*n*s,m*n+2*m*n*s);
Anew(:,1:m*n)=repmat(-0.5*speye(m*n),s,1);
Anew(:,m*n+1:m*n+m*n*s)= speye(m*n*s);
bnew= 0.5*yhat(:);

A=vertcat(A,Anew);
b=vertcat(b,bnew);

%%% can assign each item once %%%%%%%%%%%%%%%%%%%%%%%%%%%%

Anew=sparse(m*s,m*n+2*m*n*s);
Anew(:,m*n+1:m*n+m*n*s)=kron(speye(s),repmat(speye(m),1,n));
bnew= ones(m*s,1);

A=vertcat(A,Anew);
b=vertcat(b,bnew);

%%% limit number of items assigned to each driver %%%%%%%%%%%%%%%%%%%%%%%%%%%%

Anew=sparse(n*s,m*n+2*m*n*s);
Anew(:,m*n+1:m*n+m*n*s)=kron(speye(n*s),ones(1,m));
bnew=repmat(q,s,1);

A=vertcat(A,Anew);
b=vertcat(b,bnew);

%%% z constraint %%%%%%%%%%%%%%%
Anew=sparse(m*n*s,m*n+2*m*n*s);
Anew(:,1:m*n)=repmat(speye(m*n),s,1);
Anew(:,m*n+1:m*n+m*n*s)=kron(speye(n*s),-ones(m,m));
Anew(:,m*n+m*n*s+1:m*n+2*m*n*s)= -speye(m*n*s);
bnew= ones(m*n*s,1)-yhat(:);

A=vertcat(A,Anew);
b=vertcat(b,bnew);

%%% lb, ub, and ctype %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%get approximate yprobs to use as bound since items with p_ij=0 shouldn't
%be offered
yprobsapprox=zeros(m,n);
for k=1:s
    yprobsapprox=yprobsapprox + yhat(:,(k-1)*n +1: k*n);
end
yprobsapprox=yprobsapprox/s;
lb=zeros(m*n+2*m*n*s,1);
ub=vertcat(ceil(yprobsapprox(:)),ones(2*m*n*s,1));

% ctype=zeros(m*n+2*m*n*s,1);
% ctype=string(ctype);
% ctype(1:m*n+m*n*s,1)=repmat('B',m*n+m*n*s,1);
% ctype(m*n+m*n*s+1:m*n+2*m*n*s)=repmat('C',m*n*s,1);
% ctype=ctype'
c1=char(ones([1 m*n+m*n*s])*('B'));
c2=char(ones([1 m*n*s])*('C'));
ctype=[c1 c2] ;
% for k=1:m*n+m*n*s
%     ctype(k,1)='B';
% end
% for k=1:m*n*s
%     ctype(m*n+k,1)='C';
% end


Aeq=[];
beq=[];
sostype='';
sosind=[];
soswt=[];

%x0=[];
[soln,negobj] = cplexmilp(-obj,A,b,Aeq,beq,sostype,sosind,soswt,lb,ub,ctype,x0,options);
x=reshape(soln(1:m*n,1),[m,n]);
v=reshape(soln(m*n+1:m*n+m*n*s,1),[m,n*s]);
z=reshape(soln(m*n+m*n*s+1:m*n+2*m*n*s,1)',[m,n*s]);


obj=-negobj;
w=zeros(m,s);
for k=1:s
       w(:,k)= ones(m,1)-v(:,1+(k-1)*n:k*n)*ones(n,1);
end
dup = nnz(z)/s;
rej = nnz(w)/s;

    %simplify menu
    for i=1:m
            for j=1:n
                if abs(x(i,j))<0.1
                    x(i,j)=0;
                end
                if abs(x(i,j)-1)<0.1
                    x(i,j)=1;
                end
            end
    end


