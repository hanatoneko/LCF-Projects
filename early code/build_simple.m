function[m,n,cbar,Abar,Bbar,bbar,Ubar,Cbar,gbar,Fbar]=build_simple(C,D,r,U,theta)

%this code builds the large matrices, which all have 'bar' in their name.
%The system is:      min c^T*x
%                   s.t. Abar*x+Bbar*y >= bbar
%                        *the entries of x corresponding to menu decisions are binary*           
%                        y=argmax Ubar*y
%                             Cbar*y >= gbar -Fbar*x




[m,n]=size(C);

%%% Build cbar %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cbar=zeros(3*m*n+m,1);
for i=1:m
    for j=1:n
        cbar((j-1)*m+i,1)=C(i,j);
        cbar(2*m*n+(j-1)*m+i,1)=-D(i,j);
    end
    cbar(3*m*n+i,1)=-r(i);
end



%%% Build Ubar %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ubar=zeros(m*n,1);
for i=1:m
    for j=1:n
        Ubar((j-1)*m+i,1)=U(i,j);
    end
end


%%%%%%% Build the matrices/vectors for the outer constraints %%%%%%%%%%%%%%
Abar=zeros(1,3*m*n+m);
Bbar=zeros(1,m*n);
bbar=[];

crow=0; %keeps track of how many rows have been filled in so constraints can be added or deleted without too much hassle

%%%%%%%%%% Building on for each constraint: 

%%%  menu size %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:n
    Abar(crow+i,m*n+1+m*(i-1):m*n+m+m*(i-1))=ones(1,m);
    Bbar(crow+ i,:)=zeros(1, m*n);
    bbar=[bbar, theta];
end

crow = crow + n;

for i=1:n
    Abar(crow+i,m*n+1+m*(i-1):m*n+m+m*(i-1))=-1*ones(1,m);
    Bbar(crow+ i,:)=zeros(1, m*n);
    bbar=[bbar, -theta];
end

crow = crow + n;

%%% z constraint %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for j=1:n
    for i=1:m
        Abar(crow+1,i+(j-1)*m)=1;
        Abar(crow+1,2*m*n+i+(j-1)*m)=1;
        Bbar(crow+ 1,i+(j-1)*m)=-1;
        bbar=[bbar, 0];
        crow = crow + 1;
    end
    
end

%%% w constraint %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:m
    for j=1:n
        Abar(crow+1,i+m*(j-1))=1;
    end
    Abar(crow+1,3*m*n+i)=1;
    Bbar(crow+ 1,:)=zeros(1, m*n);
    bbar=[bbar, 1];
    crow = crow + 1;
    
end

%%% simplified v constraint %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:m
    for j=1:n
        Abar(crow+1,i+m*(j-1))=-1;
    end
    Bbar(crow+ 1,:)=zeros(1, m*n);
    bbar=[bbar, -1];
    crow = crow + 1;
    
end

%%% a request must be assigned to a driver that accepted it %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for j=1:n
    for i=1:m
        Abar(crow+1,i+(j-1)*m)=-1;
        Bbar(crow+ 1,i+(j-1)*m)=1;
        bbar=[bbar, 0];
        crow = crow + 1;
    end
    
end

%%% v>=0 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% for i=1:m*n
%     Abar(crow+1,i)=1;
%     Bbar(crow+ 1,:)=zeros(1, m*n);
%     bbar=[bbar, 0];
%     crow = crow + 1;
%     
% end

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
gbar=[];
for j=1:n
   Cbar(((j-1)*q+1):((j-1)*q+q),((j-1)*p+1):((j-1)*p+p))=Cmini;
   gbar=[gbar,gmini]; 
end


%%% Build Fbar %%%%%%%%%%%%%%%%%%
Fbar=zeros(q*n,3*m*n+m);

for j=1:n
   crow=0;
   for i=1:m
      Fbar(2+(j-1)*q+crow, m*n + (j-1)*m+i)=1; 
      crow=crow+1;
   end
end

%make gbar and bbar have standard matrix dimensions
bbar=bbar';
gbar=gbar';