function[U]=build_u_exhaust_perm(m,n)

vals=[1:1:(m+1)];
allperms=[];
stop=[];
ncols=n;
for j=1:n
    temp=perms(vals)';
    stop=vertcat(stop, size(temp,2));
    ncols=ncols*size(temp,2);
    Uoptions=temp(1:m,:)-0.5; %shift the permutated values so they can be used as actual utilities
    for i=1:m
        Uoptions(i,:)=Uoptions(i,:)-temp(m+1,:);
    end
    allperms=cat(3,allperms,Uoptions);
end
U=zeros(m,ncols);
col=ones(n,1);
check=1;
curr=1;
ccol=0;

%%% build matrix, goes through all combinations of columns from the
%%% permutation matrices for each driver
while true
    for j=1:n
        U(:,ccol+j) = allperms(:,col(j),j);
    end
    ccol=ccol+n;
    if col==stop
        break
    end
    while true
        if col(check)<stop(check)
            col(check)=col(check)+1;
            check=1;
            break
        end
        col(check)=1;
        check=check+1;
        if (check-1)==curr
            curr=curr+1;
            check=1;
            col(curr,1)=col(curr,1)+1;
            break
        end
        
    end

end
