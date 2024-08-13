function[yhat,scenprobs,scenbase,scenexp]=indepy_generate_scens(yprobs,samples,replace)
%%% this code generates random scenarios of driver selections (e.g. for test scenarios)

%%% inputs: yprobs is m x n array of pij (or pij*x if you want test
%%% scenarios) i.e. the probability that each driver will accept each
%%% request, samples is the number of scenarios to generate and is 'all' if 
%%% you want to generate all unique scenarios, replace is 1
%%% if you want to ensure there are no duplicates and is 0 if you want to
%%% just generate once and not check for duplicates (for our experiments
%%% replace =0 and the code for replace=1 is outdated so don't recommend)

%%% outputs: yhat is m x n*samples array of the generated driver
%%% selections, each scenario is m x n and the scenarios are concatenated
%%% horizontally, scenprobs is 1 x samples vector of the scenario likelihoods
%%% normalized so they sum to 1, scenbase and scenexp are 1 x samples
%%% vectors that represent the scientific notation representation of the
%%% un-normalized (i.e. actual) scenario probabilities, that is, prob =
%%% scenbase*10^scenexp

[m,n]=size(yprobs);
ave=mean(mean(yprobs)); %this is the average willingness across driver-request pairs, 
%%% used as a normalizer when calculating scenario weights so they're less
%%% likely to be super small


%%% find and save the locations of the 'nontrivial' entries of pij, i.e
%%% above 0 and below 1 
[locrows,loccols] = find(yprobs>0 & yprobs <1);
nontrivial=size(locrows,1);

%%% if the number of samples we want is higher or at the number of distinct scenarios, find all scenarios 
if 2^nontrivial <= samples
    samples = 'all';
end


if replace==0
    if samples=='all'
        %generate all scens
        totscen=2^nontrivial; %number of distinct scenarios
        yhat=sparse(m,n*totscen); 
        scenprobs=ones(1,totscen);
        scenbase=ones(1,totscen);
        scenexp=zeros(1,totscen);
        %%% we find all the scenarios by considering each scenario to be
        %%% represented by a binary number of length nontrivial, and each 1
        %%% and 0 represents the driver's decision for the driver-request
        %%% pair corresponding to that digit (we skip having digits for
        %%% driver-request pairs where pij is 1 or 0 since that digit will
        %%% always be the same)
        for k=0:totscen-1
            willingness=dec2bin(k,nontrivial); %convert iteration k into a binary number (length nontrivial) to get the scen decisions
            %%% yscen is the temporary variable storing the iteration's
            %%% scenario, initialized as yprobs then change the yprobs
            %%% values that are not 0 or 1 to match the binary willingness
            %%% number
            yscen=yprobs; 
            for ell=1:nontrivial               
                    if willingness(ell)=='1'
                        yscen(locrows(ell,1),loccols(ell,1))=1;
                    else
                        yscen(locrows(ell,1),loccols(ell,1))=0;
                    end
            end
            %save the new scenario into yhat
            yhat(:,k*n + 1:(k+1)*n) =yscen;
            %%% calculate that scenario's probability   
            %val is used as a temporary variable to store the probability a
            %specific driver-request pair's decision happened as it did in
            %the scenario
                for i=1:m
                    for j=1:n
                        if yscen(i,j) == 1
                            val = yprobs(i,j);
                        else
                            val = 1-yprobs(i,j);
                        end
                        newexp=floor(log10(val));
                        newbase=val/(10^newexp);
                        scenexp(1,k+1) = scenexp(1,k+1)+newexp;
                        scenbase(1,k+1) = scenbase(1,k+1)*newbase;
                        %if the scenario base goes above 10 it's not
                        %scientific notation so we divide by 10 and store
                        %the 10 in the exponent
                        if scenbase(1,k+1)>=10
                            scenexp(1,k+1) = scenexp(1,k+1)+1;
                            scenbase(1,k+1) = scenbase(1,k+1)/10;
                        end
                    end
                end
        end
        %%% get the normalized scenprobs
        newscenexp=scenexp-max(scenexp); %cancels out the exponent of the most likely 
        %%% scenario to make values larger so multiplying out the
        %%% scientific notation is less likely to have  numbers that are
        %%% too small to record
        scenprobs=scenbase.*((10*ones(1,totscen)).^newscenexp);
        scenprobs=scenprobs/sum(scenprobs);     
        
    else
        %draw without replacement to desired size
        %if the number of distinct scenarios is <=17000, all scenarios
        %are generated then drawn without replacement
        
        %%% we find all the scenarios by considering each scenario to be
        %%% represented by a binary number of length nontrivial, and each 1
        %%% and 0 represents the driver's decision for the driver-request
        %%% pair corresponding to that digit (we skip having digits for
        %%% driver-request pairs where pij is 1 or 0 since that digit will
        %%% always be the same)
        if 2^nontrivial<= 17000
            scenids = 0:2^nontrivial-1; %array containing all possible scenario id's, 
            %where the id is the decimal form of the binary number
            %representing the scenario decisions
            weights=ones(1,2^nontrivial);
            selections = zeros(1,samples); %%% the vector of scenario id's that are sampled
            yhat=zeros(m,n*samples);
            scenprobs=ones(1,samples);
            scenbase=ones(1,samples);
            scenexp=zeros(1,samples);
            
            
            % calculate the weights of every scenario (i.e. scenario probabilities, but
            % normalized by ave so that as many probabilities as possible
            % are large enough to be recorded), this is done by going
            % through each nontrivial decision in the scenario (i.e. pij >0
            % and <1) and calculate the probability the driver made that
            % decision
            for k=0:2^nontrivial-1
                willingness=dec2bin(k,nontrivial);
                for ell=1:nontrivial
                    if willingness(ell) == '1'
                        weights(1,k+1) = weights(1,k+1)/ave*yprobs(locrows(ell,1),loccols(ell,1));
                    else
                        weights(1,k+1) = weights(1,k+1)/ave*(1-yprobs(locrows(ell,1),loccols(ell,1)));
                    end
                end
            end

            %draw the samples and construct yhat
            for k=1:samples
                %%% draw a scenario out of the scenid pool
                %%% using the calculated weights as liklihoods
                selections(1,k) = randsample(scenids,1,true,weights);
                willingness=dec2bin(selections(1,k),nontrivial);
                %set the weight of the drawn scenario equal to 0 so it
                %won't be redrawn
                weights(scenids == selections(k)) = 0;
                   
                % construct the yhat scneario for the drawn id
                %%% yscen is the temporary variable storing the iteration's
                %%% scenario, initialized as yprobs then change the yprobs
                %%% values that are not 0 or 1 to match the binary willingness
                %%% number
                yscen=yprobs;
                for ell=1:nontrivial               
                        if willingness(ell)=='1'
                            yscen(locrows(ell,1),loccols(ell,1))=1;
                        else
                            yscen(locrows(ell,1),loccols(ell,1))=0;
                        end
                end
                yhat(:,(k-1)*n + 1:k*n) =yscen;
             end
               %%% calculate that scenario's probability 
                %val is used as a temporary variable to store the probability a
                %specific driver-request pair's decision happened as it did in
                %the scenario
                for i=1:m
                    for j=1:n
                        if yscen(i,j) == 1
                            val = yprobs(i,j);
                        else
                            val = 1-yprobs(i,j);
                        end
                        newexp=floor(log10(val));
                        newbase=val/(10^newexp);
                        scenexp(1,k) = scenexp(1,k)+newexp;
                        scenbase(1,k) = scenbase(1,k)*newbase;
                        %if the scenario base goes above 10 it's not
                        %scientific notation so we divide by 10 and store
                        %the 10 in the exponent
                        if scenbase(1,k)>=10
                            scenexp(1,k) = scenexp(1,k)+1;
                            scenbase(1,k) = scenbase(1,k)/10;
                        end
                    end
                end
      
                
                
        %%% if there are more that 17000 distinct scenarios, randomly 
        %%% generate samples and make sure they're unique
        else
            yhat=repmat(yprobs,1,samples); %yhat initialized as yprobs then change the yprobs
                %%% values that are not 0 or 1 to for the driver decisions
                %%% that are stochastic
            scenbase=ones(1,samples);
            scenexp=zeros(1,samples);
            relevantyprobs=zeros(nontrivial,1); %stores the nontrivial yprob values
            for ell=1:nontrivial
                relevantyprobs(ell,1)=yprobs(locrows(ell,1),loccols(ell,1));
            end
            %%% draw [samples] number of scenarios by randomly generating
            %%% each nontrivial driver-request decision for each of
            %%% [samples] scenarios using a bernouillie random process for
            %%% each decision with probability of scucces yprobs
            %%% lonver stores all of the (nontrivial) decision info as a
            %%% samples x nontrivial array so each row is a scenario
            longver =binornd(ones(samples,nontrivial),repmat(relevantyprobs',samples,1));
            
            %use unique to delete any duplicate rows i.e. duplicate drawn
            %scenarios
            uniqsamps=unique(longver,'rows');
            numunique= size(uniqsamps,1); %%% number of unique scenarios that were drawn
            
            %%% if there aren't enough unique scenarios, draw the number of
            %%% scenarios that were deleted as duplicates, check if there
            %%% are now enough unique scenarios. Repeat until desired
            %%% number of unique scenarios
            if numunique<samples
                while true
                    longver(numunique+1:samples,:)=binornd(ones(samples-numunique,nontrivial),repmat(relevantyprobs',samples-numunique,1));
                    uniqsamps=unique(longver,'rows');
                    longver(1:size(uniqsamps,1),:)=uniqsamps;
                    numunique= size(uniqsamps,1);
                    if numunique==samples
                        break
                    end


                end
            end
            
            for k=1:samples
                for ell=1:nontrivial
                    % form yhat by changing the nontrivial entries according to
                    % longver
                    yhat(locrows(ell,1),(k-1)*n+loccols(ell,1)) = longver(k,ell);
                    
                    %%% calculate that scenario's probability 
                    %val is used as a temporary variable to store the probability a
                    %specific driver-request pair's decision happened as it did in
                    %the scenario
                    if longver(k,ell)==1
                        val=yprobs(locrows(ell,1),loccols(ell,1));
                    else
                        val=1-yprobs(locrows(ell,1),loccols(ell,1));
                    end
                    newexp=floor(log10(val));
                    newbase=val/(10^newexp);
                    scenexp(1,k) = scenexp(1,k)+newexp;
                    scenbase(1,k) = scenbase(1,k)*newbase;
                    %if the scenario base goes above 10 it's not
                        %scientific notation so we divide by 10 and store
                        %the 10 in the exponent
                    if scenbase(1,k)>=10
                        scenexp(1,k) = scenexp(1,k)+1;
                        scenbase(1,k) = scenbase(1,k)/10;
                    end
                end
            end

            
            
        end
        %%% get the normalized scenprobs
        newscenexp=scenexp-max(scenexp); %cancels out the exponent of the most likely 
        %%% scenario to make values larger so multiplying out the
        %%% scientific notation is less likely to have  numbers that are
        %%% too small to record
        scenprobs=scenbase.*((10*ones(1,samples)).^newscenexp);
        scenprobs=scenprobs/sum(scenprobs);        
    end
    
else
 %%% this code is old, clearly not doing any replacing and doesn't make
 %%% scenbase or scenexp
 if samples=='all'
        samples=2^(m*n);
    end
    
   yhat=zeros(m,n*samples);
   scenprobs=ones(1,samples);
   
    for k=1:samples 
        yhat(:,(k-1)*n+1:(k-1)*n+n) = binornd(ones(m,n),yprobs);
        for i=1:m
            for j=1:n
                if yhat(i,(k-1)*n+j) == 1
                    scenprobs(1,k) = scenprobs(1,k)/ave*yprobs(i,j);
                else
                    scenprobs(1,k) = scenprobs(1,k)/ave*(1-yprobs(i,j));
                end
            end
        end
    end
end
