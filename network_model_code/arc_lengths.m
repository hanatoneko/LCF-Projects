function[Gamma,pen]=arc_lengths(C,D,r,yprobs,alpha1,alpha2)

[m,n]=size(yprobs);

Gamma=C+n*yprobs./(yprobs*ones(n,n))+yprobs;
Gamma=alpha1*Gamma;


rev=alpha2*C*ones(n,1)/n;
penalties=zeros(m,n-1);
for j=1:n-1    
    penalties(:,j)=((0.5*(n-1+j)/(n-1))*ones(m,1)).^(((ones(1,m)*yprobs*ones(n,n))*ones(m,1)./(m*yprobs*ones(n,1))).^1); %was 0.5 for 10x10
end


penalties=-1*(n-1)*penalties.*(((ones(1,m)*r)/m*ones(m,1)./r  +  m/(ones(1,m)*D*ones(n,1))*(D*ones(n,1)))./ones(m,1)*ones(1,n-1));
pen=horzcat(rev,penalties);