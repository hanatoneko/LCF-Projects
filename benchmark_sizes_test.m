function[testobjs,times,abserror,percerror]=benchmark_sizes_test(sizes,testsizes,exh,notes)
%this code does the phase 0 analysis of SLSF 
%this code will, for each size given, use the corresponding theta values to
%make a parameter instance. For this instance, a menu will be made using
%saa. Then the exhaustive performance will be caclulated. This value will
%be compared against several performance analysis trials (three trials of each 
%of whatever sizes are input as 'testsizes'). We'll calculate the percent difference 
%from either the optimal solution's objective or the objective estimate using 100,000 samples, as well as
%keep track of m,n,theta,total number of performance scenarios, and
%runtime. A matlab data file is also outputted into the
%Paper_experiments\phase0 containing all variables, the title includes
%'wexh' for w/ exhahustive performance analysis as the comparison, or
%'noexh' for no exhaustive perf (uses 100,000 samples instead)

%%% NOTE: this code makes one problem instance per problem size, and our
%%% paper analysis considers the analysis of three instances per problem
%%% size, so doing analysis equivalent to the paper requires running this
%%% code three times (can use different notes strings to differentiate the
%%% save files)

%%% inputs: sizes is an array where each row is a different problem size to
%%% test, each row has three column entries: m,n,theta,
%%% testsizes is a k x 1 vector where k is the number of test sample sizes
%%% you want to test, exh is 1 if you are testing smaller sizes and want to
%%% compare against the exhaustive, otherwise exh is 0 and 100,000 test
%%% samples will be calculated and compared with to calculate error, notes
%%% is a string you can add that will be added to the saved file name to
%%% differentiate multiple runs of the code

%%% outputs: this code outputs four arrays each containing performance metric 
%%% values of the trials for each problem size and test sample size: testobjs 
%%% is the performance analysis objective estimates, times is the
%%% performance analysis runtimes, abserror is the absolute error i.e.
%%% opt-obj estimate, and percerror is the % error i.e. (opt-obj est.)/opt.
%%% For each array, each row is a different problem size (corresponding to
%%% the sizes input). The first three row entries are m, n, the number of nontrivial
%%% menu entries (i.e. number of distinct test scenarios is 2^nontrivial).
%%% The next column is the metric value (e.g. obj estimate) for the exhaustive
%%% performance/100,000 samples performance analysis; this column is only
%%% included in testobjs and times. The remaining columns are the metric
%%% values for each trial of each test sample size (e.g. first 3 entries
%%% are the three trials with testsizes(1,1) test sample sizes and so on)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%build empty variable arrays
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



numcols=3*size(testsizes,1)+1+3; %number of columns desired in the results arrays
%%% for each of these recorded metrics, the first column is the number of
%%% requests (m), col 2 is number of drivers (n), 3 is the number of 'nontrivial'
%%% menu items, i.e. requests offered that have 0<p_ij<1 (pij != 1 and !=0)
%%% col 4 is the metric value (e.g. obj estimate) for the exhaustive
%%% performance/100,000 samples performance analysis (this column is only
%%% included in testobjs and times), the remaining columns for these metrics is the obj/time/error/etc of
%%% each of the three trials for each test sample size tested (e.g. first 3 entries
%%% are the three trials with testsizes(1,1) test sample sizes and so on) (we do 500,1000,5000,10000 test scenarios)



testobjs=zeros(size(sizes,1),numcols); %the test objectives recorded for all of the sizes 
times=zeros(size(sizes,1),numcols); %the runtimes recorded for all of the sizes 
abserror=zeros(size(sizes,1),numcols-1); %the error (opt obj-found obj) recorded for all of the sizes 
percerror=zeros(size(sizes,1),numcols-1); %the percent error recorded for all of the sizes 

testobjs(:,1:2)=sizes(:,1:2);
times(:,1:2)=sizes(:,1:2);
abserror(:,1:2)=sizes(:,1:2);
percerror(:,1:2)=sizes(:,1:2);

for s=1:size(sizes,1)
    
    m=sizes(s,1);
    n=sizes(s,2);
    theta=sizes(s,3);
    attempts=1;
    skip=0;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % get menu 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while true
        %generate a parameter instance that has at least 2^(m*n/2) perf scens and require 
        %at least one nonzero pij entry in each row and column
        pijattempts=1;
        while true
            [C,D,r,q,yprobs,Oi,Di,Oj,Dj,drand]=generate_params(m,n,1);
            pijnontrivial=nnz(yprobs)-size(find(yprobs==1),1);
            %check if pij conditions are met
            if pijnontrivial>m*n/2
                if nnz(sum(yprobs,2))==m
                    if nnz(sum(yprobs,1))==n
                        break
                    end
                end
            end
            pijattempts=pijattempts+1;
            %%% give up if it takes more than 1000 attempts
            if pijattempts>1000
                break
            end
        end
        
        %%% solve for menu, requiring that there be between 2^14 and 2^18
        %%% distinct test scenarios if we're doing exhaustive performance
        %%% and at least 2^22 distinct if we're doing 100,000 scen performance
        %%% (if the number of test scenarios is out of the range generate
        %%% new problem instance)
       [yhat,scenprobs,newretention,scenbase,scenexp]=filter_scens(m,n,yprobs,0,0,0,1000000,'t',50);
       [obj,gap,x,v,z,w]=fixed_y_prob_cplex_dot(C,D,r,theta,q,yprobs,yhat,scenprobs,0,0,500,.01,0);

       nontrivial=nnz(x)-(m*n-nnz(x.*yprobs-ones(m,n)))
       totscens=2^nontrivial;
       if exh==1
           if totscens>=2^14
               if totscens<=2^18
                   nontrivial
                   attempts
                   yprobs;
                   x;
                    testobjs(s,3)=nontrivial;
                    times(s,3)=nontrivial;
                    abserror(s,3)=nontrivial;
                    percerror(s,3)=nontrivial;
                   break
               end
           end
       else
          if totscens>=2^22
               nontrivial
               attempts
               yprobs;
               x;
                testobjs(s,3)=nontrivial;
                times(s,3)=nontrivial;
                abserror(s,3)=nontrivial;
                percerror(s,3)=nontrivial;

               break
          end
       end
       %%% give up if 100 menus are made without getting nontrivial in 
       %%% desired range
       if attempts>=100
           skip=1;
           break
       end
       attempts=attempts+1;
    end
    
    
    %%% skip to next problem size if no good menus were found
    if skip==1
        continue
    end
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%performance analysis
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if exh==1
       %%%exhaustive performance, get obj and runtime
       tic
       [opt,objsdexh,dupaveexh,dupsdexh,rejaveexh,rejsdexh,aveassignexh,objvalsexh]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,'all',0,0);
       toc
       testobjs(s,4)=opt
       times(s,4)=toc
   else
        %%%calculate approximation of exhaustive using 100,000 random
        %%%test scenarios, get obj and runtime
       tic
       [opt,objsdexh,dupaveexh,dupsdexh,rejaveexh,rejsdexh,aveassignexh,objvalsexh]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,100000,0,0);
       toc
       testobjs(s,4)=opt
       times(s,4)=toc  
   end
   %%% now do three trials for each perf scen sample size
   for k=1:size(testsizes,1)
       for ell=1:3
           tic
           [objave,objsd,dupave,dupsd,rejave,rejsd,aveassign,objval]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,testsizes(k,1),0,0);
           toc
           testobjs(s,4+3*(k-1)+ell)=objave
           times(s,4+3*(k-1)+ell)=toc
           abserror(s,3+3*(k-1)+ell)=opt-objave
           percerror(s,3+3*(k-1)+ell)=(opt-objave)/opt
              
           
           
       end
   end
   

   %%%%%%%%% create matlab data file
       if exh==1
            stem= sprintf('phase0totwexh%s.mat',notes);
       else
           stem= sprintf('phase0totnoexh%s.mat',notes);
       end
       filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_0\' stem];
       save(filename);
    end
end
               
       
      
      


