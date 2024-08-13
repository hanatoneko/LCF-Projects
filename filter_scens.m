function[newyhat,newprobs,newretention,scenbase,scenexp]=filter_scens(m,n,yprobs,yhat,scenbase,scenexp,filterlevel,filtertype,finalsize)
%%% this code creates mutated scenarios, though was also desinged to
%%% possibly make other types of scenarios
%%% 

%%% yhat and scenbase/scenexp are included as inputs to use for some
%%% scenario type generation (i.e. working from an initial set of scenarios).
%%% Howerver for mutated scenarios, just input these as 0. Filterlevel is
%%% the deviation cap for mutated scenarios, filter type is 't' for mutated
%%% scnenarios, finalsize is the number of scenarios you want outputted
%%% (i.e. sample size)

%%% newyhat is the returned mutated scenarios (m x n scenarios concatenated horizontally)
%%% newprobs is the normalized likelihoods of each scenario (row vector),
%%% newretention isn't used in any of the experiments, scenbase and scenexp
%%% are the scenario likelihoods bronken into the base and exponent of the
%%% scientific notation representation of the likelihood (row vectors)

%currently the 'refill' method doesn't do what it's supposed to



samples=size(yhat,2)/n;
if nnz(yhat)>0
    scaledscenexp=scenexp-max(scenexp);
    scaledprobs=scenbase.*((10*ones(1,samples)).^scaledscenexp);
    scaledprobs=scaledprobs/sum(scaledprobs);
end



if filtertype=='a' %%%for absolute ratio, one passthrough
    maxprob=max(scaledprobs);
    threshold=maxprob/filterlevel;
    relevant=size(find(scaledprobs>=threshold),2);
    retention=relevant/samples;
    newyhat=zeros(m,n*relevant);
    newprobs=zeros(1,relevant);
    counter=1;
    
    
    for k=1:samples
        if scaledprobs(1,k)>=threshold
          newyhat(:,n*(counter-1)+1:n*counter)= yhat(:,n*(k-1)+1:n*k);
          newprobs(1,counter)= scaledprobs(1,k);
          counter=counter+1; 
        end
    end

elseif filtertype=='r' %%% for refill (i.e. filter out scenarios with likelihoods too low then 'refill' to get the initial scenario size and repeat
    attempts=0;
    curryhat=yhat;
    currbase=scenbase;
    currexp=scenexp;
    while true 
        %%% sort out the current scenarios that are above the threshold
        maxexp=max(currexp);
        maxbase=max(currbase(currexp==maxexp));
        thresholdexp=maxexp-log10(filterlevel)
        relevant=size(find(currexp>thresholdexp),2)+size(find(currexp==thresholdexp & currbase>=maxbase),2)
        retention=relevant/samples;
        newyhat=zeros(m,n*relevant);
        newbase=zeros(1,relevant);
        newexp=zeros(1,relevant);
        newretention=finalsize/samples;
        counter=1;
       for k=1:samples
          if currexp(1,k)>thresholdexp
              newyhat(:,n*(counter-1)+1:n*counter)= curryhat(:,n*(k-1)+1:n*k);
              newbase(1,counter)= currbase(1,k);
              newexp(1,counter)= currexp(1,k);
              counter=counter+1;
          elseif currexp(1,k)==thresholdexp
              if currbase>=maxbase
                  newyhat(:,n*(counter-1)+1:n*counter)= curryhat(:,n*(k-1)+1:n*k);
                  newbase(1,counter)= currbase(1,k);
                  newexp(1,counter)= currexp(1,k);
                  counter=counter+1;
              end
           end
       end
        
       %%% see if it's big enough
       if relevant>=finalsize
            newyhat=newyhat(:,1:n*finalsize);
            scaledscenexp=newexp-max(newexp);
            sfinal=size(scaledscenexp,2);
            scaledprobs=newbase.*((10*ones(1,sfinal)).^scaledscenexp);
            scaledprobs=scaledprobs/sum(scaledprobs);
            newprobs=scaledprobs(:,1:finalsize);
           break
       end
       
       %%% now draw new scens and creat new currscens and currprobs
       [addyhat,addprobs,addbase,addexp]=indepy_generate_scens(yprobs,samples-relevant,0);
       curryhat=horzcat(newyhat,addyhat);
       currbase=horzcat(newbase,addbase);
       currexp=horzcat(newexp,addexp);
       
       
       %%% break if this doesn't seem to ever finish
       if attempts>10000
           newyhat=0;
           break
       end

       attempts=attempts+1;
       
    end

elseif filtertype=='t' %for 'top' scenarios, i.e. mutated scenarios
    %initialize yhat as yprobs, since the 1's and 0's will be in any yhat
    %then pij values in (0,1) will be replaced
    %scenario probabilities, split into the base and exponent of the
    %scientific notation of the probability, are initialized as 1=1*10^0
    newyhat=repmat(yprobs,1,finalsize);
    scenbase=ones(1,finalsize);
    scenexp=zeros(1,finalsize);
    
    %mostlikely is the yhat scenario that is most likely
    mostlikely=zeros(m,n);
    for i=1:m
        for j=1:n
            if yprobs(i,j)>(1-yprobs(i,j))
                mostlikely(i,j)=1;
            end
        end
    end
    [locrows,loccols] = find(yprobs>0 & yprobs <1); %finds the locations of nontrivial yprobs entries
    nontrivial=nnz(yprobs)-size(find(yprobs==1),1);
    relevantyprobs=zeros(nontrivial,1);
    relmostlikely=zeros(nontrivial,1);
    for ell=1:nontrivial
        relevantyprobs(ell,1)=yprobs(locrows(ell,1),loccols(ell,1));
        relmostlikely(ell,1)=mostlikely(locrows(ell,1),loccols(ell,1));
    end
    
    %relmostprobs is max(pij, 1-pij) i.e each pair's probability in the
    %most likely scenario
    relmostprobs=max(relevantyprobs,ones(nontrivial,1)-relevantyprobs);
    %longver is the final (nontrivial entries of the) yhat values, it is originally set to the most
    %likely scenario then mutations are added (in a random order from 'choices') until the filterlevel is met 
    longver =repmat(relmostlikely',finalsize,1);
    
    %generate the random choices as binary values for each nontrivial entry
    %for each scenario
    choices=binornd(ones(finalsize,nontrivial),repmat(relevantyprobs',finalsize,1));
    for k=1:finalsize
       pickorder=randperm(nontrivial);
       counter=1;
       %numdiff=0;
       deviation=1;
       
       %make initial set of longver mutations
       while true 

           if choices(k,pickorder(1,counter))~=relmostlikely(pickorder(1,counter),1)              
               longver(k,pickorder(1,counter))=choices(k,pickorder(1,counter));
               deviation=deviation/(1-relmostprobs(pickorder(1,counter),1))*relmostprobs(pickorder(1,counter),1);
              % numdiff=numdiff+1;
           end
           if deviation> filterlevel
               longver(k,pickorder(1,counter))=1-longver(k,pickorder(1,counter));
               %numdiff
               %counter
              break
           end
           if counter==nontrivial
               break
           end
           counter=counter+1;
           
       end
    end
    
    
    uniqsamps=unique(longver,'rows');
    numunique= size(uniqsamps,1);
    attempts=1;
    %make new longver mutations until we have enough unique samples (as we
    %don't want duplicate scenarios)
    while true
        if numunique==finalsize %stop if our sample size is met
            break
        end
        if attempts>1000000 %give up after many attempts
           attempts;
            break
        end
        %make one new yhat (longvernew row) for each yhat/longver row that
        %was a duplicate before so combined we once again have [sample
        %size] scenarios
        longvernew=repmat(relmostlikely',finalsize-numunique,1);
        choices=binornd(ones(finalsize-numunique,nontrivial),repmat(relevantyprobs',finalsize-numunique,1));
        for k=1:finalsize-numunique
           pickorder=randperm(nontrivial);
           counter=1;
           deviation=1;
           while true 
               if choices(k,pickorder(counter))~=relmostlikely(pickorder(counter),1)
                   longvernew(k,pickorder(counter))=choices(k,pickorder(counter));
                   deviation=deviation/(1-relmostprobs(pickorder(counter),1))*relmostprobs(pickorder(counter),1);
               end
               if deviation> filterlevel
                   longvernew(k,pickorder(counter))=1-longvernew(k,pickorder(counter));
                  break
               end
               if counter==nontrivial
                   break
               end
               counter=counter+1;
               

           end
        end
        longver(numunique+1:finalsize,:)=longvernew;
        uniqsamps=unique(longver,'rows');
        longver(1:size(uniqsamps,1),:)=uniqsamps;
        numunique= size(uniqsamps,1);
        attempts=attempts+1;

    end
    if attempts>1000000 %return trivial values if we didn't get enough unique samples in time
        newyhat=0;
        scenexp=0;
        scenbase=0;
    else
        
        % form yhat and calculate scenbase/scenexp
        for k=1:finalsize
            for ell=1:nontrivial
                newyhat(locrows(ell,1),(k-1)*n+loccols(ell,1)) = longver(k,ell);
                if longver(k,ell)==1
                    val=yprobs(locrows(ell,1),loccols(ell,1));
                else
                    val=1-yprobs(locrows(ell,1),loccols(ell,1));
                end
                %each nontrivial entry added to yhat adjusts the scneario
                %likelihood, calculated here based on the change in
                %probability captured as val
                newexp=floor(log10(val));
                newbase=val/(10^newexp);
                scenexp(1,k) = scenexp(1,k)+newexp;
                scenbase(1,k) = scenbase(1,k)*newbase;
               %if multiplying the new likelihood changes the scenbase to
               %be larger than 10, adjust so that scientific notation is
               %properly upheld
                if scenbase(1,k)>=10
                    scenexp(1,k) = scenexp(1,k)+1;
                    scenbase(1,k) = scenbase(1,k)/10;
                end
            end
        end
    end
    newscenexp=scenexp-max(scenexp); %we scale this to normalize the newprobs so that they aren't extremely small values
    newprobs=scenbase.*((10*ones(1,finalsize)).^newscenexp);
    newprobs=newprobs/sum(newprobs);  
    newretention=finalsize/samples;

end

    
   
end


