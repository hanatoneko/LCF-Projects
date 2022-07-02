function[trivialscens,nontrivialz]=trivialscenscount(m,n,x,z)
offers=nnz(x);
scens=size(z,2)/n;
trivialscens=0;
nontrivialz=nnz(z);
for s=1:scens
    if nnz(z(:,(s-1)*n+1:s*n))>=nnz(x)
        trivialscens=trivialscens+1;
        nontrivialz=nontrivialz-nnz(z(:,(s-1)*n+1:s*n));
    end
end