function[uconst,rhsconst] = create_uconst(x,eqtype,drivprox_thresh,reqprox_thres,reqdist_buffer,Oj,Dj,Oi,Di,alphavals,mins,driverparams)
%creates the fairness constraint uconst as well as the corresponding rhs

%eqtype is the type of fairness constraint used: 'eq' for all equal comp,
%'ch'=closer driver receives higher (or gets same if similar dist), 'wr'= equal comp for drivers w/in
%radius of req, 'dp'=same comp for drivers in close proximity


%drivprox_thresh is the threshold value for 'dp', reqprox is for 'wr' (the one we're not using), reqdist is for 'ch'

%Oj/Oi is drivers'/riders' origin nodes, Dj/Di are destinations (column vectors), mins is
%the matrix of travel times you get from the trip data file from any demand
%node (row 1 is node 1) to any demand node (col 1 is node 1) (the origins and destinations)
%alphavals is an m x n matrix of the alpha parameter values
%driver params is added as a potential extension to consider some parameter
%representing the driver's history etc.


[m,n]=size(x);
% if eqtype ~= 'eq'
%     [miles,mins]=loadtripinfo();
%     tripinfo=cat(3,miles,mins);
% end

uconst = zeros(1,m*n);
rhsconst = 0;
for i = 1:m
    %%% identify drivers that are offered this request
    driverset = find(x(i,:))';
    %%% pull out trip info for our drawn OD pairs
    for j = 1:size(driverset,1)
        for k = 1:size(driverset,1)
            %use needsconst variable to decide if we need comp_ij<=comp_ik
            if j ~= k
                needsconst = 1; %for all equality
                if eqtype == 'dp' %doesn't need const if drivers are far from each other
                    minsOjOk= mins(Oj(driverset(j,1)),Oj(driverset(k,1))); %(this is one scalar)
                    minsOkOj= mins(Oj(driverset(k,1)),Oj(driverset(j,1)));
                    if (minsOjOk + minsOkOj)/2 >= drivprox_thresh
                        needsconst = 0;
                    end
                    
                 %%% removed this one
                elseif eqtype == 'wr' %doesn't need const if one or both drivers are far from req
                    minsOjOi= mins(Oj(driverset(j,1)),Oi(i));
                    minsOkOi= mins(Oj(driverset(k,1)),Oi(i));
                    if  minsOjOi >= reqprox_thresh
                        needsconst = 0;
                    elseif minsOkOi >= reqprox_thresh
                        needsconst = 0;
                    end
                    
                 elseif eqtype == 'ch' %doesn't need const if driv j is closer than driv k
                    minsOjOi = mins(Oj(driverset(j,1)),Oi(i));
                    minsOkOi = mins(Oj(driverset(k,1)),Oi(i));
                    if  minsOkOi - minsOjOi >= reqdist_buffer
                        needsconst = 0;
                    end
                end
                
                %add const if needs const is still 1
                if needsconst == 1
                    uconstnew = zeros(1,m*n);
                    rhsconst = vertcat(rhsconst,alphavals(i,driverset(k,1))-alphavals(i,driverset(j,1)));
                    uconstnew(1,(driverset(j,1)-1)*m + i) = 1;
                    uconstnew(1,(driverset(k,1)-1)*m + i) = -1;
                    uconst = vertcat(uconst,uconstnew);
                    
                end
            end
        end
    end
end

if size(uconst,1) > 1 %take off the first row if at least one row was added, as we saved it as zeros so it wouldn't be empty
    uconst = uconst(2:size(uconst,1),:);
    rhsconst = rhsconst(2:size(rhsconst,1),:);
end