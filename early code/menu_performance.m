function[obj,dup,rej,v,y,w,z]=menu_performance(C,D,r,y)

% addpath(genpath('C:\Users\hanna\OneDrive\Documents\MATLAB\yalmip'));
% Options=sdpsettings('solver','cplex','verbose',0,'cachesolvers',1);


[m,n]=size(C);


%%% calculate v
v=zeros(m,n);
for i=1:m
    if nnz(y(i,:))==1
        v(i,:)=y(i,:);
    elseif nnz(y(i,:))>1
        candidates=find(y(i,:));
        maxval=-1000; %just a large number to compare
        maxindex=0;
        for j=1:size(candidates,2)
            if C(i,candidates(j))+ D(i,candidates(j))>maxval
                maxval=C(i,candidates(j))+ D(i,candidates(j));
                maxindex= candidates(j);
            end
        end
        v(i,maxindex)=1;
    end
end

%%% calculate z and w

z=y-v;
w=ones(m,1)-v*ones(n,1);


% U=rand(m,n)-0.5*ones(m,n);
% 
% %%% calculate y
% y = zeros(m,n);
% for j=1:n
%     utility=0;
%     index=0;
%     for i=1:m
%         if U(i,j)*x(i,j)>utility
%             utility=U(i,j)*x(i,j);
%             index=i;
%         end
%     end
%     if index~=0
%         y(index,j)=1;
%     end
% end


% %%%%%% find optimal v (and get z, w)
% v = sdpvar(m,n,'full');
% w = sdpvar(m,1);
% z = sdpvar(m,n,'full');
% 
% %%%%%%% build objective functions
% obj = 0;
% for i=1:m
%    obj = obj + C(i,:)*(v(i,:))' - D(i,:)*(z(i,:))';
%   
% end
% 
% obj = obj - r'*w;
% 
% %%%%%%%%% Constraints %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Const=[];
% 
% %%% z constraint (driver accepts but is rejected)
% for i=1:m
%     for j=1:n
%         Const=[Const, y(i,j)-v(i,j) <= z(i,j)];
%     end
% end
% 
% %%% w unfulfilled requests
% for i=1:m
%     Const=[Const, 1-v(i,:)*ones(n,1) <= w(i)];
% end
% 
% %%% simplified v constraint
% for i=1:m
%     Const=[Const, v(i,:)*ones(n,1) <= 1];
% end
% 
% %%% can't assign a request to driver j if they didn't accept the request
% for i=1:m
%     for j=1:n
%         Const=[Const, v(i,j) <= y(i,j)];
%     end
% end
% 
% Const=[Const,v>=0];
% 
% %%%%%%%%%%% solve
% solvesdp(Const,-obj,Options);

% obj=value(obj);
% v=value(v);
% z=value(z);
% w=value(w);
obj = 0;
for i=1:m
   obj = obj + C(i,:)*(v(i,:))' - D(i,:)*(z(i,:))';
  
end

obj = obj - r'*w;

dup = nnz(z);
rej = nnz(w);




