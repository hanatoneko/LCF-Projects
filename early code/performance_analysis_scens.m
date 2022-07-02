function[yhat,scenprobs]=performance_analysis_scens(x,yprobs,samples,replace)
[m,n]=size(yprobs);
ave=mean(mean(yprobs));
% numpicks is the number of options each driver is intereted in
% topkpicks is a numpick*n matrix with the indices of the top k picks for each driver
% yprobs is the m*n matrix with the probability that item i is accepted by driver j if offered
% y is the m*(samples*n) matrix of 1s and 0s telling what drivers accept for each scenario
% scenprobs is a 1*samples vector with the probability that each scenario occurs

%create a matrix of the menu items and their indices WE SKIP THE VALUES
%WHERE AN ITEM IS OFFERED AND P_IJ==1 BUT ASSUME WE CANNOT HAVE X==1 AND
%P_I
[locrows,loccols] = find(x>=0.5 & yprobs <1);
nontrivial=size(find(yprobs<1 & x>=0.5),1);


if replace==0
    if samples=='all'
        %generate all scens
        totscen=2^nontrivial;
        allscens=zeros(m,n*totscen);
        weights=ones(1,totscen);
        for k=0:totscen-1
            willingness=dec2binarray(k,nontrivial);
            yscen=x;
            for ell=1:nontrivial
                    if willingness(ell)==1
                        weights(1,k+1) = weights(1,k+1)/ave*yprobs(locrows(ell,1),loccols(ell,1));
                        
                    else
                        yscen(locrows(ell,1),loccols(ell,1))=0;
                        weights(1,k+1) = weights(1,k+1)/ave*(1-yprobs(locrows(ell,1),loccols(ell,1)));
                    end
            end
            allscens(:,k*n + 1:(k+1)*n) =yscen;
             
        end

        yhat=allscens;
        scenprobs=weights;
        
    else
        %draw without replacement to desired size
        %if the number of samples is >=%10 of total samples, all scenarios
        %are generated then drawn without replacement
       
        if 1==0 

            bit='flagged'
            scenids = 0:2^nontrivial-1;
            weights=ones(1,2^nontrivial);
            selections = zeros(1,samples);
            yhat=zeros(m,n*samples);
            scenprobs=ones(1,samples);
            % calculate the weights
            for k=0:2^nontrivial-1
                willingness=dec2binarray(k,nontrivial);
                for ell=1:nontrivial
                    if willingness(ell) == 1
                        weights(1,k+1) = weights(1,k+1)/ave*yprobs(locrows(ell,1),loccols(ell,1));
                    else
                        weights(1,k+1) = weights(1,k+1)/ave*(1-yprobs(locrows(ell,1),loccols(ell,1)));
                    end
                end
            end
            %draw the samples and construct yhat
            for k=1:samples
                selections(k) = randsample(scenids,1,true,weights);
                willingness=dec2binarray(selections(1,k),nontrivial);
                scenprobs(k)=weights(1,selections(k)+1);
                weights(scenids == selections(k)) = 0;
                yscen=x;               
                for ell=1:nontrivial
                    if willingness(ell)==0
                        yscen(locrows(ell,1),loccols(ell,1))=0;
                    end
                end
                yhat(:,n*(k-1)+1:n*k)=yscen;
            end
        %%% generate scenarios and make sure they're unique
        else
            yhat=repmat(x,1,samples);
            scenbase=ones(1,samples);
            scenexp=zeros(1,samples);
            relevantyprobs=zeros(nontrivial,1);
            for ell=1:nontrivial
                relevantyprobs(ell,1)=yprobs(locrows(ell,1),loccols(ell,1));
            end
            longver =binornd(ones(samples,nontrivial),repmat(relevantyprobs',samples,1));
            uniqsamps=unique(longver,'rows');
            numunique= size(uniqsamps,1);

            while true
                longver(numunique+1:samples,:)=binornd(ones(samples-numunique,nontrivial),repmat(relevantyprobs',samples-numunique,1));
                uniqsamps=unique(longver,'rows');
                longver(1:size(uniqsamps,1),:)=uniqsamps;
                numunique= size(uniqsamps,1);
                if numunique==samples
                    break
                end
            end

            for k=1:samples
                for ell=1:nontrivial
                    yhat(locrows(ell,1),(k-1)*n+loccols(ell,1)) = longver(k,ell);
                    if longver(k,ell)==1
                        val=yprobs(locrows(ell,1),loccols(ell,1));
                    else
                        val=1-yprobs(locrows(ell,1),loccols(ell,1));
                    end
                    newexp=floor(log10(val));
                    newbase=val/(10^newexp);
                    scenexp(1,k) = scenexp(1,k)+newexp;
                    scenbase(1,k) = scenbase(1,k)*newbase;
                    if scenbase(1,k)>=10
                        scenexp(1,k) = scenexp(1,k)+1;
                        scenbase(1,k) = scenbase(1,k)/10;
                    end
                end
            end
        end
        
        
        scenexp=scenexp-max(scenexp);
        scenprobs=scenbase.*((10*ones(1,samples)).^scenexp);
        scenprobs=scenprobs/sum(scenprobs);
%         
%         yhat=zeros(m,n*samples);
%         scenprobs=ones(1,samples);
%         longver = 2*ones(samples,nnz(x));
%         relevantyprobs=zeros(nnz(x),1);
%         for ell=1:nnz(x)
%             relevantyprobs(ell,1)=yprobs(menu(ell,1),menu(ell,2));
%         end
%         for k = 1:samples
%             while true
%                 y=binornd(ones(nnz(x),1),relevantyprobs);
%                 %if the drawn scenario isn't in the previously sampled set,
%                 %add it to the set of scenarios
%                 if ismember(y',longver,'rows')==0
%                     for ell=1:nnz(x)
%                         yhat(menu(ell,1),(k-1)*n+menu(ell,2)) = y(ell,1);
%                     end
%                     longver(k,:)=y';
%                     
%                     for i=1:m
%                         for j=1:n
%                             if yhat(i,(k-1)*n+j) == 1
%                                 scenprobs(1,k) = scenprobs(1,k)/mean(mean(yprobs))*yprobs(i,j);
%                             else
%                                 scenprobs(1,k) = scenprobs(1,k)/mean(mean(yprobs))*(1-yprobs(i,j));
%                             end
%                         end
%                     end
%                     break
%                 end
%             end
%             selections(k) = randsample(scenids,1,true,weights);
%             scenprobs(k)=weights(1,selections(k));
%             weights(scenids == selections(k)) = 0;
%             yhat(:,n*(k-1)+1:n*k)=allscens(:,n*(selections(k)-1)+1:n*selections(k));
    end
    
else
    if samples=='all'
        samples=2^(nnz(x));
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
