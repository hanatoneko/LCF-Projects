function[obj,gap,vf,vfull,w,y,p,ptrue,u,psi]=comp_model_no_v_w_scens_fixed_menu(Chat,x,q,s,fyhat,fscenprobs,fare,alpha,beta,buffer,mincomp,timelim,gap,displ)


[m,n]=size(Chat);
sfixed=size(fyhat,2)/n;

ysum=zeros(m,n);
for i=1:sfixed
    ysum=ysum+fscenprobs(1,i)*fyhat(:,(i-1)*n+1:i*n);
end
beta=max(beta,3/2/(s+sfixed)*x.*ysum.*alpha./buffer);
% Build model
cplex = Cplex('drivermenus');
cplex.Model.sense = 'minimize';
if timelim~='inf'
    if timelim~=0
        cplex.Param.timelimit.Cur=timelim;
    end
end

if gap~=0
    cplex.Param.mip.tolerances.mipgap.Cur=gap;
end

cplex.Param.mip.display.Cur=displ;

%%% set column indices set for each variable
curr=1;
vfind=curr:curr+m*n*sfixed-1;
curr=curr+m*n*sfixed;
yind=curr:curr+m*n*s-1;
curr=curr+m*n*s;
pind=curr:curr+m*n-1;
curr=curr+m*n;
uind=curr:curr+m*n-1;
curr=curr+m*n;
psifind=curr:curr+m*n*sfixed-1;
curr=curr+m*n*sfixed;
psiind=curr:curr+m*n*s-1;
varitot=curr+m*n*s-1;




%%% objective
objf=sparse(varitot,1);
objf(vfind,1)=repmat(Chat(:)-alpha(:),sfixed,1).*kron(fscenprobs',ones(m*n,1));
objf(yind,1)=repmat(Chat(:)-alpha(:),s,1);
objf(psifind,1)=-ones(m*n*sfixed,1);
objf(psiind,1)=-ones(m*n*s,1);
objf=objf/(s+sfixed);




%%% v less x (can only assign if offered) %%%%%%%%%%%%%%%
Anew=sparse(m*n*(s+sfixed),varitot);
Anew(:,[vfind,yind])= speye(m*n*(s+sfixed));
bnew= repmat(x(:),s+sfixed,1);

Am=Anew;
bm=bnew;

%%% v less fixed y(can only assign if  accepted) %%%%%%%%%%%%%%%
Anew=sparse(m*n*sfixed,varitot);
Anew(:,vfind)= speye(m*n*sfixed);
bnew= fyhat(:);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);



%%% can assign each item once (sum_j v_ij<=1) %%%%%%%%%%%%%%%%%%%%%%%%%%%%

Anew=sparse(m*(s+sfixed),varitot);
Anew(:,[vfind,yind])=kron(speye(s+sfixed),repmat(speye(m),1,n));
bnew= ones(m*(s+sfixed),1);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% limit number of items assigned to each driver (sum_i v<=q %%%%%%%%%%%%%%%%%%%%%%%%%%%%

Anew=sparse(n*(s+sfixed),varitot);
Anew(:,[vfind,yind])=kron(speye(n*(s+sfixed)),ones(1,m));
bnew=repmat(q,s+sfixed,1);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);


%%% psi lower bound (psi>= beta*v +u-beta %%%%%%%%%%%%%%%
Anew=sparse(m*n*(s+sfixed),varitot);
Anew(:,[vfind,yind])=sparse(diag(repmat(beta(:),s+sfixed,1)));
Anew(:,uind)=repmat(speye(m*n),s+sfixed,1);
Anew(:,[psifind,psiind])= -speye(m*n*(s+sfixed));
bnew= repmat(beta(:),s+sfixed,1);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% psi upper bound 1 (psi<= u) %%%%%%%%%%%%%%%
Anew=sparse(m*n*(s+sfixed),varitot);
Anew(:,uind)=repmat(-speye(m*n),s+sfixed,1);
Anew(:,[psifind,psiind])= speye(m*n*(s+sfixed));
bnew= sparse(m*n*(s+sfixed),1);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% psi upper bound 2 (psi<= beta*v)  %%%%%%%%%%%%%%%
Anew=sparse(m*n*(s+sfixed),varitot);
Anew(:,[vfind,yind])=sparse(diag(repmat(-beta(:),s+sfixed,1)));
Anew(:,[psifind,psiind])= speye(m*n*(s+sfixed));
bnew= sparse(m*n*(s+sfixed),1);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);



%%% p value lower bound (p>=2/(3alpha)*u)  %%%%%%%%%%%%%%%
Anew=sparse(m*n,varitot);
Anew(:,pind)=-speye(m*n);
Anew(:,uind)= sparse(diag(2/3*ones(m*n,1)./alpha(:)));
bnew= sparse(m*n,1);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% p value upper bound (p<=2/(3alpha)*u)  %%%%%%%%%%%%%%%
Anew=sparse(m*n,varitot);
Anew(:,pind)=speye(m*n);
Anew(:,uind)= sparse(diag(-2/3*ones(m*n,1)./alpha(:)));
bnew= sparse(m*n,1);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% buffer (1\samples*sum_s y<= buffer*pij)  %%%%%%%%%%%%%%%
Anew=sparse(m*n,varitot);
Anew(:,yind)=repmat(1/(s+sfixed)*diag(x(:)),1,s);
Anew(:,pind)= -sparse(diag(buffer(:)));

bnew=-1/(s+sfixed)*ysum(:).*x(:);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);


%%% min comp constr,  min(5,beta)x \leq alpha + u
Anew=sparse(m*n,varitot);
Anew(:,uind)=-speye(m*n);
bnew= alpha(:)-min(5*ones(m*n,1),beta(:)).*x(:);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% min comp percent,  0.6*fare*x \leq alpha + u
Anew=sparse(m*n,varitot);
Anew(:,uind)=-speye(m*n);
bnew= alpha(:)-mincomp*fare(:).*x(:);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);



% %%% filter constr, u<=beta*x
% Anew=sparse(m*n,varitot);
% Anew(:,uind)= speye(m*n);
% bnew= beta(:).*x(:);
% 
% Am=vertcat(Am,Anew);
% bm=vertcat(bm,bnew);



%%% lb, ub, and ctype %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% use yprobs as bound since items with p_ij=0 shouldn't
%be offered
lbm=sparse(varitot,1);
ubm=zeros(varitot,1);
ubm([vfind, yind],1)=ones(m*n*(s+sfixed),1);
ubm(pind,1)=2/3*beta(:)./alpha(:);
ubm(uind,1)=beta(:);
ubm([psifind,psiind],1)=repmat(beta(:),(s+sfixed),1);
% 


c1=char(ones([1 m*n*s])*('B'));
c2=char(ones([1 m*n])*('B'));
c3=char(ones([1 m*n*(s+sfixed)])*('C'));
c4=char(ones([1 m*n])*('C'));
c5=char(ones([1 m*n*sfixed])*('B'));
ctypem=[c5 c1 c4 c4 c3] ;


cplex.Model.obj   = -objf;
cplex.Model.lb    = lbm;
cplex.Model.ub    = ubm;
cplex.Model.rhs   = bm;
cplex.Model.lhs   = -100000*ones(size(bm));
cplex.Model.A     = Am;
cplex.Model.ctype = ctypem;


 % Solve model
   cplex.solve();
   
% Display solution
% if displ==1
%     fprintf ('\nSolution status = %s\n',cplex.Solution.statusstring);
% end

negobj=cplex.Solution.objval;
best=cplex.Solution.bestobjval;
if best~=0
    gap=(best-negobj)/best;
else
    gap=0;
end
soln=cplex.Solution.x;

vf=round(reshape(soln([vfind,],1),[m,n*(sfixed)]),0);
y=round(reshape(soln(yind,1),[m,n*s]),0);
p=reshape(soln(pind,1),[m,n]);
u=reshape(soln(uind,1),[m,n]);
psi=reshape(soln([psifind,psiind],1),[m,n*(s+sfixed)]);
vfull=horzcat(vf,y);

obj=-negobj;
w=zeros(m,s+sfixed);
for k=1:s
       w(:,k)= ones(m,1)-y(:,1+(k-1)*n:k*n)*ones(n,1);
end
for k=1:sfixed
       w(:,k)= ones(m,1)-vf(:,1+(k-1)*n:k*n)*ones(n,1);
end

 ptrue=p;
 ptrue(p>1)=ones(size(p(p>1)));


   