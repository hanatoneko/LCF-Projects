function[m,n,cbint,Abint,bbint,Cbint,gbint,Fbint]=build_bilevel_interdict(C,D,r,theta)
[m,n]=size(C);

%%% Build cbar %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cbint=zeros(3*m*n+m,1);
for i=1:m
    for j=1:n
        cbint((j-1)*m+i,1)=C(i,j);
        cbint(2*m*n+(j-1)*m+i,1)=-D(i,j);
    end
    cbint(3*m*n+i,1)=-r(i);
end


%%%%%%% Build the matrices/vectors for the outer constraints %%%%%%%%%%%%%%
Abint=zeros(1,m*n);

bbint=[];

crow=0; %keeps track of how many rows have been filled in so constraints can be added or deleted without too much hassle

%%%  menu size %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:n
    Abint(crow+i,1+m*(i-1):m+m*(i-1))=ones(1,m);
    bbint=[bbint, theta];
end

crow = crow + n;

for i=1:n
    Abint(crow+i,1+m*(i-1):m+m*(i-1))=-ones(1,m);
    bbint=[bbint, -theta];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% matrices for inner constraints %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%Cbar, gbar, and Fbar from original lower level
%%% Build the Matrices/vectors for the inner constriants %%%%%%%%%%%%%%%%%%
%these submatrices don't depend on j so we'll just make 
%a mini version and then concatonate them later
Cmini=zeros(1,m); 
gmini=[];
crow=0;
%%% Sum upper and lower bounds %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Cmini(1,:)=-1*ones(1,m);
gmini=[gmini, -1];
crow=crow + 1;

%%% Individual upper constraints %%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:m
    Cmini(crow+1,i)=-1;
    gmini=[gmini, 0];
    crow=crow + 1;
end


%%% Individual lower constraints %%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:m
    Cmini(crow+1,i)=1;
    gmini=[gmini, 0];
    crow=crow + 1;
end


%%% Concatonate Cbar and gbar %%%%%%%%%%%%%%%%%%%%%%%%
[q,p]=size(Cmini);
Cbar=zeros(q*n, m*n);
gbint=[];
for j=1:n
   Cbar(((j-1)*q+1):((j-1)*q+q),((j-1)*p+1):((j-1)*p+p))=Cmini;
   gbint=[gbint,gmini]; 
end


%%% Build Fbar %%%%%%%%%%%%%%%%%%
Fbint=zeros(q*n,m*n);

for j=1:n
   crow=0;
   for i=1:m
      Fbint(2+(j-1)*q+crow, (j-1)*m+i)=1; 
      crow=crow+1;
   end
end

%make gbar and bbar have standard matrix dimensions
bbint=bbint';
gbint=gbint';

%%% Put Cbar into Cbint 
Cbint=horzcat(zeros((2*m+1)*n,m*n),Cbar,zeros((2*m+1)*n,m*n+m));


%%% z constraint %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

new=horzcat(-eye(m*n),eye(m*n),-eye(m*n),zeros(m*n,m));
Cbint=vertcat(Cbint,new);
Fbint=vertcat(Fbint,zeros(m*n));
gbint=vertcat(gbint,zeros(m*n,1));

%%% w constraint %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
new=(-eye(m));
for i=1:n-1
    new=horzcat(new,-eye(m));
end
new=horzcat(new,zeros(m,2*m*n),-eye(m));
Cbint=vertcat(Cbint,new);
Fbint=vertcat(Fbint,zeros(m,m*n));
gbint=vertcat(gbint,-ones(m,1));

%%% ensure accepted tasks get assigned %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

new1=eye(m);
for i=1:n-1
    new1=horzcat(new1,eye(m));
end
new=new1;
for i=1:n-1
    new=vertcat(new,new1);
end
new=horzcat(new,-eye(m*n),zeros(m*n,m*n+m));
Cbint=vertcat(Cbint,new);
Fbint=vertcat(Fbint,zeros(m*n));
gbint=vertcat(gbint,zeros(m*n,1));

%%% a request must be assigned to a driver that accepted it %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
new=horzcat(-eye(m*n),eye(m*n),zeros(m*n,m*n+m));
Cbint=vertcat(Cbint,new);
Fbint=vertcat(Fbint,zeros(m*n));
gbint=vertcat(gbint,zeros(m*n,1));


%%% v>=0 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

new=horzcat(eye(m*n),zeros(m*n,2*m*n+m));
Cbint=vertcat(Cbint,new);
Fbint=vertcat(Fbint,zeros(m*n));
gbint=vertcat(gbint,zeros(m*n,1));


