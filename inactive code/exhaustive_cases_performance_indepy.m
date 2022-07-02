function[objave,objsd,dupave,dupsd,rejave,rejsd]=exhaustive_cases_performance_indepy(C,D,r,q,x,yprobs)
[m,n]=size(x);

%%% this code finds all possible (i.e. the exhaustive set of) test
%%% scenarios for a menu and runs performance analysis on all of these
%%% sceanrios, then returns the average and standard deviation of the set of 
%%% ojbective values (objave and objsd), the average and s.d. of the number of requests accepted by an 
%%% unhappy driver, (dupave and dupsd), and the average and s.d. of the
%%% number of unmatched (rejected) requests (rejave rejsd)

%%% C,D,x,yprobs are all m x n arrays, yprobs is the pij set, r = the match
%%% bonus (m x 1 vector) which can instead just be built into the C values
%%% q is a n x 1 vector of how many requests a driver can fulfill 

%%% create item 'menu' that has the indices of the offered requests
stop=[]; %%% will be  a n x 1 vector, each entry stop_j is the number of possible menu responses from driver j 
menu = cell(1,n);
for j=1:n
    if nnz(x(:,j))>0
        menu{j} = find(x(:,j)); %%% a vector of the requests offered to j
        dim=size(menu{j});
        stop=vertcat(stop, 2^(dim(1)));
    else
        menu{j} = 0;
        stop=vertcat(stop,1);
    end
end


%%%initialize vals

nontrivial=nnz(x)-(m*n-nnz(x.*yprobs-ones(m,n))); %number of nontrivial menu entries (i.e. s.t. pij!=0 and !=1)
totscen=2^nontrivial; %the total number of distinct test scenarios

objvals = zeros(totscen,1);
dupvals = zeros(totscen,1);
rejvals = zeros(totscen,1);
weights = zeros(totscen,1);
col=ones(n,1); %%% entry col_j is a number between 1 and the total possible 
% different menu selections from driver j, to record which selection is
% used currently
check=1;
curr=1;


%%%%%%%%%%%%%%%%% big loop over each scenario
p=1;
while true
    y = zeros(m,n);
    scenprob=1;
    %%% set y values based on current column choices
    for j=1:n
        if menu{j}~= 0
           temp=menu{j};
           accepted=dec2binarray(col(j,1)-1,size(temp,1)); %converts driver j's menu selection number into binary which represents accepts/rejects
           for i=1:size(accepted,2)
               y(temp(i),j)=accepted(1,i);
               %%% calculate the scenario's probability based on these
               %%% selections
               if y(temp(i),j) == 1
                    scenprob = scenprob*yprobs(temp(i),j);
               else
                    scenprob = scenprob*(1-yprobs(temp(i),j));
               end
           end
        end
    end
    %%% performance analysis
    [obj,dup,rej,v,w,z]=menu_performance_indepy(C,D,r,q,x,y);

%     if csv==1
%     fprintf(fid, '%f,%d,%d\n', obj,dup,rej) ;
%     end
    objvals(p,1)=obj;
    dupvals(p,1)=dup;
    rejvals(p,1)=rej;
    weights(p,1)=scenprob;
    %%% advance col choices to the next combination of choices
     if col==stop
        break %stop if we've reached the final possible choice for each driver
    end
    while true
        if col(check)<stop(check)
            col(check)=col(check)+1;
            check=1;
            break
        end
        col(check)=1;
        check=check+1;
        if (check-1)==curr
            curr=curr+1;
            if stop(curr)==1
                curr=curr+1;
            end
            check=1;
            col(curr,1)=col(curr,1)+1;
            break
        end
        
    end 
    
    p=p+1;
end
    


objave = (objvals')*weights;
objsd = std(objvals,weights);
dupave = (dupvals')*weights;
dupsd = std(dupvals,weights);
rejave = (rejvals')*weights;
rejsd = std(rejvals,weights);
