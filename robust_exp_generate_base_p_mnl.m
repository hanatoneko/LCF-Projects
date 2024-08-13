function[ pbaselong ] = robust_exp_generate_base_p_mnl( alphalong, ulong, issymm )
[ j, k ] = size( alphalong );
alphamult = 0

if issymm == true
    alphamult = 0.75
end

pbaselong = ones( j, k )./(ones( j, k ) + exp( alphamult * alphalong - ulong ) );

%figure
%scatter( (ulong(:) + alphalong(:))./alphalong(:), pbaselong(:) )