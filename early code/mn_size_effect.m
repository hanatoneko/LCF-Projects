function[menunzs,times,nontrivscens,percnontriv,topprobs]=mn_size_effect(sizes,sampsizes)


numsamp=size(sampsizes,1);
menunzs=zeros(size(sizes,1),numsamp);
nontrivscens=zeros(size(sizes,1),numsamp);
percnontriv=zeros(size(sizes,1),numsamp);
times=zeros(size(sizes,1),numsamp);
topprobs=zeros(size(sizes,1),numsamp*3);
for t=1:size(sizes,1)
    m=sizes(t,1);
    n=sizes(t,2);
    theta=sizes(t,3);
    for i=1:size(sampsizes,1)
        samples=sampsizes(i,1);
        [C,D,r,q,yprobs,Oi,Di,Oj,Dj,drand]=generate_params(m,n,1);

        [yhat,scenprobs]=indepy_generate_scens(yprobs,samples,0);
        scenprobs=scenprobs/sum(scenprobs);
        sortprobs=sort(scenprobs,'descend');
        topprobs(t,(i-1)*3+1:(i-1)*3+3)=sortprobs(1,1:3)
        
        %get a menu
        tic
        [obj,gap,x,v,z,w]=fixed_y_prob_cplex_dot(C,D,r,theta,q,yprobs,yhat,scenprobs,0,0,500,0.01,0);
        toc
        times(t,i)=toc
        menunzs(t,i)=nnz(x)
        [trivialscens,nontrivialz]=trivialscenscount(m,n,x,z);
        nontrivscens(t,i)=samples-trivialscens
        percnontriv(t,i)=(samples-trivialscens)/samples
    end
end
