funciton[newbetavals] = generate_betavals_for_eq(x,alphavals,betavals,premium,variscens,fcenprobs,yhat)

%%% this code updates the beta values to use for SOL-FR/LCF-FR, as the
%%% fairness constraints can cause infeasibility if some beta values are
%%% not high enough (see paper)

%%%inputs: x is the menu, alphavals are the alpha values, betavals is the
%%%current beta values (just from generate_params_compmodel)

[m,n] = size(x);
sfixed=size(yhat,2)/n;
wagemin = 10;
wagemax = 25;
ysum=zeros(m,n);
for i=1:sfixed
    ysum=ysum+fscenprobs(1,i)*yhat(:,(i-1)*n+1:i*n);
end
betavals=max(betavals,3/2/(variscens+sfixed)*x.*ysum.*alphavals./premium);

newbetavals = betavals;
for i = 1:m
    MaxCompI = max((betavals(i,:)+alphavals(i,:)).*x(i,:));
    if MaxComp > 0
        for j = 1:n
            if x(i,j) == 1
               newbetavals(i,j) = MaxCompI -alphavals(i,j);
            end
            end
%             RowsWithNeg1 = find(uconst(:,(i-1)*m+j) == -1);
%             if size(RowsWithNeg,1)>0
%                 for r = 1:size(RowsWithNeg,1)
%                     DriverToCheck = find(uconst(RowsWithNeg1(r,1),:) == 1);
%                     k = mod(DriverToCheck,m);


                
        end
    end
end


