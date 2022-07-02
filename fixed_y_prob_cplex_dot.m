function[objf,gap,x,v,z,w]=fixed_y_prob_cplex_dot(C,D,r,theta,q,yprobs,yhat,scenprobs,equal,lwr,timelim,gap,displ)
%%% formulates and solves SLSF

%%% outputs: objf is the objective, gap is the optimality gap (0.01 is 1%)
%%% x is the menu (m x n), v is the assignemnt (m x n represents a
%%% scenario, scenarios concatenated horizontally so v is m x n*s), z is
%%% the unhappy driver requets (m x n*s), umached requets: w is the binary values where 1 means
%%% it is unmatched in scenario s (w is m x s), w is represented as a function
%%% of v in the formulation but is calculated after so we can easily know
%%% the match rate
%%%
%%% inputs: C and D are m x n arrays from the formulation, r is the m x 1 vector match
%%% bonus (i.e. the objective function is Cv +rw-Dz), theta is max menu
%%% size, q is a col vector of how many requests each driver can be
%%% assigned, yprobs is the pij array, yhat is the set of driver selections
%%% (a set of selections is formatted as an m x n array, these are then
%%% horizontally concatenated), scenprobs is a row vector of the scenario liklihoods,
%%% equal is 1 if you want the menu size to be exactly theta, if equal is 0
%%% then the menu size lower bound is lwr, timelim is the cplex time limit
%%% in seconds, gap is the optimality gap you want the solver to terminate
%%% at, displ is an integer between 0 and (3?) where a higher number means
%%% more of the cplex solver process is displayed

[m,n]=size(C);
s=size(yhat,2)/n; %number of samples

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


%%% variables have to all be represnted by a single vector, so each
%%% variable is converted from an array to a vector and concatenated to be x then 
%%% v then z, so for example the first m*n entries are x
%%% The array-to-vector conversion concatenates each column,
%%% i.e. the same result as the command (:) (e.g. x(:))



%%% objective
objf=zeros(m*n+2*m*n*s,1);
block=repmat(scenprobs,m*n,1);
objf(m*n+1:m*n+m*n*s,1)=((repmat(C(:),s,1)+repmat(r,n*s,1)).*block(:))/sum(scenprobs);
objf(m*n+m*n*s+1:m*n+2*m*n*s,1)=repmat(-D(:),s,1).*block(:)/sum(scenprobs);


%%%%%%%%%%%%% constraints %%%%%%%%%%%%%%%%%
%%% menu size max %%%%%%%%%%%%%%%%%%%
Anew=sparse(n,m*n+2*m*n*s);
Anew(:,1:m*n)=kron(speye(n),ones(1,m));
bnew=theta*ones(n,1);

Am=Anew;
bm=bnew;

%%% menu size min %%%%%%%%%%%%%%%%%%%%%%%
% Anew is just the negative of the previous Anew
if equal==1
    bnew=-theta*ones(n,1);
else
    bnew= -lwr*ones(n,1);
end

Am=vertcat(Am,-Anew);
bm=vertcat(bm,bnew);


%%% v bound (can only assign if offered and accepted) %%%%%%%%%%%%%%%
Anew=sparse(m*n*s,m*n+2*m*n*s);
Anew(:,1:m*n)=repmat(-0.5*speye(m*n),s,1);
Anew(:,m*n+1:m*n+m*n*s)= speye(m*n*s);
bnew= 0.5*yhat(:);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% can assign each item once %%%%%%%%%%%%%%%%%%%%%%%%%%%%

Anew=sparse(m*s,m*n+2*m*n*s);
Anew(:,m*n+1:m*n+m*n*s)=kron(speye(s),repmat(speye(m),1,n));
bnew= ones(m*s,1);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% limit number of items assigned to each driver %%%%%%%%%%%%%%%%%%%%%%%%%%%%

Anew=sparse(n*s,m*n+2*m*n*s);
Anew(:,m*n+1:m*n+m*n*s)=kron(speye(n*s),ones(1,m));
bnew=repmat(q,s,1);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% z constraint %%%%%%%%%%%%%%%
Anew=sparse(m*n*s,m*n+2*m*n*s);
Anew(:,1:m*n)=repmat(speye(m*n),s,1);
Anew(:,m*n+1:m*n+m*n*s)=kron(speye(n*s),-ones(m,m));
Anew(:,m*n+m*n*s+1:m*n+2*m*n*s)= -speye(m*n*s);
bnew= ones(m*n*s,1)-yhat(:);

Am=vertcat(Am,Anew);
bm=vertcat(bm,bnew);

%%% lower bound (lb), uppber bound (ub), and ctype (binary, cts, etc)%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% use yprobs as bound since items with p_ij=0 shouldn't be offered
lbm=zeros(m*n+2*m*n*s,1);

% if there aren't enough requests with a positive pij for driver j, set the
% upper bound for x_ij to be 1 for all requests for that driver
yprobsround=ceil(yprobs);
for j=1:n
    if nnz(yprobs(:,j))<theta
        yprobsround(:,j)=ones(m,1);
    end
end 
ubm=vertcat(yprobsround(:),ones(2*m*n*s,1));

%%% build a vector that tells cplex which variable entries are binary (B)
%%% and which are continuous (C)
c1=char(ones([1 m*n+m*n*s])*('B'));
c2=char(ones([1 m*n*s])*('C'));
ctypem=[c1 c2] ;


cplex.Model.obj   = -objf;
cplex.Model.lb    = lbm;
cplex.Model.ub    = ubm;
cplex.Model.rhs   = bm;
cplex.Model.lhs   = -1000*ones(size(bm));
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
x=reshape(soln(1:m*n,1),[m,n]);
v=reshape(soln(m*n+1:m*n+m*n*s,1),[m,n*s]);
z=reshape(soln(m*n+m*n*s+1:m*n+2*m*n*s,1)',[m,n*s]);


objf=-negobj;

%calculate w since in the optimization model we just model it implicitly through v
w=zeros(m,s);
for k=1:s
       w(:,k)= ones(m,1)-v(:,1+(k-1)*n:k*n)*ones(n,1);
end


    %round menu x (at one point we needed to round x because it could be
    %slightly above 0 or less than 1)
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

   