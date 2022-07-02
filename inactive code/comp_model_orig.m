function[obj,gap,x,v,z,w,y,p,t,u,eps,phi,psi]=comp_model_orig(C,D,theta,lwr,q,s,alpha,beta,buffer,timelim,gap,displ)


[m,n]=size(D);

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
xind=curr:curr+m*n-1;
curr=curr+m*n;
vind=curr:curr+m*n*s-1;
curr=curr+m*n*s;
zind=curr:curr+m*n*s-1;
curr=curr+m*n*s;
yind=curr:curr+m*n*s-1;
curr=curr+m*n*s;
pind=curr:curr+m*n-1;
curr=curr+m*n;
tind=curr:curr+m*n-1;
curr=curr+m*n;
uind=curr:curr+m*n-1;
curr=curr+m*n;
epsind=curr:curr+m*n-1;
curr=curr+m*n;
phiind=curr:curr+m*n*s-1;
curr=curr+m*n*s;
psiind=curr:curr+m*n*s-1;
varitot=curr+m*n*s-1;




%%% objective
objf=sparse(varitot,1);
objf(vind,1)=repmat(C(:),s,1);
objf(zind,1)=repmat(-D(:),s,1);
objf(phiind,1)=-ones(m*n*s,1);
objf(psiind,1)=-ones(m*n*s,1);
objf=objf/s;



%%% menu size max %%%%%%%%%%%%%%%%%%%
Anew=sparse(n,varitot);
Anew(:,xind)=kron(speye(n),ones(1,m));
bnew=theta*ones(n,1);


Am=Anew;
bm=bnew;

%%% menu size min %%%%%%%%%%%%%%%%%%%%%%%
% Anew is just the negative of the previous Anew

bnew= -lwr*ones(n,1);


Am=vertcat(Am,-Anew);
bm=vertcat(bm,bnew);


%%% v less x (can only assign if offered) %%%%%%%%%%%%%%%
Anew=sparse(m*n*s,varitot);
Anew(:,xind)=repmat(-speye(m*n),s,1);
Anew(:,vind)= speye(m*n*s);
bnew= sparse(m*n*s,1);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% v less y(can only assign if  accepted) %%%%%%%%%%%%%%%
Anew=sparse(m*n*s,varitot);
Anew(:,yind)=-speye(m*n*s);
Anew(:,vind)= speye(m*n*s);
bnew= sparse(m*n*s,1);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% can assign each item once (sum_j v_ij<=1) %%%%%%%%%%%%%%%%%%%%%%%%%%%%

Anew=sparse(m*s,varitot);
Anew(:,vind)=kron(speye(s),repmat(speye(m),1,n));
bnew= ones(m*s,1);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% limit number of items assigned to each driver (sum_i v<=q %%%%%%%%%%%%%%%%%%%%%%%%%%%%

Anew=sparse(n*s,varitot);
Anew(:,vind)=kron(speye(n*s),ones(1,m));
bnew=repmat(q,s,1);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% z constraint %%%%%%%%%%%%%%%
Anew=sparse(m*n*s,varitot);
Anew(:,xind)=repmat(speye(m*n),s,1);
Anew(:,vind)=kron(-speye(n*s),ones(m,m));
Anew(:,zind)= -speye(m*n*s);
Anew(:,yind)= speye(m*n*s);
bnew= ones(m*n*s,1);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% phi lower bound (phi>= alpha*v +t-alpha %%%%%%%%%%%%%%%
Anew=sparse(m*n*s,varitot);
Anew(:,vind)=sparse(diag(repmat(alpha(:),s,1)));
Anew(:,tind)=repmat(speye(m*n),s,1);
Anew(:,phiind)= -speye(m*n*s);
bnew= repmat(alpha(:),s,1);


Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% phi upper bound 1 (phi<= t) %%%%%%%%%%%%%%%
Anew=sparse(m*n*s,varitot);
Anew(:,tind)=repmat(-speye(m*n),s,1);
Anew(:,phiind)= speye(m*n*s);
bnew= sparse(m*n*s,1); 

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% phi upper bound 2 (phi<= alpha*v)  %%%%%%%%%%%%%%%
Anew=sparse(m*n*s,varitot);
Anew(:,vind)=sparse(diag(repmat(-alpha(:),s,1)));
Anew(:,phiind)= speye(m*n*s);
bnew= sparse(m*n*s,1);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);


%%% psi lower bound (psi>= beta*v +u-beta %%%%%%%%%%%%%%%
Anew=sparse(m*n*s,varitot);
Anew(:,vind)=sparse(diag(repmat(beta(:),s,1)));
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
Anew(:,vind)=sparse(diag(repmat(-beta(:),s,1)));
Anew(:,psiind)= speye(m*n*s);
bnew= sparse(m*n*s,1);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% t lower bound (t>=alpha*epsilon)  %%%%%%%%%%%%%%%
Anew=sparse(m*n,varitot);
Anew(:,tind)=-speye(m*n);
Anew(:,epsind)= sparse(diag(alpha(:)));
bnew= sparse(m*n,1);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% u upper bound (u<=beta*epsilon)  %%%%%%%%%%%%%%%
Anew=sparse(m*n,varitot);
Anew(:,uind)=speye(m*n);
Anew(:,epsind)= sparse(diag(-beta(:)));
bnew= sparse(m*n,1);

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



%%% lb, ub, and ctype %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% use yprobs as bound since items with p_ij=0 shouldn't
%be offered
lbm=sparse(varitot,1);
ubm=zeros(varitot,1);
ubm([xind epsind],1)=ones(2*m*n,1);
ubm([vind zind yind],1)=ones(m*n*s*3,1);
ubm(pind,1)=2/3*beta(:)./alpha(:);
ubm(tind,1)=alpha(:);
ubm(uind,1)=beta(:);
ubm(phiind,1)=repmat(alpha(:),s,1);
ubm(psiind,1)=repmat(beta(:),s,1);



c1=char(ones([1 m*n*s])*('B'));
c2=char(ones([1 m*n])*('B'));
c3=char(ones([1 m*n*s])*('C'));
c4=char(ones([1 m*n])*('C'));
ctypem=[c2 c1 c3 c1 c4 c4 c4 c2 c3 c3] ;


cplex.Model.obj   = -objf;
cplex.Model.lb    = lbm;
cplex.Model.ub    = ubm;
cplex.Model.rhs   = bm;
cplex.Model.lhs   = -10000*ones(size(bm));
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
x=round(reshape(soln(xind,1),[m,n]),0);
v=round(reshape(soln(vind,1),[m,n*s]),0);
z=round(reshape(soln(zind,1),[m,n*s]),0);
y=round(reshape(soln(yind,1),[m,n*s]),0);
p=reshape(soln(pind,1),[m,n]);
t=reshape(soln(tind,1),[m,n]);
u=reshape(soln(uind,1),[m,n]);
eps=reshape(soln(epsind,1),[m,n]);
phi=reshape(soln(phiind,1),[m,n*s]);
psi=reshape(soln(psiind,1),[m,n*s]);


obj=-negobj;
w=zeros(m,s);
for k=1:s
       w(:,k)= ones(m,1)-v(:,1+(k-1)*n:k*n)*ones(n,1);
end



   