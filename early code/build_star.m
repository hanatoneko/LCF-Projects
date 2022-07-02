function[cstr,dstr,Astr,Bstr,bstr,qstr,Nstr,Mstr]=build_star(m,n,cbar,Abar,Bbar,bbar,Ubar,Cbar,gbar,Fbar)

lenxbar = size(cbar,1);
lenybar = size(Cbar,2);
[Arows,Acols]=size(Abar);
[dualbar] = size(Cbar,1);

%%%  build c* %%%%%%%%%

cstr = zeros(lenxbar+lenybar+dualbar,1);
cstr(1:lenxbar,1)=cbar;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% build A*, B*, and b* %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Abar*xbar + Bbar*xbar >=b %%%%%%%%%%%%%%

Astr = horzcat(Abar,Bbar,zeros(Arows,dualbar));
bstr = bbar;
Bstr = zeros(Arows,m*n+dualbar);


%%% Fx + Ciyi -wi >= gi %%%%%%%%%%%%%%

bstr = vertcat(bstr,gbar);   
new=horzcat(Fbar, Cbar,-1*eye(dualbar));
Astr = vertcat(Astr,new);
Bstr = vertcat(Bstr,zeros(dualbar, m*n+dualbar));


%%% Fx + Ciyi -wi <= gi %%%%%%%%%%%%%%

bstr = vertcat(bstr,-gbar);   
new=horzcat(-Fbar, -Cbar,eye(dualbar));
Astr = vertcat(Astr,new);
Bstr = vertcat(Bstr,zeros(dualbar, m*n+dualbar));


%%% di - Ci^T*lambda_i >= 0 %%%%%%%%%%%%%%%

bstr = vertcat(bstr, -Ubar + cbar(m*n+1:2*m*n));
new = horzcat(zeros(m*n),-Cbar');
Bstr = vertcat(Bstr,new);
for j=1:n
    new=zeros(m,lenxbar);
    mat=zeros(m);
    for i=1:m
        mat(i,i)=-cbar(2*m*n +(j-1)*m+i,1);
    end
    for i = 1:n
        
        if i==j
            new=horzcat(new,zeros(m,m));
        else
            new=horzcat(new,mat);
        end        
    end
    new=horzcat(new,zeros(m,dualbar));
    Astr = vertcat(Astr,new);
    
end

%%% di - Ci^T*lambda_i <= 0 %%%%%%%%%%%%%%%

bstr = vertcat(bstr, Ubar - cbar(m*n+1:2*m*n));
new = horzcat(zeros(m*n),Cbar');
Bstr = vertcat(Bstr,new);
for j=1:n
    new=zeros(m,lenxbar);
    mat=zeros(m);
    for i=1:m
        mat(i,i)=cbar(2*m*n +(j-1)*m+i,1);
    end
    for i = 1:n
        
        if i==j
            new=horzcat(new,zeros(m,m));
        else
            new=horzcat(new,mat);
        end        
    end
    new=horzcat(new,zeros(m,dualbar));
    Astr = vertcat(Astr,new);
    
end

%%% x = 1- xbin %%%%%%%%%%%%%%%%%%%%%%%%%
bstr = vertcat(bstr, ones(m*n,1), -1*ones(m*n,1));
new = horzcat(zeros(m*n),eye(m*n),zeros(m*n, 2*m*n+m + dualbar));

Astr = vertcat(Astr,new);
new = horzcat(eye(m*n),zeros(m*n, dualbar));
Bstr = vertcat(Bstr,new);

new = horzcat(zeros(m*n),-1*eye(m*n),zeros(m*n, 2*m*n+m + dualbar));
Astr = vertcat(Astr,new);
new = horzcat(-1*eye(m*n),zeros(m*n, dualbar));
Bstr = vertcat(Bstr,new);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Build N* %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%

Nstr = horzcat(zeros(m*n),eye(m*n),zeros(m*n, 2*m*n+m + dualbar));
new = horzcat(zeros(dualbar,lenxbar+m*n),eye(dualbar));
Nstr = vertcat(Nstr,new);

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% d*=0, q*=0, M*=0 %%%%%%%%%%%%%%%%%%%%
dstr = zeros(m*n + dualbar, 1);
qstr = zeros(m*n + dualbar,1);

Mstr = zeros(m*n + dualbar);

