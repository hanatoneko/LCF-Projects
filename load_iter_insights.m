%this code was made to facilitate analysis comparing solution properties of different iterations of
%SOL-IT solutions for the main SOL-IT experiment (SOL-IT_10(5,5)).  When the 
% SOL-IT experiments are conducted, each iteration is run individually
%and has its own data file produced. This code produces a single matlab
%data file named 'concat_vals.mat' that contains variable/soln information
%from every iteration (and the initial SLSF soln) by loading each iteration
%one at a time and adding that iteration's information into a set of
%larger variables that are concatenated variables from the iterations, containing _concat in the variable names.
%The _concat variables are each iteration's info vertically concatenated,
%that is the slsf info (if applicable) is on the top, then the iteration 1
%info then iteration 2 and so on


trials = 100;
numiters = 10; %number of iterations
m = 20;
n = 20;
minitestsize = 200;
testsamps = 5000;
fixedscens_lcf_it = 5;
variscens_lcf_it = 5;



%%%%%% initialize storage variables %%%%%%

%%% history is what was the best-found solution as of each iteration, changes is all
%%% zeros execpt a 1 in row i col t means iteration i soln became new best
%%% soln for trial t
guessbestiter_history = zeros(numiters,trials);
guessbestiter_changes = zeros(numiters,trials);



%soln variable info 
slsfcomp_concat = zeros(m*(numiters+1),n*trials);
yprobs_concat = zeros(m*(numiters+1),n*trials);
x_lcf_it_concat = zeros(m*(numiters),n*trials);
p_lcf_it_concat = zeros(m*(numiters),n*trials);
ptrue_lcf_it_concat = zeros(m*(numiters),n*trials);
u_lcf_it_concat = zeros(m*(numiters),n*trials);
v_lcf_it_concat = zeros(m*trials*(numiters),n*(fixedscens_lcf_it + variscens_lcf_it)); %the assignment used in the training scenarios 
runtimes_slsf_concat = zeros(numiters,trials);
runtimes_lcf_it_concat = zeros(numiters,trials);

% minitest soln info (slsf is first 'line')
testyhat_mini_concat = zeros(m*trials*(numiters+1),n*minitestsize);
testscenprobs_mini_concat = zeros(trials*(numiters+1),minitestsize);

runtimes_mini_concat = zeros(numiters+1,trials);
testobjave_mini_concat = zeros(numiters+1,trials);
testrejave_mini_concat = zeros(numiters+1,trials);
testdupave_mini_concat = zeros(numiters+1,trials);



%soln info for large perf analysisc(slsf is first 'line')
testyhat_lcf_it_concat = zeros(m*trials*(numiters+1),n*testsamps);
testscenprobs_lcf_it_concat = zeros(trials*(numiters+1),testsamps);
testobjs_lcf_it_concat = zeros(trials*(numiters+1),testsamps);
testobjave_lcf_it_concat = zeros(numiters+1,trials);
testdupave_lcf_it_concat = zeros(numiters+1,trials);
testrejave_lcf_it_concat = zeros(numiters+1,trials);
testv_lcf_it_concat = zeros(m*trials*(numiters+1),n*testsamps);
testz_lcf_it_concat = zeros(m*trials*(numiters+1),n*testsamps);
testw_lcf_it_concat = zeros(m*trials*(numiters+1),testsamps);
aveassign_lcf_it_concat = zeros(m*(numiters+1),n*trials);

avecomp_lcf_it_concat = zeros(numiters+1,trials);
aveperccomp_lcf_it_concat = zeros(numiters+1,trials);
avetotprofit_lcf_it_concat = zeros(numiters+1,trials);
percposprofit_lcf_it_concat = zeros(numiters+1,trials);
aveextratime_lcf_it_concat = zeros(numiters+1,trials);

%%%%%%%%%%%%%%%%%%% load and save for each iteration (skipping initial SLSF soln
%%%%%%%%%%%%%%%%%%% info for now)
%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i_concat = 1:numiters
    
    %load the file
    stem = sprintf('lcf_it_iterperfI%dP10FS5VS5.mat',i_concat);
     filename = [ 'C:\Users\horneh\Documents\LCF_Paper_experiments\LCF_IT_iterperf\' stem];
    load(filename);
     
    %%% save the guessbestiter_changes
    for t_concat = 1:trials
          if guessbestiter_lcf_it_noperf(1,t_concat) == i_concat

                guessbestiter_changes(i_concat,t_concat) = 1;
          end
 
    end
    
    guessbestiter_history(i_concat,:)= guessbestiter_lcf_it_noperf;
    v_lcf_it_concat((i_concat-1)*m*trials+1:m*trials*(i_concat),:) = v_lcf_it_noperf;
     

    %soln variable info 
    if i_concat > 1
        %for these only need to do after first iteration as we know what
        %they are in the first iteration
        slsfcomp_concat((i_concat-1)*m+1:m*i_concat,:) = slsfcomp_new_lcf_it_noperf;
        yprobs_concat((i_concat-1)*m+1:m*i_concat,:) =yprobslong_new_lcf_it_noperf;
        runtimes_slsf_concat(i_concat,:) = runtimes_slsf_lcf_it_noperf;
    end
    x_lcf_it_concat((i_concat-1)*m+1:m*i_concat,:) =  x_lcf_it_noperf;
    p_lcf_it_concat((i_concat-1)*m+1:m*i_concat,:) = p_lcf_it_noperf;
    ptrue_lcf_it_concat((i_concat-1)*m+1:m*i_concat,:) = ptrue_lcf_it_noperf;
    u_lcf_it_concat((i_concat-1)*m+1:m*i_concat,:) = u_lcf_it_noperf;
   
    runtimes_lcf_it_concat(i_concat,:) = runtimes_lcf_it_noperf;

    % minitest soln info (slsf is first 'line')
    testyhat_mini_concat((i_concat)*m*trials+1:m*trials*(i_concat+1),:) = testyhat_mini_lcf_it_noperf;
    testscenprobs_mini_concat((i_concat)*trials+1:(i_concat+1)*trials,:) = testscenprobs_mini_lcf_it_noperf;

    runtimes_mini_concat(i_concat+1,:) = runtimes_mini_lcf_it_noperf;
    testobjave_mini_concat(i_concat+1,:) = testobjave_mini_lcf_it_noperf;
    testrejave_mini_concat(i_concat+1,:) = testrejave_mini_lcf_it_noperf;
    testdupave_mini_concat(i_concat+1,:) = testdupave_mini_lcf_it_noperf;



    %soln info for large perf analysisc(slsf is first 'line')
    testyhat_lcf_it_concat((i_concat)*m*trials+1:m*trials*(i_concat+1),:) = testyhat_lcf_it_iterperf;
    testscenprobs_lcf_it_concat((i_concat)*trials+1:(i_concat+1)*trials,:) = testscenprobs_lcf_it_iterperf;
    testobjs_lcf_it_concat((i_concat)*trials+1:(i_concat+1)*trials,:) = testobjs_lcf_it_iterperf;
    testobjave_lcf_it_concat(i_concat+1,:) = testobjave_lcf_it_iterperf;
    testdupave_lcf_it_concat(i_concat+1,:) = testdupave_lcf_it_iterperf;
    testrejave_lcf_it_concat(i_concat+1,:) = testrejave_lcf_it_iterperf;
    testv_lcf_it_concat((i_concat)*m*trials+1:m*trials*(i_concat+1),:) = testv_lcf_it_iterperf;
    testz_lcf_it_concat((i_concat)*m*trials+1:m*trials*(i_concat+1),:) = testz_lcf_it_iterperf;
    testw_lcf_it_concat((i_concat)*m*trials+1:m*trials*(i_concat+1),:) = testw_lcf_it_iterperf;
    aveassign_lcf_it_concat((i_concat)*m+1:(i_concat+1)*m,:) = aveassign_lcf_it_iterperf;

    avecomp_lcf_it_concat(i_concat+1,:) = avecomp_lcf_it_iterperf;
    aveperccomp_lcf_it_concat(i_concat+1,:) = aveperccomp_lcf_it_iterperf ;
    avetotprofit_lcf_it_concat(i_concat+1,:) = avetotprofit_lcf_it_iterperf;
    percposprofit_lcf_it_concat(i_concat+1,:) = percposprofit_lcf_it_iterperf; 
    aveextratime_lcf_it_concat(i_concat+1,:) = aveextratime_lcf_it_iterperf;
    
    
end


%%%% calculate and save slsfcomp and yprobs that result from iter 10 soln
%as it wasn't calculated during the experiment
for t_concat = 1:trials
   [C,yprobs,newcomp] = generate_comp_iter(alphavalslong(:,(t_concat-1)*n+1:t_concat*n)+u_lcf_it_concat(9*m+1:m*10,(t_concat-1)*n+1:t_concat*n),slsfcomp_concat(9*m+1:m*10,(t_concat-1)*n+1:t_concat*n),alphavalslong(:,(t_concat-1)*n+1:t_concat*n),farelong(:,(t_concat-1)*n+1:t_concat*n),OjOiminslong(:,(t_concat-1)*n+1:t_concat*n),extradrivingtimelong(:,(t_concat-1)*n+1:t_concat*n),drandlong(:,(t_concat-1)*n+1:t_concat*n),'c');
    slsfcomp_concat(numiters*m+1:m*11,(t_concat-1)*n+1:t_concat*n) = newcomp;
    yprobs_concat(numiters*m+1:m*11,(t_concat-1)*n+1:t_concat*n) = yprobs;
end



 %%v_lcf_it_concat = v_lcf_it_concat(m*trials+1:m*trials*(numiters+1),:)







%load info on best-found soln (which includes slsf info)
 load('C:\Users\horneh\Documents\LCF_Paper_experiments\LCF_it_bestperf\lcf_it_bestperfmaxI10P10FS5VS5.mat');
   

%%%%%%%%%%%%%%%%%load slsf as first 'row'

slsfcomp_concat(1:m,:) = slsfcomplong;
yprobs_concat(1:m,:) = yprobslong;
runtimes_slsf_concat(1,:) = runtimes_slsf;

% minitest soln info (slsf is first 'line')
testyhat_mini_concat(1:m*trials,:) = testyhat_mini_slsf;
testscenprobs_mini_concat(1:trials,:) = testscenprobs_mini_slsf;

 
runtimes_mini_concat(1,:) = runtimes_mini_slsf;
testobjave_mini_concat(1,:) = testobjave_mini_slsf;
testrejave_mini_concat(1,:) = testrejave_mini_slsf;
testdupave_mini_concat(1,:) = testdupave_mini_slsf;



%soln info for large perf analysisc(slsf is first 'line')
testyhat_lcf_it_concat(1:m*trials,:) = testyhat_slsf;
testscenprobs_lcf_it_concat(1:trials,:) = testscenprobs_slsf;
testobjs_lcf_it_concat(1:trials,:) = testobjs_slsf;
testobjave_lcf_it_concat(1,:) = testobjave_slsf;
testdupave_lcf_it_concat(1,:) = testdupave_slsf;
testrejave_lcf_it_concat(1,:) = testrejave_slsf;
testv_lcf_it_concat(1:m*trials,:) = testv_slsf;
testz_lcf_it_concat(1:m*trials,:) = testz_slsf;
testw_lcf_it_concat(1:m*trials,:) = testw_slsf;
aveassign_lcf_it_concat(1:m,:) = aveassign_slsf;

avecomp_lcf_it_concat(1,:) = avecomp_slsf;
aveperccomp_lcf_it_concat(1,:) = aveperccomp_slsf ;
avetotprofit_lcf_it_concat(1,:) = avetotprofit_slsf;
percposprofit_lcf_it_concat(1,:) = percposprofit_slsf; 
aveextratime_lcf_it_concat(1,:) = aveextratime_slsf;
vbest_lcf_it_bestperf = -1*ones(m*trials,n*(fixedscens_lcf_it + variscens_lcf_it));

%%% record xbest, ubest, pbest, and ptruebest that weren't recorded
trials = 100;
m = 20;
n = 20;
iterations = 10;
for t = 1:trials
    %record quality metrics for slsf 
%     [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare] = quality_metrics_with_scenprobs(farelong(:,(t-1)*n+1:t*n),slsfcomplong(:,(t-1)*n+1:t*n),extradrivingtimelong(:,(t-1)*n+1:t*n),testscenprobs_slsf(t,:),testv_slsf((t-1)*m+1:t*m,:),testw_slsf((t-1)*m+1:t*m,:));
%     avecomp_slsf(1,t) = avecomp;
%     aveperccomp_slsf(1,t) = aveperccomp;
%     avetotprofit_slsf(1,t) = avetotprofit;
%     percposprofit_slsf(1,t) = percposprofit;
%     aveextratime_slsf(1,t) = aveextratime;
%     averejfare_slsf(1,t) = averejfare;
    
   if guessbestiter_lcf_it_final(1,t) == 0
       ubest_lcf_it_bestperf(:,(t-1)*n+1:t*n) = -1*ones(m,n);
       pbest_lcf_it_bestperf(:,(t-1)*n+1:t*n) = yprobslong(:,(t-1)*n+1:t*n);
       ptruebest_lcf_it_bestperf(:,(t-1)*n+1:t*n) = yprobslong(:,(t-1)*n+1:t*n);
        xbest_lcf_it_bestperf(:,(t-1)*n+1:t*n) = x_lcf_it_concat(1:m,(t-1)*n+1:t*n);
        testv_best_lcf_it_bestperf((t-1)*m+1:t*m,:) = testv_lcf_it_concat((t-1)*m+1:t*m,:);

        
        
        avecomp_best_lcf_it_bestperf(1,t) = avecomp_slsf(1,t);
        aveperccomp_best_lcf_it_bestperf(1,t) = aveperccomp_slsf(1,t);
       avetotprofit_best_lcf_it_bestperf(1,t) = avetotprofit_slsf(1,t);
        percposprofit_best_lcf_it_bestperf(1,t) = percposprofit_slsf(1,t);
        aveextratime_best_lcf_it_bestperf(1,t) = aveextratime_slsf(1,t);
        averejfare_best_lcf_it_bestperf(1,t) = averejfare_slsf(1,t);
        
    else
         temp_iter = guessbestiter_lcf_it_final(1,t);
%        xbest_lcf_it_bestperf(:,(t-1)*n+1:t*n) = x_lcf_it_concat((temp_iter-1)*n+1:temp_iter*n,(t-1)*n+1:t*n);
%        ubest_lcf_it_bestperf(:,(t-1)*n+1:t*n) = u_lcf_it_concat((temp_iter-1)*n+1:temp_iter*n,(t-1)*n+1:t*n);
%        pbest_lcf_it_bestperf(:,(t-1)*n+1:t*n) = p_lcf_it_concat((temp_iter-1)*n+1:temp_iter*n,(t-1)*n+1:t*n);
%        ptruebest_lcf_it_bestperf(:,(t-1)*n+1:t*n) = ptrue_lcf_it_concat((temp_iter-1)*n+1:temp_iter*n,(t-1)*n+1:t*n);
%        testv_lcf_it_concat(temp_iter*m*trials+ (t-1)*m+1:temp_iter*m*trials+t*m,:) = testv_best_lcf_it_bestperf((t-1)*m+1:t*m,:);
%        

 %       vbest_lcf_it_bestperf((t-1)*m+1:t*m,:) = v_lcf_it_concat((temp_iter-1)*m*trials + (t-1)*m+1:(temp_iter-1)*m*trials+t*m,:);
%        [avecomp,aveperccomp,avetotprofit,percposprofit,aveextratime,averejfare] = quality_metrics_with_scenprobs(farelong(:,(t-1)*n+1:t*n),...
%            alphavalslong(:,(t-1)*n+1:t*n)+ubest_lcf_it_bestperf(:,(t-1)*n+1:t*n),extradrivingtimelong(:,(t-1)*n+1:t*n),testscenprobs_best_lcf_it_bestperf(t,:),...
%                 testv_best_lcf_it_bestperf((t-1)*m+1:t*m,:),testw_best_lcf_it_bestperf((t-1)*m+1:t*m,:));
%         avecomp_best_lcf_it_bestperf(1,t)=avecomp;
%         aveperccomp_best_lcf_it_bestperf(1,t)=aveperccomp;
%         avetotprofit_best_lcf_it_bestperf(1,t)=avetotprofit;
%         percposprofit_best_lcf_it_bestperf(1,t)=percposprofit;
%         aveextratime_best_lcf_it_bestperf(1,t)=aveextratime;
%         averejfare_best_lcf_it_bestperf(1,t)=averejfare;
   end
end

% % for i = 1:iterations
% %     for t = 1:trials
% %        if guessbestiter_history(i,t) == i
% %           guessbestiter_changes(i,t) = 1; 
% %        end
% %     end
% % end


%%%%%%%%%%%%%%%% save variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 stem = 'concat_vals.mat';
%   
 filename = [ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Paper_experiments\' stem];
 save(filename, 'Chatlong','Clong', 'Dlong', 'rlong', 'farelong', 'yprobslong',...
    'slsfcomplong', 'alphavalslong', 'betavalslong', 'OjOiminslong', 'extradrivingtimelong', 'drandlong',...
    ...
     'runtimes_scens_lcfinput','runtimes_perf_slsf', 'guessbestiter_history',...
      'guessbestiter_changes', 'slsfcomp_concat', 'x_lcf_it_concat', 'p_lcf_it_concat',...
     'ptrue_lcf_it_concat', 'u_lcf_it_concat','v_lcf_it_concat', 'runtimes_slsf_concat', 'runtimes_lcf_it_concat',...
     ...
     'testyhat_mini_concat', 'testscenprobs_mini_concat', 'runtimes_mini_concat',...
     'testobjave_mini_concat', 'testrejave_mini_concat', 'testdupave_mini_concat',...
     ...
     'testyhat_lcf_it_concat', 'testscenprobs_lcf_it_concat', 'testobjs_lcf_it_concat',...
     'testobjave_lcf_it_concat', 'testdupave_lcf_it_concat', 'testrejave_lcf_it_concat',...
     'testv_lcf_it_concat', 'testz_lcf_it_concat', 'testw_lcf_it_concat', 'aveassign_lcf_it_concat',...
     ...
     'avecomp_lcf_it_concat', 'aveperccomp_lcf_it_concat', 'avetotprofit_lcf_it_concat',...
     'percposprofit_lcf_it_concat', 'aveextratime_lcf_it_concat',...
     ... 
    'xbest_lcf_it_bestperf', 'ubest_lcf_it_bestperf', 'ptruebest_lcf_it_bestperf','pbest_lcf_it_bestperf', 'vbest_lcf_it_bestperf',...
    'testobjs_best_lcf_it_bestperf', 'testobjave_best_lcf_it_bestperf', 'testdupave_best_lcf_it_bestperf', ...
    'testrejave_best_lcf_it_bestperf', 'testyhat_best_lcf_it_bestperf', 'testscenprobs_best_lcf_it_bestperf',... 
    'testv_best_lcf_it_bestperf', 'testz_best_lcf_it_bestperf',... 
    'testw_best_lcf_it_bestperf', 'aveassign_best_lcf_it_bestperf', 'avecomp_best_lcf_it_bestperf',... 
    'aveperccomp_best_lcf_it_bestperf', 'avetotprofit_best_lcf_it_bestperf',...
    'percposprofit_best_lcf_it_bestperf', 'aveextratime_best_lcf_it_bestperf', 'guessbestiter_lcf_it_final',... 
    'times_soln_updated_lcf_it_final', '-v7.3');
