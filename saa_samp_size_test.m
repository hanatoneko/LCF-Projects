function[testobjs,times,perctimesaved,abserror,percerror,menunzs]=saa_samp_size_test(mnsizes,saasizes,exh,notes)
%%% this code does the phase 1 analysis of SLSF 
%this code will, for each size given, make one parameter instance. For this instance, three menus will be made using
%SLSF for each sample size. Then we'll calculate the optimal menu (using
%exhaustive set of training scenarios) if exh=1. We then do performance
%analysis on each menu using random test scenarios generated using the
%union set of menus from the same problem instance (including opt menu if
%applicable), using the same set of test scenarios to test each menu in the instance.
%We compare performance of each menu with either the optimal menu or the
%menu in the instance with the highest objective value. A matlab data file is also outputted into the
%Paper_experiments\phase1 containing all variables, the title includes
%'wexh' for using the optimal menu (with exhaustive training scenario sample set) as the comparison, or
%'noexh' for no exhaustive training sample set (uses best-found menu instead)

%%% NOTE: this code makes one problem instance per problem size, and our
%%% paper analysis considers the analysis of three instances per problem
%%% size, so doing analysis equivalent to the paper requires running this
%%% code three times (can use different notes strings to differentiate the
%%% save files)


%%% inputs: mnsizes is an array where each row is a different problem size to
%%% test, each row has three column entries: m,n,theta,
%%% saasizes is a k x 1 vector where k is the number of training sample sizes
%%% you want to use, exh is 1 if you are finding the optimal menu using the exhaustive
%%% set of training scenarios, otherwise exh is 0 and error will be calculated
%%% by comparing with the best-found menu in the problem instance, notes
%%% is a string you can add that will be added to the saved file name to
%%% differentiate multiple runs of the code

%%% outputs: this code outputs six arrays each containing performance metric 
%%% values of the trials for each problem size and saa sample size: testobjs 
%%% is the performance analysis objective estimates, times is the
%%% SLSF solver runtimes, perctimesaved compares runtime of a menu to the runtime
%%% of the opt/best-found menu (opt time-time)/opt time, abserror is the absolute error i.e.
%%% opt-obj estimate, percerror is the % error i.e. (opt-obj est.)/opt,
%%% menunzs is the total number of items offered across the menu (i.e.
%%% number of nonzero entries in x).
%%% For each of these arrays, each row is a different problem size (corresponding to
%%% the mnsizes input). The first three row entries are m, n, the number of nontrivial
%%% pij entries (i.e. number of distinct saa scenarios is 2^nontrivial).
%%% The next column is the metric value (e.g. obj estimate) for the optimal menu/best-found 
%%% menu, samples performance analysis; this column is only
%%% included in testobjs, times and menunzs. The remaining columns are the metric
%%% values for each trial of each saa sample size (e.g. first 3 entries
%%% are the three trials with saasizes(1,1) saa sample sizes and so on).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%build empty variable arrays
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


numcols=3*size(saasizes,1)+1+3;%number of columns desired in the results arrays
%%% for each of these recorded metrics, the first column is the number of
%%% requests (m), col 2 is number of drivers (n), 3 is the number of 'nontrivial'
%%% pij values, i.e. driver-request pairs with 0<p_ij<1 (pij != 1 and !=0)
%%% col 4 is the metric value (e.g. obj estimate) for the optimal/best-found
%%% menu (this column is only included in testobjs, times, and menunzs), 
%%% the remaining columns for these metrics is the obj/time/error/etc of
%%% each of the three trials for each saa sample size tested (e.g. first 3 entries
%%% are the three trials with sizes(1,1) saa sample sizes and so on) (we do 10, 50,100,500,1000 saa scenarios)

testobjs=zeros(size(mnsizes,1),numcols); %the test objectives recorded for all of the sizes 
times=zeros(size(mnsizes,1),numcols); %the runtimes recorded for all of the sizes
perctimesaved=zeros(size(mnsizes,1),numcols-1); %compares runtime of a menu to the runtime of the opt/best-found menu
abserror=zeros(size(mnsizes,1),numcols-1); %the error (opt obj-found obj) recorded for all of the sizes 
percerror=zeros(size(mnsizes,1),numcols-1); %the percent error recorded for all of the sizes 
menunzs=zeros(size(mnsizes,1),numcols); %total number of items offered across the menu (i.e. number of nonzero entries in x)

testobjs(:,1:2)=mnsizes(:,1:2);
times(:,1:2)=mnsizes(:,1:2);
perctimesaved(:,1:2)=mnsizes(:,1:2);
abserror(:,1:2)=mnsizes(:,1:2);
percerror(:,1:2)=mnsizes(:,1:2);
menunnz(:,1:2)=mnsizes(:,1:2);


% for each problem size
for s=1:size(mnsizes,1)
    m=mnsizes(s,1);
    n=mnsizes(s,2);
    theta=mnsizes(s,3);
    attempts=1;
    
    
    while true
        pijattempts=1;
        
        %generate a yprobs that has at least 2^(m*n/2) distinct training scens (or 2^8 when w/ exh), else try again
        %also require at least one nonzero pij entry in each row and column
        while true


            [C,D,r,q,yprobs,Oi,Di,Oj,Dj,drand]=generate_params(m,n,1);
            pijnontrivial=nnz(yprobs)-size(find(yprobs==1),1);
            %check if pij conditions are met and save info if they are
            if exh==1
                if pijnontrivial>9
                    if nnz(sum(yprobs,2))==m
                        if nnz(sum(yprobs,1))==n
                            if pijnontrivial<14
                                testobjs(s,3)=pijnontrivial;
                                times(s,3)=pijnontrivial;
                                perctimesaved(s,3)=pijnontrivial;
                                abserror(s,3)=pijnontrivial;
                                percerror(s,3)=pijnontrivial;
                                menunnz(s,3)=pijnontrivial;
                            break
                            end
                        end
                    end
                end
            else
               if pijnontrivial>m*n/3
                    if nnz(sum(yprobs,2))==m
                        if nnz(sum(yprobs,1))==n
                            testobjs(s,3)=pijnontrivial;
                            times(s,3)=pijnontrivial;
                            perctimesaved(s,3)=pijnontrivial;
                            abserror(s,3)=pijnontrivial;
                            percerror(s,3)=pijnontrivial;
                            menunnz(s,3)=pijnontrivial;
                            break
                        end
                    end
               end
            end
            pijattempts=pijattempts+1;
             %%% give up if it takes more than 1000 attempts
            if pijattempts>1000
                continue
            end
            pijattempts=pijattempts+1;

        end



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% if exh=1, find optimal menu and initialize x-union, the union
        %%% of the menus for the given problem instance. 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         xunion=zeros(m,n);
         bigx=zeros(m,n*3*size(saasizes,1)); %big matrix saving all of the menus so we can access them for perf analysis
         if exh==1
            [yhat,scenprobs,scenbase,scenexp]=indepy_generate_scens(yprobs,'all',0);
          tic
           [opt,gap,xopt,v,z,w]=fixed_y_prob_cplex_dot(C,D,r,theta,q,yprobs,yhat,scenprobs,0,0,500,.01,0);
            toc
            opt
            xunion=xopt;

            times(s,4)=toc
            menunzs(s,4)=nnz(xopt)
            
            %If the time needed to solve SLSF is >500 seconds, the solver
            %probably terminated without actually finding the optimal
            %solution. If this is the case, start over with a new problem
            %instance, else continue to next step
            if times(s,4)<500
                break
            end
            
         else
             break
         end
         
         % if 10 optimal menus require >500 seconds, give up on problem instance
         if attempts>10
             continue
         end
         attempts=attempts+1;
    end
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% solve for the menus for each trial of each saa sample size and the x-union (union of the menus)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   for k=1:size(saasizes,1)
       for ell=1:3
            if 2^pijnontrivial>saasizes(k,1)

                %get mutated scenarios
               [yhat,scenprobs,newretention,scenbase,scenexp]=filter_scens(m,n,yprobs,0,0,0,1000000,'t',saasizes(k,1));
               %solve SLSF
               tic
               [obj,gap,x,v,z,w]=fixed_y_prob_cplex_dot(C,D,r,theta,q,yprobs,yhat,scenprobs,0,0,500,.01,0);
                toc

               yprobs
               x
               xunion=max(xunion,x);
               bigx(:,n*((k-1)*3+ell-1)+1:n*(3*(k-1)+ell))=x;
                times(s,4+3*(k-1)+ell)=toc
                menunzs(s,4+3*(k-1)+ell)=nnz(x)
                    

            end
       end
   end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%performance analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%generate 5000 (or exh set if <5000) scens based on xunion 
    xnontriv=nnz(xunion)-(m*n-nnz(xunion.*yprobs-ones(m,n)));

   
   if 5000<2^xnontriv
   [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(yprobs.*xunion,5000,0);
   else
       [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(yprobs.*xunion,'all',0);
   end

   %performance analysis of optimal menu if applicable
   if exh==1
       [opt,objsdexh,dupaveexh,dupsdexh,rejaveexh,rejsdexh,aveassignexh,objvalsexh]=sample_cases_performance_indepy(C,D,r,q,xopt,yprobs,min(5000,2^xnontriv),testyhat,testscenprobs);

       testobjs(s,4)=opt

   end

   %%% now do perf analysis for the menu for each trial of each saa sample
   %%% size
   for k=1:size(saasizes,1)
       for ell=1:3
           %if the menu has a nonzero entry
           if nnz(bigx(:,n*((k-1)*3+ell-1)+1:n*(3*(k-1)+ell)))>0

           [objave,objsd,dupave,dupsd,rejave,rejsd,aveassign,objval]=sample_cases_performance_indepy(C,D,r,q,bigx(:,n*((k-1)*3+ell-1)+1:n*(3*(k-1)+ell)),yprobs,min(5000,2^xnontriv),testyhat,testscenprobs);
 
           testobjs(s,4+3*(k-1)+ell)=objave
              

           end
       end
   end
   
   %if we're comparing against best-found menu, find and save it's info
    if exh==0
        [opt,col]=max(testobjs(s,5:4+3*size(saasizes,1)));
        testobjs(s,4)=opt
        menunzs(s,4)=menunzs(s,col+4)
        times(s,4)=times(s,4+col)
    end
    
    %calculate the comparison metrics
    perctimesaved(s,4:3+3*size(saasizes,1))=(times(s,4)*ones(1,3*size(saasizes,1))- times(s,5:4+3*size(saasizes,1)))/times(s,4)
    abserror(s,4:3+3*size(saasizes,1))=testobjs(s,4)*ones(1,3*size(saasizes,1))- testobjs(s,5:4+3*size(saasizes,1))
    percerror(s,4:3+3*size(saasizes,1))=(testobjs(s,4)*ones(1,3*size(saasizes,1))- testobjs(s,5:4+3*size(saasizes,1)))/testobjs(s,4)
       
      
    %create matlab data file
    stem= sprintf('phase1%dx%d%s.mat',m,n,notes);
   filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_1\' stem];
   save(filename);  
   
end




if exh==1
    stem= sprintf('phase1totwexh%s.mat',notes);
else
   stem= sprintf('phase1totnoexh%s.mat',notes);
end
filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_1\' stem];
save(filename);     
      
      


