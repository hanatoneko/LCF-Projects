function[ noiselong ] = robust_exp_generate_correlated_data( j, k )

noiselong = zeros( j, k );

p1 = rand( j * k, 1 )
requestSeeds = rand( 1, k )
p2data = repmat( requestSeeds, j, 1 )
p2 = p2data( : );
u = copularnd( 'Gaussian', 0.8, j * k );

[s1,i1] = sort(u(:,1));
[s2,i2] = sort(u(:,2));

x1 = zeros(size(s1));
x2 = zeros(size(s2));

x1(i1) = sort(p1);
x2(i2) = sort(p2);

for i = 1:k
    seed = requestSeeds( i );
    [ seedIndices, col ] = find( x2 == seed );
    values = x1( seedIndices, : );
    neworder = randperm( j );
    noiselong( :, i ) = values( neworder );
end

%figure
%scatterhist(p2,noiselong(:))


%copula_corr = corr(u,'Type','spearman')
%pearson_corr = corr([x1,x2],'Type','spearman')