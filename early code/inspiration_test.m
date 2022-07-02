function[revscore,probscore,mixscore,probandmix,total]=inspiration_test(menu,C,yprobs)

%%% build constraint matrices
[m,n]=size(C);

A=repmat(speye(m),1,n);
b= ones(m,1);

Anew=kron(speye(n),ones(1,m));
bnew=ones(n,1);

A=vertcat(A,Anew);
b=vertcat(b,bnew);

ctype=char(ones([1 m*n])*('B'));
Aeq=[];
beq=[];
sostype='';
sosind=[];
soswt=[];
lb=zeros(m*n,1);
ub=ones(m*n,1);



%%% find matching with max revenue
soln = cplexmilp(-C(:),A,b,Aeq,beq,sostype,sosind,soswt,lb,ub,ctype);
vrev=reshape(soln,[m,n]);
revscore=sum(sum(menu))-sum(sum(max(zeros(m,n),menu-vrev)));

%%% find matching with max expected number of fulfilled requests
soln = cplexmilp(-yprobs(:),A,b,Aeq,beq,sostype,sosind,soswt,lb,ub,ctype);
vprob=reshape(soln,[m,n]);
probscore=sum(sum(menu))-sum(sum(max(zeros(m,n),menu-vprob)));

%%% find matching with max revenue*prob
soln = cplexmilp(-C(:).*yprobs(:),A,b,Aeq,beq,sostype,sosind,soswt,lb,ub,ctype);
vmix=reshape(soln,[m,n]);
mixscore=sum(sum(menu))-sum(sum(max(zeros(m,n),menu-vmix)));

probandmix=sum(sum(menu))-sum(sum(max(zeros(m,n),menu-vprob-vmix)));
total=sum(sum(menu))-sum(sum(max(zeros(m,n),menu-vrev-vprob-vmix)));
