function[obj,gap,w,y,p,ptrue,u,psi]=comp_model_no_v_fixed_menu(Chat,x,q,s,fare,alpha,beta,buffer,mincomp,timelim,gap,displ)


[m,n]=size(Chat);

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
yind=curr:curr+m*n*s-1;
curr=curr+m*n*s;
pind=curr:curr+m*n-1;
curr=curr+m*n;
uind=curr:curr+m*n-1;
curr=curr+m*n;
psiind=curr:curr+m*n*s-1;
varitot=curr+m*n*s-1;




%%% objective
objf=sparse(varitot,1);
objf(yind,1)=repmat(Chat(:)-alpha(:),s,1);
objf(psiind,1)=-ones(m*n*s,1);
objf=objf/s;






%%% y less x (can only assign if offered) %%%%%%%%%%%%%%%
Anew=sparse(m*n*s,varitot);
Anew(:,yind)= speye(m*n*s);
bnew= repmat(x(:),s,1);

Am=Anew;
bm=bnew;


%%% can assign each item once (sum_j y_ij<=1) %%%%%%%%%%%%%%%%%%%%%%%%%%%%

Anew=sparse(m*s,varitot);
Anew(:,yind)=kron(speye(s),repmat(speye(m),1,n));
bnew= ones(m*s,1);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% limit number of items assigned to each driver (sum_i y<=q %%%%%%%%%%%%%%%%%%%%%%%%%%%%

Anew=sparse(n*s,varitot);
Anew(:,yind)=kron(speye(n*s),ones(1,m));
bnew=repmat(q,s,1);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);


%%% psi lower bound (psi>= beta*y +u-beta %%%%%%%%%%%%%%%
Anew=sparse(m*n*s,varitot);
Anew(:,yind)=sparse(diag(repmat(beta(:),s,1)));
Anew(:,uind)=repmat(speye(m*n),s,1);
Anew(:,psiind)= -speye(m*n*s);
bnew= repmat(beta(:),s,1);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% psi upper bound 1 (psi<= u) %%%%%%%%%%%%%%%
Anew=sparse(m*n*s,varitot);
Anew(:,uind)=repmat(-speye(m*n),s,1);
Anew(:,psiind)= speye(m*n*s);
bnew= sparse(m*n*s,1);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% psi upper bound 2 (psi<= beta*v)  %%%%%%%%%%%%%%%
Anew=sparse(m*n*s,varitot);
Anew(:,yind)=sparse(diag(repmat(-beta(:),s,1)));
Anew(:,psiind)= speye(m*n*s);
bnew= sparse(m*n*s,1);

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
Anew(:,yind)=repmat(1/s*speye(m*n),1,s);
Anew(:,pind)= -sparse(diag(buffer(:)));
bnew= sparse(m*n,1);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% min comp constr,  5x \leq alpha + u
Anew=sparse(m*n,varitot);
Anew(:,uind)=-speye(m*n);
bnew= alpha(:)-5*x(:);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% min comp percent,  0.6*fare*x \leq alpha + u
Anew=sparse(m*n,varitot);
Anew(:,uind)=-speye(m*n);
bnew= alpha(:)-mincomp*fare(:).*x(:);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);



%%% filter constr, u<=beta*x
Anew=sparse(m*n,varitot);
Anew(:,uind)= speye(m*n);
bnew= beta(:).*x(:);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);


%%% lb, ub, and ctype %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% use yprobs as bound since items with p_ij=0 shouldn't
%be offered
lbm=sparse(varitot,1);
ubm=zeros(varitot,1);
ubm([yind],1)=ones(m*n*s,1);
ubm(pind,1)=2/3*beta(:)./alpha(:);
ubm(uind,1)=beta(:);
ubm(psiind,1)=repmat(beta(:),s,1);
% 


c1=char(ones([1 m*n*s])*('B'));
c2=char(ones([1 m*n])*('B'));
c3=char(ones([1 m*n*s])*('C'));
c4=char(ones([1 m*n])*('C'));
ctypem=[c1 c4 c4 c3] ;


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
y=round(reshape(soln(yind,1),[m,n*s]),0);
p=reshape(soln(pind,1),[m,n]);
u=reshape(soln(uind,1),[m,n]);
psi=reshape(soln(psiind,1),[m,n*s]);


obj=-negobj;
w=zeros(m,s);
for k=1:s
       w(:,k)= ones(m,1)-y(:,1+(k-1)*n:k*n)*ones(n,1);
end

 ptrue=p;
 ptrue(p>1)=ones(size(p(p>1)));


   