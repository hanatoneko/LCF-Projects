function[C,D,r,a,q]=data_generation(m,n)
C=ones(m,n)+rand(m,n);
D=repmat(ones(1,n)+rand(1,n),m,1);
r=ones(m,1)+rand(m,1);
%U=unidrnd(2,m+N,n)-ones(m+N,n);
%U=unidrnd(2,m+N,n)-ones(m+N,n)+ 0.01*rand(m+1,n);
U=rand(m,n)-0.5*ones(m,n);
q=m*ones(n,1);
a=n*ones(m,1);
%U=rand(m+1,n);
%[q,U]=sort(U,'descend');

%U=ones(m+N,n);
%U=rand(m+N,n);
%[B,Sorted]=sort(C+D,2,'descend');



%%%test stuff, comment out later
% A=[4,3,1;2,3,1]
% [B,Sorted]=sort(A,2,'descend');


% for i=1:m
%     set=[];
%     for j=1:n
%         %first get the index of the next highest element of row i of C+D
%         current=Sorted(i,j);
%         set=[set,current];
%         for k=1:n
%             %check if k> current j, i.e. is k in set
%             isgreater=0;
%             for p=1:j % the length of set will be j so we're checking each entry
%                 if set(p)==k
%                     isgreater=1;
%                     continue
%                 end    
%             end
%             if isgreater==0
%                 %Outconst=[Outconst, v(i,k) <= 1-y(i,current)];
%                 sprintf(' v(%d,%d) <= 1-y(%d,%d)',i,k,i,current)
%             end
%         end
%     end
% end