function[true_sorted,heur_sorted]=compare_assmts_diff_scens(m,n,theta,saasamps,verifsamps,heursamps,trials)
%%% saasamps is the number of samples used for saa to make the menus
%%% verifsamps is a 1-by-q vector of the number of scenarios/samples used in the optimal assignment
%%% analysis for each test you want to do (each 'test' calculates the average objective over the specified number of scenarios
%%%heursamps is the number of scenarios tested in the heuristic analysis

kpercentage=1; %the portion of requests that have a positive p_ij

equal=1;
lwr=1;
alpha=m*ones(1,n);
addpath(genpath('C:\Users\hanna\OneDrive\Documents\MATLAB\yalmip'));
addpath(genpath('C:\Program Files\IBM\ILOG\CPLEX_Studio128\cplex\matlab\x64_win64'));


heur=zeros(trials,1);
true_sampled=zeros(trials,size(verifsamps,2));


% generate the data
C=0.5*ones(m,n)+rand(m,n);
D=ones(m,n)+0.3*rand(m,n);
r=ones(m,1)+ones(m,1);
a=n*ones(m,1);
assigncap=m*ones(n,1);
[topkpicks,yprobs]=indepy_generate_yprobs(m,n,kpercentage)

for t=1:trials
     %generate a menu
    [y,scenprobs]=indepy_generate_scens(m,n,topkpicks,yprobs,saasamps);
    [obj,x,v,z,w]=fixed_y_prob(C,D,r,a,theta,assigncap,y,scenprobs,topkpicks,equal,lwr);
   

    %%% performance analysis

    %%% for heuristic %%%%%%%%%%%%%%%%%%%%%%%
    %%%initialize vals
    %optobjvals = zeros(totscen,1);
    heurobjvals = zeros(heursamps,1);
    weights = ones(heursamps,1);



    %%%%%%%%%%%%%%%%% sample scenarios and run performance analysis

    for k=1:heursamps
        y= binornd(ones(m,n),yprobs);
            for i=1:m
                for j=1:n
                    if y(i,j) == 1
                        weights(k,1) = weights(k,1)*yprobs(i,j);
                    else
                        weights(k,1) = weights(k,1)*(1-yprobs(i,j));
                    end
                end
            end

           %%% performance analysis
          [obj,dup,rej,v,w,z]=approx_assgn(C,D,r,x,y);
          heurobjvals(k,1)=obj;

    end

    heur(t,1) = (heurobjvals')*weights/sum(weights);

    %%%% do the analysis for each test of the opt assign %%%%%%%%%%%%%%%%%%

    for q=1:size(verifsamps,2)
    %%%initialize vals
    optobjvals = zeros(verifsamps(1,q),1);
    weights = ones(verifsamps(1,q),1); 

    for k=1:verifsamps(1,q)
        y= binornd(ones(m,n),yprobs);
            for i=1:m
                for j=1:n
                    if y(i,j) == 1
                        weights(k,1) = weights(k,1)*yprobs(i,j);
                    else
                        weights(k,1) = weights(k,1)*(1-yprobs(i,j));
                    end
                end
            end


          [obj,dup,rej,v,w,z]=menu_performance_indepy(C,D,r,alpha,x,y);
          optobjvals(k,1)=obj;

    end


    true_sampled(t,q) = (optobjvals')*weights/sum(weights);

    end
end

%%%
%%% assume last opt assign test set is most valid so sort based on those
%%% entries
[true_sortedmain, true_order] = sort(true_sampled(:,size(verifsamps,2)));
heur_sorted = heur(true_order,:);
true_sorted = true_sampled(true_order,:);




