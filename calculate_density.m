function[DensityNums] = calculate_density(x,eqtype,uconst)
%inputs: menu x, eqtype is 'dp' for driver proximity, 'ch' for closer
%higher, uconst is the constraint matrix for u
%density is an array with 1 row per request and 4 cols:
%col 1 =number times offered
%col 2 = number of possible pairs to constrain
%col 3 = number of pairs constrained
%col 4 = % of pairs constrained

[m,n] = size(x);
NumMetrics = 4;
DensityNums = zeros(m,NumMetrics);
DensityNums(:,1) = sum(x,2);
DensityNums(:,2) = DensityNums(:,1).*(DensityNums(:,1)-ones(m,1))/2;
if nnz(uconst)> 0
    for t = 1:size(uconst,1)
        %%% for each row in uconst, add the pair to the right row of densitynums
        TempMat = uconst(t,:);
        ULocations = find(TempMat ~=0); %indices of the two nonzero vals in the const row
        ReqIndex = mod(ULocations(1,1),m); %figures out which request const is for
        if ReqIndex == 0
            ReqIndex = m;
        end
        DensityNums(ReqIndex,3) = DensityNums(ReqIndex,3) + 1; %adds tally
    end



    if eqtype == 'dp'
        DensityNums(:,3) = DensityNums(:,3)/2;
    elseif eqtype == 'ch'
       DensityNums(:,3) = DensityNums(:,3) - DensityNums(:,2); 
    end

end

DensityNums(:,4) = DensityNums(:,3)./DensityNums(:,2);
for i =1:m
   if DensityNums(i,2) == 0
       DensityNums(i,4) = 0;
   end
end