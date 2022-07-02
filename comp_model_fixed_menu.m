function[obj,gap,v,w,y,p,ptrue,u,psi]=comp_model_fixed_menu(Chat,x,q,s,fare,alpha,beta,buffer,mincomp,timelim,gap,displ)
%%% code to solve lcf-fm

%%% outputs: obj is the objective value, gap is the optimality gap (0.01 is 1%)
%%% v is the assignemnt (m x n represents a
%%% scenario, scenarios concatenated horizontally so v is m x n*s), umached
%%% requets: w is the binary values where 1 means
%%% it is unmatched in scenario s (w is m x s), w is represented as a function
%%% of v in the formulation but is calculated after so we can easily know
%%% the match rate, y is the driver selections (m x n*s), p is the
%%% p-double-dot values (m x n), ptrue is p-double-dot rounded so that
%%% values cannot exceed 1 (i.e. to represent pij), u is the u values
%%% (compensation is alpha + u) and u is m x n, psi is the psi values (m x
%%% n*s)

%inputs: assume menu size is between 0 and 5, q is a nx1 vector of the number of
%requests a driver can be assigned, s is number of variable scenarios, buffer is prem*ones(m,n), mincomp is a
%scalar ex. 0.8 means driver is paid at least 80% of fare, there is also a
%constraint that the offer is at least $4. Timelim is the solver time
%limit, gap is the optimality gap to solve to, disp is usually set at zero,
%is an integer display setting for the solver i.e. how much stuff is displayed as
%it solves,
%Chat,x,fare,alpha, and beta are each m x n arrays of the corresponding
%parameter

[m,n]=size(Chat);

% Build model base for cplex to read
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

%%% set column indices set for each variable so they can easily be
%%% referenced for constraints
%%% variables have to all be represnted by a single vector, so each
%%% variable is converted from an array to a vector and concatenated in the
%%% order they appear below. The array-to-vector conversion concatenates each column,
%%% i.e. the same result as the command (:) (e.g. v(:))
curr=1;
vind=curr:curr+m*n*s-1;
curr=curr+m*n*s;
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
objf(vind,1)=repmat(Chat(:)-alpha(:),s,1);
objf(psiind,1)=-ones(m*n*s,1);
objf=objf/s;





%%%%%%%%%%%%% constraints %%%%%%%%%%%%%%%%%
%%% v less x (can only assign if offered) %%%%%%%%%%%%%%%
Anew=sparse(m*n*s,varitot);
Anew(:,vind)= speye(m*n*s);
bnew= repmat(x(:),s,1);

Am=Anew;
bm=bnew;

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

%%% min comp constr,  4x \leq alpha + u
Anew=sparse(m*n,varitot);
Anew(:,uind)=-speye(m*n);
bnew= alpha(:)-4*x(:);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% min comp percent,  0.8*fare*x \leq alpha + u
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


%%% lower bound (lb), uppber bound (ub), and ctype (binary, cts, etc) %%%%%%%%%%%%%%%%%%%%%%%%%%%%
lbm=sparse(varitot,1);
ubm=zeros(varitot,1);
ubm([vind yind],1)=ones(m*n*s*2,1);
ubm(pind,1)=2/3*beta(:)./alpha(:);
ubm(uind,1)=beta(:);
ubm(psiind,1)=repmat(beta(:),s,1);
% 

%%% build a vector that tells cplex which variable entries are binary (B)
%%% and which are continuous (C)
c1=char(ones([1 m*n*s])*('B'));
c2=char(ones([1 m*n])*('B'));
c3=char(ones([1 m*n*s])*('C'));
c4=char(ones([1 m*n])*('C'));
ctypem=[c1 c1 c4 c4 c3] ;


cplex.Model.obj   = -objf;
cplex.Model.lb    = lbm;
cplex.Model.ub    = ubm;
cplex.Model.rhs   = bm;
cplex.Model.lhs   = -100000*ones(size(bm));
cplex.Model.A     = Am;
cplex.Model.ctype = ctypem;


 % Solve model
   cplex.solve();
   
%the solution is a single vector of variables plus info like objective and
%time, so we first extract that information then convert the single
%variable vector into an array for each variable to output


negobj=cplex.Solution.objval;
best=cplex.Solution.bestobjval;
if best~=0
    gap=(best-negobj)/best;
else
    gap=0;
end
soln=cplex.Solution.x;
v=round(reshape(soln(vind,1),[m,n*s]),0);
y=round(reshape(soln(yind,1),[m,n*s]),0);
p=reshape(soln(pind,1),[m,n]);
u=reshape(soln(uind,1),[m,n]);
psi=reshape(soln(psiind,1),[m,n*s]);


obj=-negobj;

%calculate w since in the optimization model we just model it implicitly through v
w=zeros(m,s);
for k=1:s
       w(:,k)= ones(m,1)-v(:,1+(k-1)*n:k*n)*ones(n,1);
end

 ptrue=p; %ptrue is just p double dot but not allowed to exceed 1 so we can use it as a probability like intented
 ptrue(p>1)=ones(size(p(p>1)));


   