%this code is used to make all graphs, data analysis etc used to gain
%insights about the SOL-FR solutions. For some analysis (comparing multiple settings), the concatenated data file
% 'concat_vals_eq.mat' (made by load_eq_all) is used, otherwise the
% individual bestperf files are used

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%To make the plots/get analysis numbers, simply adjust the values for needload,  
%loadtype, eqtype, threshold, premium, category, and metric as desired and then run the code. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


needload =0; %since loading the data takes time, just set needload =1 when you need to load the data in and set as 0 after that
loadtype = 'c'; %different files need to be loaded base on which analysis you want to do, 'c' is for compare multiple SOL-FR settings,
%'i' is for individual method results, though the only analysis that you can use 'i' with is metric='av' average performance (though metric='av' also
%works with loadtype='c')
eqtype = 'dp'; %specify the fairness type if you're only getting performance average of one setting ('dp' for driver proximity, 'ch' for closer higher, 'eq' for all equal)
threshold = 20; %specify the fairness threshold if you're only getting performance average of one setting
premiumstr = '10'; %specify the premium string if you're only getting performance average of one setting
category = 'c'; %%%  is performance ('p') or compensation ('c')
metric = 'cd' %%%%% for category= performance: 'av' is perf averages, 'wt' is wait time
%%% for comp: 'cd' is comp distribution, 'id' is incentive distrib, 'ei' expected income




m = 20;
n = 20;
theta = 5;
trials = 100;
NumExperiments = 7;
testscens = 5000;

%%% decides the size and location in which the graph is made on the screen, first two digits are the (pixel?) coordinates of
%%% the top left corner, then 3rd and 4th numbers are the (pixel?) width and hieght respectively
%figure('Renderer', 'painters', 'Position', [300 300 400 250])
figure('Renderer', 'painters', 'Position', [300 300 600 400])

%%% rgb of some colors and some linestyles/markerstyles for plots
grey=[0.1 0.1 0.1];
red=[0.6350 0.0780 0.1840];
orange=[0.8500 0.3250 0.0980];
yellow=[0.9290 0.6940 0.1250];
green=[0.4660 0.6740 0.1880];
blue=[0 0.4470 0.7410];
purple=[0.4940 0.1840 0.5560];
symbols=[':d ';'-^ ';':o ';'--+';'-x ';'-.d';'--v'];
colors = [grey; red; orange; yellow; green; blue; purple];


%load the data files if needed
if needload == 1
    if loadtype == 'i'
        stem = sprintf('lcf_eq_bestperfmaxI%dP%sFS%dVS%dEq%sT%d%s.mat',10,premiumstr,5,5,eqtype,threshold,'');
            filename = [ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Eq_experiments\bestperf\' stem];
    else
        stem = 'concat_vals_eq.mat';  
        filename = [ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Eq_experiments\' stem];
    end
     load(filename);
end


%%%%%%%% checking that the comensations follow fairness constraints
% t = 3;
% compinmenu = xbest_lcf_it_bestperf.*(ubest_lcf_it_bestperf+alphavalslong);
% [uconst,rhsconst] = create_uconst(xbest_lcf_it_bestperf(:,(t-1)*n+1:t*n),eqtype,threshold,threshold,threshold,Ojlong(:,t),Djlong(:,t),Oilong(:,t),Dilong(:,t),alphavalslong(:,(t-1)*n+1:t*n),mins,0);
% uconstSparse = zeros(size(uconst,1),3);
% for k =1 : size(uconst,1)
%     uconstSparse(k,1) = mod(find(uconst(k,:) == 1),m);
%     uconstSparse(k,2) = ceil(find(uconst(k,:) == 1)/m);
%     uconstSparse(k,3) = ceil(find(uconst(k,:) == -1)/m);
% end
% 
% compinmenu(:,(t-1)*n+1:t*n)
% uconstSparse;
% nnz(guessbestiter_lcf_it_noperf)


%%%%%%%%%%%%% performance %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if category == 'p'
   if metric == 'av' %performance averages
       if loadtype == 'i' %%% individual results
           
           %print averages in the main metrics 
           mean(testobjave_best_lcf_it_bestperf)
           mean(testrejave_best_lcf_it_bestperf)
           mean(testdupave_best_lcf_it_bestperf)
           mean(avetotprofit_best_lcf_it_bestperf)
           
           %calculate average density of constraints
           DensityNumsAve = zeros(m,1);
           for t = 1:100
               DensityNumsAve = DensityNumsAve + DensityNumsBest(:,t*4); 
           end
           DensityNumsAve = DensityNumsAve/nnz(guessbestiter_lcf_it_noperf);
           mean(DensityNumsAve)
           
           %number of times initial SLSF solution is returned
           nnz(guessbestiter_lcf_it_noperf)
           mean(runtimes_total_lcf_it_noperf)
           %menu size
            menusizes_all = zeros(1,n*trials); %SOL-FR menu sizes including when SLSF is returned
             menusizes_slsf = zeros(1,n*trials); % menu size of initial SLSF solns
            menusizes_noslsf = zeros(1,n*trials); %SOL-FR menu sizes not including when SLSF is returned
            %calculate the values
                for t=1:trials
                     %menusizes_slsf(1,(t-1)*n+1:n*t) = sum(x_lcf_it_concat(1:m,(t-1)*n+1:t*n),1);
                    menusizes_all(1,(t-1)*n+1:n*t) = sum(xbest_lcf_it_bestperf(:,(t-1)*n+1:t*n),1);

                    if guessbestiter_lcf_it_noperf(1,t) == 0
                        menusizes_noslsf(1,(t-1)*n+1:n*t)= -1*ones(1,n);      
                    else
                        menusizes_noslsf(1,(t-1)*n+1:n*t)=sum(xbest_lcf_it_bestperf(:,(t-1)*n+1:t*n),1);

                    end

                end
               % mean(menusizes_slsf)
                mean(menusizes_all)
                mean(menusizes_noslsf(menusizes_noslsf>-1))
                %tabulate(menusizes_slsf)
                tabulate(menusizes_all)
                tabulate(menusizes_noslsf)
                %significance test that lcf menu size > slsf
    %             diffs = menusizes_all-menusizes_slsf;
    %          [h,p] = ttest(diffs,0,'Tail','right')
       else 
           %%% results for all the analyzed methods
           %print averages in the main metrics 
           mean(testobjave_lcf_it_concat,2)
           mean(testrejave_lcf_it_concat,2)
           mean(testdupave_lcf_it_concat,2)
           mean(avetotprofit_lcf_it_concat,2)
           
            %calculate average density of constraints
           DensityNumsAve = zeros(m,NumExperiments);
           for k = 1:NumExperiments
               for t = 1:100
                   DensityNumsAve(:,k) = DensityNumsAve(:,k) + DensityNumsBest_concat((k-1)*m+1:k*m,t*4); 
               end
               DensityNumsAve(:,k) = DensityNumsAve(:,k)/nnz(guessbestiter_concat(k,:));
           end
           mean(DensityNumsAve)
           sum(guessbestiter_concat~=0,2)
           
           %menu size
            menusizes_all = zeros(NumExperiments,n*trials); %SOL-FR menu sizes including when SLSF is returned
             menusizes_slsf = zeros(NumExperiments,n*trials); % menu size of initial SLSF solns
            menusizes_noslsf = zeros(NumExperiments,n*trials); %SOL-FR menu sizes not including when SLSF is returned
            %calculate
            for k = 1: NumExperiments
                for t=1:trials
                     %menusizes_slsf(1,(t-1)*n+1:n*t) = sum(x_lcf_it_concat(1:m,(t-1)*n+1:t*n),1);
                    menusizes_all(k,(t-1)*n+1:n*t) = sum(xbest_lcf_it_concat((k-1)*m+1:k*m,(t-1)*n+1:t*n),1);

                    if guessbestiter_concat(k,t) == 0
                        menusizes_noslsf(k,(t-1)*n+1:n*t)= -1*ones(1,n);      
                    else
                        menusizes_noslsf(k,(t-1)*n+1:n*t)=sum(xbest_lcf_it_concat((k-1)*m+1:k*m,(t-1)*n+1:t*n),1);

                    end

                end
             end
               % mean(menusizes_slsf)
                mean(menusizes_all,2)
                mean(aveextratime_lcf_it_concat,2)'
                mean(aveextratime_withwts_lcf_it_concat,2)'
                mean(avetotprofit_withwts_lcf_it_concat,2)'
                %mean(menusizes_noslsf(menusizes_noslsf>-1))
                %tabulate(menusizes_slsf)
%                 tabulate(menusizes_all)
%                 tabulate(menusizes_noslsf)
                %significance test that lcf menu size > slsf
    %             diffs = menusizes_all-menusizes_slsf;
    %          [h,p] = ttest(diffs,0,'Tail','right')
    plong = zeros(15,1);
    for k = 3:17
        diffs = testrejave_lcf_it_concat(1,:)-testrejave_lcf_it_concat(k,:);
         [h,p] = ttest(diffs,0,'Tail','right')
         plong(k,1) = p;

    end
       plong
       end
       
   elseif metric == 'wt' %wait time calculations
       
       waitave = zeros(NumExperiments,trials);
       for e = 1:NumExperiments
           
           for t = 1:trials
                waitfull = zeros(1,testscens);
               for s = 1:testscens
                   waitfull(1,s) = sum(sum(OjOiminslong(:,(t-1)*n+1:t*n).*testv_lcf_it_concat((e-1)*n*trials + (t-1)*n +1:(e-1)*n*trials + t*n,(s-1)*n+1:s*n)))...
                       /nnz(testv_lcf_it_concat((e-1)*n*trials + (t-1)*n +1:(e-1)*n*trials + t*n,(s-1)*n+1:s*n));
               end
               waitave(e,t) = mean(waitfull);%*testscenprobs_lcf_it_concat((e-1)*trials + t,:)'/sum(testscenprobs_lcf_it_concat((e-1)*trials + t,:));
           end
       end
       mean(waitave,2)
   end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 'c' compensation %%%%%%%%%%%%%
elseif category == 'c'
    if metric == 'cd' %compensation distribution
        
        x=[0.80:0.05:1.60]; %range of compensation/fare
        percmincomp_withslsf = zeros(1,NumExperiments);
        percmincomp_noslsf = zeros(1,NumExperiments);
        meancomp = zeros(NumExperiments,1);
        
        %for each of the main analyzed SOL-FR experiments (e.g.
        %dp(10,0.857)) and for SOL-IT, calculate what portion of the
        %compensation offers divided by the fare (in menu items) are each histogram bin of x and plot it
        for i = 2:NumExperiments 
            temp = compinmenu_noslsf_concat((i-1)*m+1:i*m,:)./farelong;
            bincounts1 = histc(temp(compinmenu_noslsf_concat((i-1)*m+1:i*m,:)>slsfcomplong+0.01),x);
            bincounts2=bincounts1/sum(bincounts1);
            plot(x,bincounts2,symbols(i,:),'color',colors(i,:),'LineWidth',1.5);
            meancomp(i,1) = mean(temp(compinmenu_noslsf_concat((i-1)*m+1:i*m,:)>slsfcomplong+0.01));
            hold on
            percmincomp_withslsf(1,i) = size(compinmenu_all_concat(compinmenu_all_concat((i-1)*m+1:i*m,:)<slsfcomplong+0.01 & compinmenu_all_concat((i-1)*m+1:i*m,:).*xbest_lcf_it_concat((i-1)*m+1:i*m,:)>0),1)/nnz(compinmenu_all_concat((i-1)*m+1:i*m,:).*xbest_lcf_it_concat((i-1)*m+1:i*m,:));
            percmincomp_noslsf(1,i) = size(compinmenu_noslsf_concat(compinmenu_noslsf_concat((i-1)*m+1:i*m,:)<slsfcomplong+0.01 & compinmenu_noslsf_concat((i-1)*m+1:i*m,:).*xbest_lcf_it_concat((i-1)*m+1:i*m,:)>0),1)/nnz(compinmenu_noslsf_concat((i-1)*m+1:i*m,:).*xbest_lcf_it_concat((i-1)*m+1:i*m,:));

        end
        title('Compensation Levels (> Min) of Offered Requests','FontSize', 16)
        xlabel('\slcomp_{ij}/fare_i\rm','FontSize', 16)
        ylabel("Probability",'FontSize', 16)
        lg=legend('SOL-IT','DP-10','DP-20','CH-3','CH-10','EQ','FontSize', 16);
        lg.Location='northeast';
        percmincomp_withslsf'
        percmincomp_noslsf'
        meancomp
        
    elseif metric == 'id' %%% incentive distribution
        
        x=[0:0.5:7]; %range of compensation - minimum compensation
        meanincentive = zeros(NumExperiments,1);
        
         %for each of the main analyzed SOL-FR experiments (e.g.
        %dp(10,0.857)) and for SOL-IT, calculate what portion of the
        %incentive offers (comp- min comp) (in menu items) are each histogram bin of x and plot it
        for i = 2:NumExperiments 
        temp = compinmenu_noslsf_concat((i-1)*m+1:i*m,:)-slsfcomplong;
        bincounts1 = histc(temp(compinmenu_noslsf_concat((i-1)*m+1:i*m,:)>slsfcomplong+0.01),x);
        bincounts2=bincounts1/sum(bincounts1);
        plot(x,bincounts2,symbols(i,:),'color',colors(i,:),'LineWidth',1.5);
        meanincentive(i,1) = mean(temp(compinmenu_noslsf_concat((i-1)*m+1:i*m,:)>slsfcomplong+0.01));
        hold on
        end
        title('Incentives (> 0) of Offered Requests','FontSize', 16)
        xlabel('\slcomp_{ij}-mincomp_i\rm','FontSize', 16)
        ylabel("Probability",'FontSize', 16)
        lg=legend('SOL-IT','DP-10','DP-20','CH-3','CH-10','EQ','FontSize', 16);
        lg.Location='northeast';
        
        meanincentive
    
    elseif metric == 'ei' %%% driver income %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%
        %%%% expected driver income
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %compensation offers in each trial
        compinmenu = ubest_lcf_it_bestperf + alphavalslong; %slsf comp is calculated separately
        exp_income = zeros(NumExperiments,n*trials);
        exp_totalrev = zeros(NumExperiments,trials);
        for i = 1:NumExperiments
        for t=1:trials
            bestiter = guessbestiter_lcf_it_noperf(1,t);
           for j=1:n
              for k=1:5000
                 exp_income(i,(t-1)*n+j) = exp_income(i,(t-1)*n+j)+sum(testscenprobs_lcf_it_concat((i-1)*trials+t,k)*testv_lcf_it_concat((i-1)*trials*m+(t-1)*m+1:(i-1)*trials*m+t*m,(k-1)*n+j).*compinmenu_all_concat((i-1)*m+1:i*m,(t-1)*n+j));

                  if j ==1
                     exp_totalrev(i,t) =  exp_totalrev(i,t) + sum(testscenprobs_lcf_it_concat((i-1)*trials+t,k)*(ones(m,1)-testw_lcf_it_concat((i-1)*trials*m+(t-1)*m+1:(i-1)*trials*m+t*m,k)).*(farelong(:,t*m)+1.85*ones(m,1)));        
                  end
              end
           end
        end
        x = [0:3:30];
        bincounts1 = histc(exp_income(i,:),x);
        bincounts2=bincounts1/sum(bincounts1);
        plot(x,bincounts2,symbols(i,:),'color',colors(i,:),'LineWidth',1.5);
        hold on
        end
     
        xlabel("A Driver's Expected Income ($)")
        ylabel("Count")
        title("Frequency of Drivers' Expected Incomes")
        lg=legend('SLSF','SOL-IT','DP-10','DP-20','CH-3','CH-10','EQ');
        std(exp_income, 0,2)
        mean(exp_income,2)
        %mean(exp_totalrev-avetotprofit_best_lcf_it_bestperf)/20
        %drivers_getting_less = find(exp_income_slsf>exp_income_lcf);
        %size(drivers_getting_less)
        
    end
    
end


