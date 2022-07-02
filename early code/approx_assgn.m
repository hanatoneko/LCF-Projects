function[obj,dup,rej,v,w,z]=approx_assgn(C,D,r,x,y)
%%% assignment heuristic that can be used to speed up performance analysis
[m,n]=size(y);
available=x.*y;
v=zeros(m,n);
while true
        %%% test if we're out of assignments or drivers
    if available==zeros(m,n)
        break
    end
    
    accepts=n+1;
    reqcand=[]; %candidate requests
    %%% find request(s) with least number of remaining suppliers that
    %%% accepted it
    for i=1:m
        if nnz(available(i,:))<accepts
            if nnz(available(i,:))>0
                reqcand=i;
                accepts=nnz(available(i,:));
            end
        elseif  nnz(available(i,:))==accepts
            reqcand=vertcat(reqcand,i);
        end
    end
   
    
    %find supplier(s) with fewest number of accepted requests (that
    %accepted our candidate request(s)
    supcand=zeros(size(reqcand,1),2); % supplier candidates
    for k=1:size(reqcand,1)
        maxrev=0;   %the highest revenue of assigning the request to someone
        bestsup=0; %the supplier that will be chosen
        options=m+1;
        for j=1:n
            if available(reqcand(k,1),j)==1
                if nnz(available(:,j))<options
                    options=nnz(available(:,j));
                    bestsup=j;
                    maxrev=C(reqcand(k,1),j)+D(reqcand(k,1),j);
                elseif nnz(available(:,j))==options
                    if C(reqcand(k,1),j)+D(reqcand(k,1),j)>maxrev
                        bestsup=j;
                        maxrev=C(reqcand(k,1),j)+D(reqcand(k,1),j);
                    end
                end
            end
        end
    supcand(k,:)=[bestsup,maxrev];    
    end
    
    %%% find best candidate, assign, and remove request and supplier from
    %%% available
   
    [maximum,index]=max(supcand(:,2));
    i=reqcand(index,1);
    j=supcand(index,1);
    v(i,j)=1;
    available(i,:)=zeros(1,n);
    available(:,j)=zeros(m,1);
    
    v;
    available;


       
end

%%% assign any extra requests that can be assigned as a second request to
%%% people
rev=C.*y.*x; %gives matrix of the nonzero assignment revenues we can still make
for i=1:m
    if v(i,:)==zeros(1,n) 
        if sum(y(i,:).*x(i,:))>0
            [maximum,j]=max(rev(i,:));
            v(i,j)=1;
        end
    end
end

%%% z constraint (driver accepts but is rejected)

z=max(-2*ones(m,n)+ y + x + ones(m,n)-ones(m,m)*v, zeros(m,n));

w=ones(m,1)-v*ones(n,1);

obj =ones(1,m)*(C.*v)*ones(n,1)-ones(1,m)*(D.*z)*ones(n,1)+ r'*(ones(m,1)-w);



dup = nnz(z);
rej = nnz(w);
            
            
            