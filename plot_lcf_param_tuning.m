%this code is used to make all graphs, data analysis etc used to decide
%SOL-IT settings (includes tuning premium, number of variable/fixed
%scenarios, number of iterations, and comparison with heuristics/alternative methods)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%To make the plots/get analysis numbers, simply adjust the values for needload, graph, tunparam, and metric
% as desired and then run the code. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


needload=0; %since loading the data takes time, just set needload =1 when you need to load the data in and set as 0 after that
graph = 0; % most of this analysis doesn't make a graph so if you don't want a blank graph to be auto-generated set graph=0 (else graph=1)
tunparam='st'; %tunparam options are 0 (lcf-dir), 'tr' (checking variance between 2 sets of 100 trials),
%'vs' (number of variable scens lcf-fm), 'pr' (premium), 'ms' (number of scenarios for lcf-fms), 'ss' (scenario scale (testing out ballpark
%fixed/vari scen sizes and ratios)), 'sr' (scenario ratio fine tuning,
%includes statistical significance tests), 'st' (statistics of using different numbers of iterations and using the heuristic/alternative methods,
%i.e. doing statistical significance tests). NOTE: '0', 'tr', 'vs', 'pr', 'ms', and 'ss' were used for exploration and to make initial decisions
%about what settings to test,  'sr' and 'st' are what's used in the paper
%(for the premium analysis table in the paper I think I just opened the
%data file and pasted what I need into excel then took averages)

%SMALL GUIDE: because it analyzes the data from many different files, the tunparam='st'
%analysis loads the param_tuning_vals.mat matlab data file (made by
%load_param_tuning.m). The variables for 'st' have a suffix in their name
%to let you know which data it corresponds to: _10 for our 'gold standard'
%(SOL-IT_10(5,5), _1257 for testing SOL-IT(5,5) with fewer than 10
%iterations (i.e. with 1, 2, 5, and 7 iterations), _13 for SOL-IT_13(5,5),
%and _mthds for the alternate methods: CLOS-1, LIK-1, CLOS-5, LIK-5,
%LCF-DIR, LCF-FM, and LCF-FMS. For _1257 and _mthds, each row of the
%outputted analysis variables is a different method (listed in order). For
%the statistical significance test in both tunparam='sr' and 'st' (for the specified metric), there will be 
%p-values (vari name pvals + suffix) of the statistical significance test
%that mean what they do in the paper: the pval is the probability that the
%metric value of the given experiment is the same as the point of
%comparison (usually the experiment with the best metric value and/or
%SOL-IT_10(5,5). So if the p-value is below 0.05, we conclude that it's
%more statistically likely that the given experiment has a worse metric
%value than the point of comparison. Be sure to check the code to
%see/adjust which experiment is being used as the point of comparision, as
%a couple different ones were used

metric='ob'; %metric options are 'ob'=obj, 'pr'=profit, 'ma'=number of matches, 'me'=menu size, 'un'=unhappy, 'ru'=runtime





plotnotes=''; %only used under tunparam = 'sr', is added to the end of the lcf_it_bestperf file name to be loaded (there's a file with
%5 variable and 5 fixed scens and 10 iterations that has 'sec' as the notes--this is the notes that this code checks for. I believe I did SOL-IT
%using the second set of 100 problem instances (hence 'sec') in order to have 200 problem instances to look at. This analysis was not used in the
%paper



numtrials=100;
m=20;
n=20;


 
%%% rgb of some colors and some linestyles/markerstyles for plots
red=[0.6350 0.0780 0.1840];
orange=[0.8500 0.3250 0.0980];
yellow=[0.9290 0.6940 0.1250];
green=[0.4660 0.6740 0.1880];
blue=[0 0.4470 0.7410];
purple=[0.4940 0.1840 0.5560];
black = [0 0 0];
brown = [0.5 0.3 0.05];
colors=[red;orange;yellow;green;blue;purple; black;brown];
symbols=['-^ ';':o ';'--+';'-x ';'-.d';'--v']; 
symbols_nomark=['- ';': ';'--';': ';'-.';'--';'- ';': '];


%%%% for the 'lcf-dir bad' graphs
if tunparam==0
    if needload==1
        load('C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Paper_experiments\LCF_base_model\lcf_base_modelP75S20.mat');
    end
    if graph == 1
        %%% decides the size and location in which the graph is made on the screen, first two digits are the (pixel?) coordinates of
        %%% the top left corner, then 3rd and 4th numbers are the (pixel?) width and hieght respectively
        figure('Renderer', 'painters', 'Position', [300 300 400 330])
    end
    if metric=='ob'
        %plot cdf of lcf-dir obj vs slsf
        p1=cdfplot(testobjave_lcf_base)
        p1.Color=red;
        p1.LineWidth=2
        hold on
        p2=cdfplot(testobjave_slsf)
        p2.Color=blue;
        p2.LineStyle=':'
        p2.LineWidth=2
        hold on
        
        lg=legend('SOL-DIR','SLSF')
        lg.Location='northwest'
        xlabel('Objective Estimate')
        ylabel('Cumulative Probability')
        title('CDF of Objective Estimates')
        
        avepercbetter=mean(mean((testobjave_lcf_base./testobjave_slsf)-ones(1,trials)))
       
    elseif metric=='pr'
         %plot cdf of lcf-dir profit vs slsf
        p1=cdfplot(avetotprofit_lcf_base)
        p1.Color=red;
        p1.LineWidth=2
        hold on
        p2=cdfplot(avetotprofit_slsf)
        p2.Color=blue;
        p2.LineStyle=':'
        p2.LineWidth=2
        hold on
        
        lg=legend('SOL-DIR','SLSF')
        lg.Location='northwest'
        xlabel('Expected Profit')
        ylabel('Cumulative Probability')
        title('CDF of Profit')
    elseif metric=='ma'
         %plot cdf of lcf-dir matches vs slsf
    
        p1=cdfplot(20*ones(1,trials)-testrejave_lcf_base)
        p1.Color=red;
        p1.LineWidth=2
        hold on
        p2=cdfplot(20*ones(1,trials)-testrejave_slsf)
        p2.Color=blue;
        p2.LineStyle=':'
        p2.LineWidth=2
        hold on
        
        lg=legend('SOL-DIR','SLSF')
        lg.Location='northwest'
        xlabel('Expected Matches')
        ylabel('Cumulative Probability')
        title('CDF of Matches')
        
          mean(testrejave_lcf_base)
         mean(testrejave_slsf)
         mean(testrejave_lcf_base./testrejave_slsf)
        avepercrejbetter=mean(ones(1,trials)-(testrejave_lcf_base./testrejave_slsf))
         
    elseif metric=='me'
        %%% menu size info for lcf-dir
        menusizes_slsf=zeros(1,n*trials);
        menusizes_lcf_base=zeros(1,n*trials);

        for t=1:trials   
            menusizes_slsf(1,(t-1)*n+1:n*t)=sum(x_slsf(:,(t-1)*n+1:t*n),1);
                menusizes_lcf_base(1,(t-1)*n+1:n*t)=sum(x_lcf_base(:,(t-1)*n+1:t*n),1);
          
        end

         p1=cdfplot(menusizes_lcf_base)
        p1.Color=red;
        p1.LineWidth=2
        hold on
        p2=cdfplot(menusizes_slsf)
        p2.Color=blue;
        p2.LineStyle=':'
        p2.LineWidth=2
        hold on
        
        lg=legend('SOL-DIR','SLSF')
        lg.Location='northwest'
        xlabel('Menu Size')
        ylabel('Cumulative Probability')
        title('CDF of Menu Size')
        
        tabulate(menusizes_lcf_base)
        mean(menusizes_slsf)
        mean(menusizes_lcf_base)
        
        mean(runtimes_testscens_lcf_base)
    end
    
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% for checking if 100 trials is enough
    %%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif tunparam=='tr'
    if needload==1
            stem= 'lcf_fmsP75FS10VS10.mat';
            filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Paper_experiments\LCF_fms\' stem];
            load(filename)
    end
    
    if graph == 1
    figure('Renderer', 'painters', 'Position', [300 300 350 350])
    end 
    
    if metric=='ob'
        %plot cdf of lcf-fms and slsf obj for first and second half of trials
        for i_plots=1:2
        p2=cdfplot(testobjave_lcf_fms(:,(i_plots-1)*100+1:i_plots*100))
        p2.Color=colors(2*i_plots-1,:);
        p2.LineStyle=symbols_nomark(2*i_plots-1,:);
        p2.LineWidth=1.5
        hold on
        p2=cdfplot(testobjave_slsf(:,(i_plots-1)*100+1:i_plots*100))
        p2.Color=colors(2*i_plots,:);
        p2.LineStyle=symbols_nomark(2*i_plots,:);
        p2.LineWidth=1.5
        hold on
        end
        lg=legend('first LCF', 'first SLSF', 'sec LCF', 'sec SLSF')
        lg.Location='northwest'
        xlabel('Objective Estimate')
        ylabel('Cumulative Probability')
        title('CDF of Objective Estimates')
             
      avepercbetter1=mean(mean(testobjave_lcf_fms(1,1:100)./testobjave_slsf(1,1:100)-ones(1,100)))
      avepercbetter2=mean(mean(testobjave_lcf_fms(1,101:200)./testobjave_slsf(1,101:200)-ones(1,100)))
      objave_slsf1=mean(testobjave_slsf(1,1:100))
      objave_slsf2=mean(testobjave_slsf(1,101:200))
      objave_lcf1=mean(testobjave_lcf_fms(1,1:100))
      objave_lcf2=mean(testobjave_lcf_fms(1,101:200))
      
    elseif metric=='pr'
        %plot cdf of lcf-fms and slsf profit for first and second half of trials
        for i_plots=1:2
        p2=cdfplot(avetotprofit_lcf_fms(:,(i_plots-1)*100+1:i_plots*100))
        p2.Color=colors(2*i_plots-1,:);
        p2.LineStyle=symbols_nomark(2*i_plots-1,:);
        p2.LineWidth=1.5
        hold on
        p2=cdfplot(avetotprofit_slsf(:,(i_plots-1)*100+1:i_plots*100))
        p2.Color=colors(2*i_plots,:);
        p2.LineStyle=symbols_nomark(2*i_plots,:);
        p2.LineWidth=1.5
        hold on
        end
        lg=legend('first LCF', 'first SLSF', 'sec LCF', 'sec SLSF')
        lg.Location='northwest'
        xlabel('Profit Estimate')
        ylabel('Cumulative Probability')
        title('CDF of Expected Profit')
             
      avepercbetter1=mean(mean(avetotprofit_lcf_fms(1,1:100)./avetotprofit_slsf(1,1:100)-ones(1,100)))
      avepercbetter2=mean(mean(avetotprofit_lcf_fms(1,101:200)./avetotprofit_slsf(1,101:200)-ones(1,100)))
      profave_slsf1=mean(avetotprofit_slsf(1,1:100))
      profave_slsf2=mean(avetotprofit_slsf(1,101:200))
      profave_lcf1=mean(avetotprofit_lcf_fms(1,1:100))
      profave_lcf2=mean(avetotprofit_lcf_fms(1,101:200))
      
      
    elseif metric=='ma'
          %plot cdf of lcf-fms and slsf matches for first and second half of trials
        for i_plots=1:2
        p2=cdfplot(20*ones(1,100)-testrejave_lcf_fms(:,(i_plots-1)*100+1:i_plots*100))
        p2.Color=colors(2*i_plots-1,:);
        p2.LineStyle=symbols_nomark(2*i_plots-1,:);
        p2.LineWidth=1.5
        hold on
        p2=cdfplot(20*ones(1,100)-testrejave_slsf(:,(i_plots-1)*100+1:i_plots*100))
        p2.Color=colors(2*i_plots,:);
        p2.LineStyle=symbols_nomark(2*i_plots,:);
        p2.LineWidth=1.5
        hold on
        end
        lg=legend('first LCF', 'first SLSF', 'sec LCF', 'sec SLSF')
        lg.Location='northwest'
        xlabel('Expected Matches')
        ylabel('Cumulative Probability')
        title('CDF of Expected Matches')
          
      avepercbetter1=mean(mean(ones(1,100)-testrejave_lcf_fms(1,1:100)./testrejave_slsf(1,1:100)))
      avepercbetter2=mean(mean(ones(1,100)-testrejave_lcf_fms(1,101:200)./testrejave_slsf(1,101:200)))
      rejave_slsf1=mean(testrejave_slsf(1,1:100))
      rejave_slsf2=mean(testrejave_slsf(1,101:200))
      rejave_lcf1=mean(testrejave_lcf_fms(1,1:100))
      rejave_lcf2=mean(testrejave_lcf_fms(1,101:200))
      
        
    elseif metric=='ru'      
        %plot cdf of lcf-fms and slsf runtime for first and second half of trials
        for i_plots=1:2
        p2=cdfplot(runtimes_lcf_fms(:,(i_plots-1)*100+1:i_plots*100))
        p2.Color=colors(2*i_plots-1,:);
        p2.LineStyle=symbols_nomark(2*i_plots-1,:);
        p2.LineWidth=1.5
        hold on
        p2=cdfplot(runtimes_slsf(:,(i_plots-1)*100+1:i_plots*100))
        p2.Color=colors(2*i_plots,:);
        p2.LineStyle=symbols_nomark(2*i_plots,:);
        p2.LineWidth=1.5
        hold on
        end
        lg=legend('first LCF', 'first SLSF', 'sec LCF', 'sec SLSF')
        lg.Location='southeast'
        xlabel('Ave. Runtime')
        ylabel('Cumulative Probability')
        title('CDF of Runtime')
             
      timeave_slsf1=mean(runtimes_slsf(1,1:100))
      timeave_slsf2=mean(runtimes_slsf(1,101:200))
      timeave_lcf1=mean(runtimes_lcf_fms(1,1:100))
      timeave_lcf2=mean(runtimes_lcf_fms(1,101:200))
        
    end
    
    
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% for the variable scenario tuning graphs
    %%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif tunparam=='vs'
    if needload==1
        numsizes=5;
        starttrial=1;
        testobjave_lcf_fm_vs=zeros(numsizes,trials);
        testrejave_lcf_fm_vs=zeros(numsizes,trials);
        testdupave_lcf_fm_vs=zeros(numsizes,trials);
        avetotprofit_lcf_fm_vs=zeros(numsizes,trials);
        runtimes_lcf_fm_vs=zeros(numsizes,trials);
        variscen_sizes=[5,10,20,50,100];
        for i_plots=1:numsizes
            stem= sprintf('lcf_fmP75S%d.mat',variscen_sizes(1,i_plots));
            filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Paper_experiments\LCF_fm\' stem];
            load(filename)
            testobjave_lcf_fm_vs(i_plots,:)=testobjave_lcf_fm;
            testrejave_lcf_fm_vs(i_plots,:)=testrejave_lcf_fm;
             testdupave_lcf_fm_vs(i_plots,:)=testdupave_lcf_fm;
            avetotprofit_lcf_fm_vs(i_plots,:)=avetotprofit_lcf_fm;
            runtimes_lcf_fm_vs(i_plots,:)=runtimes_lcf_fm;
        end
    end
    
    if graph == 1
    figure('Renderer', 'painters', 'Position', [300 300 350 350])
    end
    
    if metric=='ob'
        %plot cdf of obj for lcf-fm for diff vscens
        if graph == 1
            for i_plots=1:numsizes
            p2=cdfplot(testobjave_lcf_fm_vs(i_plots,:))
            p2.Color=colors(i_plots,:);
            p2.LineStyle=symbols_nomark(i_plots,:);
            p2.LineWidth=1.5
            hold on
            end
           lg=legend('5 v. scens','10 v. scens','20 v. scens','50 v. scens','100 v. scens')
           lg.Location='northwest'
            xlabel('Objective Estimate')
            ylabel('Cumulative Probability')
            title('CDF of Objective Estimates')
        end
         deviation = std(testobjave_lcf_fm_vs')'
       
        confidence = quantile(testobjave_lcf_fm_vs',[0.025,0.975])'
        
        aveslsf = mean(testobjave_slsf(1,starttrial:trials))
        average = mean(testobjave_lcf_fm_vs')'
        avepercbetter=-ones(numsizes,1)+average./repmat(aveslsf,numsizes,1)
        %avepercbetter = mean((testobjave_lcf_fm_vs./repmat(testobjave_slsf(1,starttrial:trials),numsizes,1)-ones(numsizes,numtrials))')'
        higherobj = testobjave_lcf_fm_vs > repmat(testobjave_slsf(1,starttrial:trials),numsizes,1);
        lowerobj = testobjave_lcf_fm_vs < repmat(testobjave_slsf(1,starttrial:trials),numsizes,1);
        percbetter = mean(higherobj')'
        percworse = mean(lowerobj')'
        
        %avepercbetter=mean(mean((testobjave_lcf_base./testobjave_slsf)-ones(1,trials)))
    elseif metric=='pr'
         %plot cdf of profit lcf-fm for diff vscens
        if graph == 1
            for i_plots=1:numsizes
            p2=cdfplot(avetotprofit_lcf_fm_vs(i_plots,:))
            p2.Color=colors(i_plots,:);
            p2.LineStyle=symbols_nomark(i_plots,:);
            p2.LineWidth=1.5
            hold on
            end
            lg=legend('5 v. scens','10 v. scens','20 v. scens','50 v. scens','100 v. scens')
            lg.Location='northwest'
            xlabel('Expected Profit')
            ylabel('Cumulative Probability')
            title('CDF of Profit')
        end
        
        deviation = std(avetotprofit_lcf_fm_vs')'
       
        confidence = quantile(avetotprofit_lcf_fm_vs',[0.025,0.975])'
        
        aveslsf = mean(avetotprofit_slsf(1,starttrial:trials))
        average = mean(avetotprofit_lcf_fm_vs')'
        avepercbetter=-ones(numsizes,1)+average./repmat(aveslsf,numsizes,1)
        %avepercbetter=mean((avetotprofit_lcf_fm_vs./repmat(avetotprofit_slsf(1,starttrial:trials),numsizes,1)-ones(numsizes,numtrials))')'
        higherprof = avetotprofit_lcf_fm_vs > repmat(avetotprofit_slsf(1,starttrial:trials),numsizes,1);
        lowerprof = avetotprofit_lcf_fm_vs < repmat(avetotprofit_slsf(1,starttrial:trials),numsizes,1);
        percbetter = mean(higherprof')'
        percworse = mean(lowerprof')'
        
    elseif metric=='ma'
         %plot cdf of matches lcf-fm for diff vscens
        if graph == 1 
            for i_plots=1:numsizes
            p2=cdfplot(20*ones(1,numtrials)-testrejave_lcf_fm_vs(i_plots,:))
            p2.Color=colors(i_plots,:);
            p2.LineStyle=symbols_nomark(i_plots,:);
            p2.LineWidth=1.5
            hold on
            end
            lg=legend('5 v. scens','10 v. scens','20 v. scens','50 v. scens','100 v. scens')
            lg.Location='northwest'
            xlabel('Expected Matches')
            ylabel('Cumulative Probability')
            title('CDF of Matches')
        end
      
         deviation = std(testrejave_lcf_fm_vs')'
       
        confidence = quantile(testrejave_lcf_fm_vs',[0.025,0.975])'
        
        aveslsf = mean(testrejave_slsf(1,starttrial:trials))
        average = mean(testrejave_lcf_fm_vs')'
        avepercbetter=ones(numsizes,1)-average./repmat(aveslsf,numsizes,1)
        %=mean((ones(numsizes,numtrials)-testrejave_lcf_fm_vs./repmat(testrejave_slsf(1,starttrial:trials),numsizes,1))')'
        higherunmat = testrejave_lcf_fm_vs > repmat(testrejave_slsf(1,starttrial:trials),numsizes,1);
        lowerunmat = testrejave_lcf_fm_vs < repmat(testrejave_slsf(1,starttrial:trials),numsizes,1);
        percbetter = mean(lowerunmat')'
        percworse = mean(higherunmat')'
        
     elseif metric=='un'
         %plot cdf of unhappy drivers lcf-fm for diff vscens
       if graph == 1
            for i_plots=1:numsizes
            p2=cdfplot(testdupave_lcf_fm_vs(i_plots,:))
            p2.Color=colors(i_plots,:);
            p2.LineStyle=symbols_nomark(i_plots,:);
            p2.LineWidth=1.5
            hold on
            end
            lg=legend('5 v. scens','10 v. scens','20 v. scens','50 v. scens','100 v. scens')
            lg.Location='southeast'
            xlabel('Expected Unhappy Driver Requests')
            ylabel('Cumulative Probability')
            title('CDF of Unhappy Driver Requests')
       end
        
        deviation = std(testdupave_lcf_fm_vs')'
       
        confidence = quantile(testdupave_lcf_fm_vs',[0.025,0.975])'
        
        aveslsf = mean(testdupave_slsf(1,starttrial:trials))
        average = mean(testdupave_lcf_fm_vs')'
        avepercbetter=ones(numsizes,1)-average./repmat(aveslsf,numsizes,1)
        %avepercbetter=mean((ones(numsizes,numtrials)-testdupave_lcf_fm_vs./repmat(testdupave_slsf(1,starttrial:trials),numsizes,1))')'
        higherunhap = testdupave_lcf_fm_vs > repmat(testdupave_slsf(1,starttrial:trials),numsizes,1);
        lowerunhap = testdupave_lcf_fm_vs < repmat(testdupave_slsf(1,starttrial:trials),numsizes,1);
        percbetter = mean(lowerunhap')'
        percworse = mean(higherunhap')'
        
    elseif metric=='ru'
        %%% runtime info for lcf-fm for diff vscens
        if graph == 1
            for i_plots=1:numsizes
            p2=cdfplot(runtimes_lcf_fm_vs(i_plots,:))
            p2.Color=colors(i_plots,:);
            p2.LineStyle=symbols_nomark(i_plots,:);
            p2.LineWidth=1.5
            hold on
            end
            lg=legend('5 v. scens','10 v. scens','20 v. scens','50 v. scens','100 v. scens')
            lg.Location='southeast'
            xlabel('Runtime')
            ylabel('Cumulative Probability')
            title('CDF of Runtime')
        end
        deviation = std(runtimes_lcf_fm_vs')'
       
        confidence = quantile(runtimes_lcf_fm_vs',[0.025,0.975])'
        
        aveslsf = mean(runtimes_slsf(1,starttrial:trials))
        average = mean(runtimes_lcf_fm_vs')'
        ratio = average/aveslsf
        
    end
   
    
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% looking at lcf-fms
    %%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif tunparam=='ms'
    if needload==1
        numsizes = 1;
        starttrial = 1;
        testobjave_lcf_fms_ms=zeros(numsizes,trials);
        testrejave_lcf_fms_ms=zeros(numsizes,trials);
        testdupave_lcf_fms_ms=zeros(numsizes,trials);
        avetotprofit_lcf_fms_ms=zeros(numsizes,trials);
        runtimes_lcf_fms_ms=zeros(numsizes,trials);
        variscen_sizes_lcf_fms_ms=[10,10,50,50];
        fixedscen_sizes_lcf_fms_ms=[10,50,10,50];
        for i_plots=1:numsizes
            stem= sprintf('lcf_fmsP10FS%dVS%d.mat',fixedscen_sizes_lcf_fms_ms(1,i_plots),variscen_sizes_lcf_fms_ms(1,i_plots));
            filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Paper_experiments\LCF_fms\' stem];
            load(filename)
            testobjave_lcf_fms_ms(i_plots,:)=testobjave_lcf_fms;
            testrejave_lcf_fms_ms(i_plots,:)=testrejave_lcf_fms;
            testdupave_lcf_fms_ms(i_plots,:)=testdupave_lcf_fms;
            avetotprofit_lcf_fms_ms(i_plots,:)=avetotprofit_lcf_fms;
            runtimes_lcf_fms_ms(i_plots,:)=runtimes_lcf_fms;
        end
    end
    
    if graph == 1
    figure('Renderer', 'painters', 'Position', [300 300 350 350])
    end
    
    if metric=='ob'
        %plot cdf of obj for lcf-it for diff  scen scales
        if graph == 1
            for i_plots=1:numsizes
            p2=cdfplot(testobjave_lcf_fms_ms(i_plots,:))
            p2.Color=colors(i_plots,:);
            p2.LineStyle=symbols_nomark(i_plots,:);
            p2.LineWidth=1.5
            hold on
            end
            lg=legend('10 var, 10 fix','10 var, 50 fix','50 var, 10 fix','50 var, 50 fix') 
            lg.Location='northwest'
            xlabel('Objective Estimate')
            ylabel('Cumulative Probability')
            title('CDF of Objective Estimates')
        end
         deviation = std(testobjave_lcf_fms_ms')'
       
        confidence = quantile(testobjave_lcf_fms_ms',[0.025,0.975])'
        
        aveslsf = mean(testobjave_slsf(1,starttrial:trials))
        average = mean(testobjave_lcf_fms_ms')'
        avepercbetter=-ones(numsizes,1)+average./repmat(aveslsf,numsizes,1)
        %avepercbetter = mean((testobjave_lcf_fms_ms./repmat(testobjave_slsf(1,starttrial:trials),numsizes,1)-ones(numsizes,numtrials))')'
        higherobj = testobjave_lcf_fms_ms > repmat(testobjave_slsf(1,starttrial:trials),numsizes,1);
        lowerobj = testobjave_lcf_fms_ms < repmat(testobjave_slsf(1,starttrial:trials),numsizes,1);
        percbetter = mean(higherobj')'
        percworse = mean(lowerobj')'
        
        %avepercbetter=mean(mean((testobjave_lcf_base./testobjave_slsf)-ones(1,trials)))
    elseif metric=='pr'
         %plot cdf of profit lcf-it for diff  scen scales
        if graph == 1
            for i_plots=1:numsizes
            p2=cdfplot(avetotprofit_lcf_fms_ms(i_plots,:))
            p2.Color=colors(i_plots,:);
            p2.LineStyle=symbols_nomark(i_plots,:);
            p2.LineWidth=1.5
            hold on
            end
            lg=legend('10 var, 10 fix','10 var, 50 fix','50 var, 10 fix','50 var, 50 fix')
            lg.Location='northwest'
            xlabel('Expected Profit')
            ylabel('Cumulative Probability')
            title('CDF of Profit')
        end
        
        deviation = std(avetotprofit_lcf_fms_ms')'
       
        confidence = quantile(avetotprofit_lcf_fms_ms',[0.025,0.975])'
        
        aveslsf = mean(avetotprofit_slsf(1,starttrial:trials))
        average = mean(avetotprofit_lcf_fms_ms')'
        avepercbetter=-ones(numsizes,1)+average./repmat(aveslsf,numsizes,1)
        %avepercbetter=mean((avetotprofit_lcf_fms_ms./repmat(avetotprofit_slsf(1,starttrial:trials),numsizes,1)-ones(numsizes,numtrials))')'
        higherprof = avetotprofit_lcf_fms_ms > repmat(avetotprofit_slsf(1,starttrial:trials),numsizes,1);
        lowerprof = avetotprofit_lcf_fms_ms < repmat(avetotprofit_slsf(1,starttrial:trials),numsizes,1);
        percbetter = mean(higherprof')'
        percworse = mean(lowerprof')'
        
    elseif metric=='ma'
         %plot cdf of matches lcf-it for diff  scen scales
        if graph == 1 
            for i_plots=1:numsizes
            p2=cdfplot(20*ones(1,numtrials)-testrejave_lcf_fms_ms(i_plots,:))
            p2.Color=colors(i_plots,:);
            p2.LineStyle=symbols_nomark(i_plots,:);
            p2.LineWidth=1.5
            hold on
            end
            lg=legend('10 var, 10 fix','10 var, 50 fix','50 var, 10 fix','50 var, 50 fix')
            lg.Location='northwest'
            xlabel('Expected Matches')
            ylabel('Cumulative Probability')
            title('CDF of Matches')
        end
      
         deviation = std(testrejave_lcf_fms_ms')'
       
        confidence = quantile(testrejave_lcf_fms_ms',[0.025,0.975])'
        
        aveslsf = mean(testrejave_slsf(1,starttrial:trials))
        average = mean(testrejave_lcf_fms_ms')'
        avepercbetter=ones(numsizes,1)-average./repmat(aveslsf,numsizes,1)
        %=mean((ones(numsizes,numtrials)-testrejave_lcf_fms_ms./repmat(testrejave_slsf(1,starttrial:trials),numsizes,1))')'
        higherunmat = testrejave_lcf_fms_ms > repmat(testrejave_slsf(1,starttrial:trials),numsizes,1);
        lowerunmat = testrejave_lcf_fms_ms < repmat(testrejave_slsf(1,starttrial:trials),numsizes,1);
        percbetter = mean(lowerunmat')'
        percworse = mean(higherunmat')'
        
     elseif metric=='un'
         %plot cdf of unhappy drivers lcf-it for diff  scen scales
       if graph == 1
            for i_plots=1:numsizes
            p2=cdfplot(testdupave_lcf_fms_ms(i_plots,:))
            p2.Color=colors(i_plots,:);
            p2.LineStyle=symbols_nomark(i_plots,:);
            p2.LineWidth=1.5
            hold on
            end
            lg=legend('10 var, 10 fix','10 var, 50 fix','50 var, 10 fix','50 var, 50 fix')
            lg.Location='southeast'
            xlabel('Expected Unhappy Driver Requests')
            ylabel('Cumulative Probability')
            title('CDF of Unhappy Driver Requests')
       end
        
        deviation = std(testdupave_lcf_fms_ms')'
       
        confidence = quantile(testdupave_lcf_fms_ms',[0.025,0.975])'
        
        aveslsf = mean(testdupave_slsf(1,starttrial:trials))
        average = mean(testdupave_lcf_fms_ms')'
        avepercbetter=ones(numsizes,1)-average./repmat(aveslsf,numsizes,1)
        %avepercbetter=mean((ones(numsizes,numtrials)-testdupave_lcf_fms_ms./repmat(testdupave_slsf(1,starttrial:trials),numsizes,1))')'
        higherunhap = testdupave_lcf_fms_ms > repmat(testdupave_slsf(1,starttrial:trials),numsizes,1);
        lowerunhap = testdupave_lcf_fms_ms < repmat(testdupave_slsf(1,starttrial:trials),numsizes,1);
        percbetter = mean(lowerunhap')'
        percworse = mean(higherunhap')'
        
    elseif metric=='ru'
        %%% runtime info for lcf-it for diff  scen scales
        if graph == 1
            for i_plots=1:numsizes
            p2=cdfplot(runtimes_lcf_fms_ms(i_plots,:))
            p2.Color=colors(i_plots,:);
            p2.LineStyle=symbols_nomark(i_plots,:);
            p2.LineWidth=1.5
            hold on
            end
            lg=legend('10 var, 10 fix','10 var, 50 fix','50 var, 10 fix','50 var, 50 fix')
            lg.Location='southeast'
            xlabel('Runtime')
            ylabel('Cumulative Probability')
            title('CDF of Runtime')
        end
        deviation = std(runtimes_lcf_fms_ms')'
       
        confidence = quantile(runtimes_lcf_fms_ms',[0.025,0.975])'
        
        aveslsf = mean(runtimes_slsf(1,starttrial:trials))
        average = mean(runtimes_lcf_fms_ms')'
        ratio = average/aveslsf
        
    end
    
    
    
    
    
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% for the scale of scenario size tuning
    %%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif tunparam=='ss'
    if needload==1
        numsizes = 4;
        starttrial = 1;
        testobjave_lcf_it_ss=zeros(4,trials);
        testrejave_lcf_it_ss=zeros(4,trials);
        testdupave_lcf_it_ss=zeros(4,trials);
        avetotprofit_lcf_it_ss=zeros(4,trials);
        runtimes_lcf_it_ss=zeros(4,trials);
        variscen_sizes_lcf_it_ss=[10,10,50,50];
        fixedscen_sizes_lcf_it_ss=[10,50,10,50];
        for i_plots=1:numsizes
            stem= sprintf('lcf_it_bestperfmaxI10P75FS%dVS%d.mat',fixedscen_sizes_lcf_it_ss(1,i_plots),variscen_sizes_lcf_it_ss(1,i_plots));
            filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Paper_experiments\LCF_it_bestperf\' stem];
            load(filename)
            testobjave_lcf_it_ss(i_plots,:)=testobjave_best_lcf_it_bestperf;
            testrejave_lcf_it_ss(i_plots,:)=testrejave_best_lcf_it_bestperf;
            testdupave_lcf_it_ss(i_plots,:)=testdupave_best_lcf_it_bestperf;
            avetotprofit_lcf_it_ss(i_plots,:)=avetotprofit_best_lcf_it_bestperf;
            runtimes_lcf_it_ss(i_plots,:)=runtimes_total_lcf_it_noperf;
        end
    end
    
    if graph == 1
    figure('Renderer', 'painters', 'Position', [300 300 350 350])
    end
    
    if metric=='ob'
        %plot cdf of obj for lcf-it for diff  scen scales
        if graph == 1
            for i_plots=1:numsizes
            p2=cdfplot(testobjave_lcf_it_ss(i_plots,:))
            p2.Color=colors(i_plots,:);
            p2.LineStyle=symbols_nomark(i_plots,:);
            p2.LineWidth=1.5
            hold on
            end
            lg=legend('10 var, 10 fix','10 var, 50 fix','50 var, 10 fix','50 var, 50 fix') 
            lg.Location='northwest'
            xlabel('Objective Estimate')
            ylabel('Cumulative Probability')
            title('CDF of Objective Estimates')
        end
         deviation = std(testobjave_lcf_it_ss')'
       
        confidence = quantile(testobjave_lcf_it_ss',[0.025,0.975])'
        
        aveslsf = mean(testobjave_slsf(1,starttrial:trials))
        average = mean(testobjave_lcf_it_ss')'
        avepercbetter=-ones(numsizes,1)+average./repmat(aveslsf,numsizes,1)
        %avepercbetter = mean((testobjave_lcf_it_ss./repmat(testobjave_slsf(1,starttrial:trials),numsizes,1)-ones(numsizes,numtrials))')'
        higherobj = testobjave_lcf_it_ss > repmat(testobjave_slsf(1,starttrial:trials),numsizes,1);
        lowerobj = testobjave_lcf_it_ss < repmat(testobjave_slsf(1,starttrial:trials),numsizes,1);
        percbetter = mean(higherobj')'
        percworse = mean(lowerobj')'
        
        %avepercbetter=mean(mean((testobjave_lcf_base./testobjave_slsf)-ones(1,trials)))
    elseif metric=='pr'
         %plot cdf of profit lcf-it for diff  scen scales
        if graph == 1
            for i_plots=1:numsizes
            p2=cdfplot(avetotprofit_lcf_it_ss(i_plots,:))
            p2.Color=colors(i_plots,:);
            p2.LineStyle=symbols_nomark(i_plots,:);
            p2.LineWidth=1.5
            hold on
            end
            lg=legend('10 var, 10 fix','10 var, 50 fix','50 var, 10 fix','50 var, 50 fix')
            lg.Location='northwest'
            xlabel('Expected Profit')
            ylabel('Cumulative Probability')
            title('CDF of Profit')
        end
        
        deviation = std(avetotprofit_lcf_it_ss')'
       
        confidence = quantile(avetotprofit_lcf_it_ss',[0.025,0.975])'
        
        aveslsf = mean(avetotprofit_slsf(1,starttrial:trials))
        average = mean(avetotprofit_lcf_it_ss')'
        avepercbetter=-ones(numsizes,1)+average./repmat(aveslsf,numsizes,1)
        %avepercbetter=mean((avetotprofit_lcf_it_ss./repmat(avetotprofit_slsf(1,starttrial:trials),numsizes,1)-ones(numsizes,numtrials))')'
        higherprof = avetotprofit_lcf_it_ss > repmat(avetotprofit_slsf(1,starttrial:trials),numsizes,1);
        lowerprof = avetotprofit_lcf_it_ss < repmat(avetotprofit_slsf(1,starttrial:trials),numsizes,1);
        percbetter = mean(higherprof')'
        percworse = mean(lowerprof')'
        
    elseif metric=='ma'
         %plot cdf of matches lcf-it for diff  scen scales
        if graph == 1 
            for i_plots=1:numsizes
            p2=cdfplot(20*ones(1,numtrials)-testrejave_lcf_it_ss(i_plots,:))
            p2.Color=colors(i_plots,:);
            p2.LineStyle=symbols_nomark(i_plots,:);
            p2.LineWidth=1.5
            hold on
            end
            lg=legend('10 var, 10 fix','10 var, 50 fix','50 var, 10 fix','50 var, 50 fix')
            lg.Location='northwest'
            xlabel('Expected Matches')
            ylabel('Cumulative Probability')
            title('CDF of Matches')
        end
      
         deviation = std(testrejave_lcf_it_ss')'
       
        confidence = quantile(testrejave_lcf_it_ss',[0.025,0.975])'
        
        aveslsf = mean(testrejave_slsf(1,starttrial:trials))
        average = mean(testrejave_lcf_it_ss')'
        avepercbetter=ones(numsizes,1)-average./repmat(aveslsf,numsizes,1)
        %=mean((ones(numsizes,numtrials)-testrejave_lcf_it_ss./repmat(testrejave_slsf(1,starttrial:trials),numsizes,1))')'
        higherunmat = testrejave_lcf_it_ss > repmat(testrejave_slsf(1,starttrial:trials),numsizes,1);
        lowerunmat = testrejave_lcf_it_ss < repmat(testrejave_slsf(1,starttrial:trials),numsizes,1);
        percbetter = mean(lowerunmat')'
        percworse = mean(higherunmat')'
        
     elseif metric=='un'
         %plot cdf of unhappy drivers lcf-it for diff  scen scales
       if graph == 1
            for i_plots=1:numsizes
            p2=cdfplot(testdupave_lcf_it_ss(i_plots,:))
            p2.Color=colors(i_plots,:);
            p2.LineStyle=symbols_nomark(i_plots,:);
            p2.LineWidth=1.5
            hold on
            end
            lg=legend('10 var, 10 fix','10 var, 50 fix','50 var, 10 fix','50 var, 50 fix')
            lg.Location='southeast'
            xlabel('Expected Unhappy Driver Requests')
            ylabel('Cumulative Probability')
            title('CDF of Unhappy Driver Requests')
       end
        
        deviation = std(testdupave_lcf_it_ss')'
       
        confidence = quantile(testdupave_lcf_it_ss',[0.025,0.975])'
        
        aveslsf = mean(testdupave_slsf(1,starttrial:trials))
        average = mean(testdupave_lcf_it_ss')'
        avepercbetter=ones(numsizes,1)-average./repmat(aveslsf,numsizes,1)
        %avepercbetter=mean((ones(numsizes,numtrials)-testdupave_lcf_it_ss./repmat(testdupave_slsf(1,starttrial:trials),numsizes,1))')'
        higherunhap = testdupave_lcf_it_ss > repmat(testdupave_slsf(1,starttrial:trials),numsizes,1);
        lowerunhap = testdupave_lcf_it_ss < repmat(testdupave_slsf(1,starttrial:trials),numsizes,1);
        percbetter = mean(lowerunhap')'
        percworse = mean(higherunhap')'
        
    elseif metric=='ru'
        %%% runtime info for lcf-it for diff  scen scales
        if graph == 1
            for i_plots=1:numsizes
            p2=cdfplot(runtimes_lcf_it_ss(i_plots,:))
            p2.Color=colors(i_plots,:);
            p2.LineStyle=symbols_nomark(i_plots,:);
            p2.LineWidth=1.5
            hold on
            end
            lg=legend('10 var, 10 fix','10 var, 50 fix','50 var, 10 fix','50 var, 50 fix')
            lg.Location='southeast'
            xlabel('Runtime')
            ylabel('Cumulative Probability')
            title('CDF of Runtime')
        end
        deviation = std(runtimes_lcf_it_ss')'
       
        confidence = quantile(runtimes_lcf_it_ss',[0.025,0.975])'
        
        aveslsf = mean(runtimes_slsf(1,starttrial:trials))
        average = mean(runtimes_lcf_it_ss')'
        ratio = average/aveslsf
        
    end
    
    
    
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% for the ratio (fine tuning) of scenario size tuning
    %%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif tunparam=='sr'
    if needload==1
        numsizes=2; %adjust to be the length of variscen_sizes_lcf_it_sr/ variscen_sizes_lcf_it_sr (below) 
        testobjave_lcf_it_sr=zeros(numsizes,numtrials);
        testrejave_lcf_it_sr=zeros(numsizes,numtrials);
        testdupave_lcf_it_sr=zeros(numsizes,numtrials);
        avetotprofit_lcf_it_sr=zeros(numsizes,numtrials);
        runtimes_lcf_it_sr=zeros(numsizes,numtrials);
        
        testobjsd_lcf_it_sr=zeros(numsizes,numtrials);
        testrejsd_lcf_it_sr=zeros(numsizes,numtrials);
        totprofitsd_lcf_it_sr=zeros(numsizes,numtrials);
        runtimessd_lcf_it_sr=zeros(numsizes,numtrials);
%         variscen_sizes_lcf_it_sr=[20,10,20,20];
%         variscen_sizes_lcf_it_sr=[20,20,10,20];
%        variscen_sizes_lcf_it_sr=[5,10,10,20,20];
%        fixedscen_sizes_lcf_it_sr=[5,10,20,10,20];
        variscen_sizes_lcf_it_sr=[5,50]; %right now these just look at SOL-IT_10(5,5) and SOL-IT_10(50,50) but you can add to 
        %variscen_sizes_lcf_it_sr/ variscen_sizes_lcf_it_sr to test the SOL-IT_10 solutions for any fixed/variable scen sizes that are in the paper
        fixedscen_sizes_lcf_it_sr=[5,50];
        for i_plots=1:numsizes
            
            %load the data for the given number of fixed/vari scenarios and
            %save the data
       
            stem= sprintf('lcf_it_bestperfmaxI10P10FS%dVS%d%s.mat',fixedscen_sizes_lcf_it_sr(1,i_plots),variscen_sizes_lcf_it_sr(1,i_plots),plotnotes);
            filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Paper_experiments\LCF_it_bestperf\' stem];
            load(filename)
            if length(plotnotes) == 3
                 testobjave_lcf_it_sr(i_plots,:)=testobjave_best_lcf_it_bestperf(1,101:200);
                testrejave_lcf_it_sr(i_plots,:)=testrejave_best_lcf_it_bestperf(1,101:200);
                testdupave_lcf_it_sr(i_plots,:)=testdupave_best_lcf_it_bestperf(1,101:200);
                avetotprofit_lcf_it_sr(i_plots,:)=avetotprofit_best_lcf_it_bestperf(1,101:200);
                runtimes_lcf_it_sr(i_plots,:)=runtimes_total_lcf_it_noperf(1,101:200);
                starttrial = 101;
            
            else
            testobjave_lcf_it_sr(i_plots,:)=testobjave_best_lcf_it_bestperf;
            testrejave_lcf_it_sr(i_plots,:)=testrejave_best_lcf_it_bestperf;
            testdupave_lcf_it_sr(i_plots,:)=testdupave_best_lcf_it_bestperf;
            avetotprofit_lcf_it_sr(i_plots,:)=avetotprofit_best_lcf_it_bestperf;
            runtimes_lcf_it_sr(i_plots,:)=runtimes_total_lcf_it_noperf;
            starttrial = 1;
            end
            
        end
    end
 
    if graph == 1
    figure('Renderer', 'painters', 'Position', [300 300 350 350])
    end
    
    if metric=='ob'
        %plot cdf of obj for lcf-it for diff finetune ratios (if graph=1)
        if graph == 1
            for i_plots=1:numsizes
            p2=cdfplot(testobjave_lcf_it_sr(i_plots,:))
            p2.Color=colors(i_plots,:);
            p2.LineStyle=symbols_nomark(i_plots,:);
            p2.LineWidth=1.5
            hold on
            end
            lg=legend('5 var, 5 fix','10 var, 10 fix','10 var, 20 fix','20 var, 10 fix','20 var, 20 fix')
            lg.Location='northwest'
            xlabel('Objective Estimate')
            ylabel('Cumulative Probability')
            title('CDF of Objective Estimates')
        end
        %standard deviation of each experiment across the trials
        deviation = std(testobjave_lcf_it_sr')'
       
        %confidence interval
        confidence = quantile(testobjave_lcf_it_sr',[0.025,0.975])'
        
        %average
        aveslsf = mean(testobjave_slsf(1,starttrial:trials))
        average = mean(testobjave_lcf_it_sr')'
        avepercbetter=-ones(numsizes,1)+average./repmat(aveslsf,numsizes,1)
        %avepercbetter = mean((testobjave_lcf_it_sr./repmat(testobjave_slsf(1,starttrial:trials),numsizes,1)-ones(numsizes,numtrials))')'
        higherobj = testobjave_lcf_it_sr > repmat(testobjave_slsf(1,starttrial:trials),numsizes,1);
        lowerobj = testobjave_lcf_it_sr < repmat(testobjave_slsf(1,starttrial:trials),numsizes,1);
        percbetter = mean(higherobj')'
        percworse = mean(lowerobj')'
        
        pvals = zeros (numsizes,1);
        diffs = repmat(testobjave_lcf_it_sr(1,:),numsizes,1)-testobjave_lcf_it_sr;
        %significance test as described in the paper, comparing to 
         [h,p] = ttest(testobjave_lcf_it_sr(1,:)-testobjave_slsf(1,starttrial:trials),0,'Tail','right');
         pvals(1,1)=p;
         if numsizes > 1
            for i_plots = 2:numsizes
                [h,p] = ttest(testobjave_lcf_it_sr(1,:)-testobjave_lcf_it_sr(i_plots,:),0,'Tail','right');
                pvals(i_plots,1)=p;
            end
         end
         pvals
         floor(log10(pvals))
         
         %confidence interval
         CI_low = mean(diffs')'-.258*std(diffs')'
         CI_high = mean(diffs')'+.258*std(diffs')'
         mean(avetotprofit_slsf)
         %fprintf('%6.4f\n', pvals);
        %avepercbetter=mean(mean((testobjave_lcf_base./testobjave_slsf)-ones(1,trials)))
    elseif metric=='pr'
         %plot cdf of profit lcf-it for diff finetune ratios
        if graph == 1
            for i_plots=1:numsizes
            p2=cdfplot(avetotprofit_lcf_it_sr(i_plots,:))
            p2.Color=colors(i_plots,:);
            p2.LineStyle=symbols_nomark(i_plots,:);
            p2.LineWidth=1.5
            hold on
            end
            lg=legend('5 var, 5 fix','10 var, 10 fix','10 var, 20 fix','20 var, 10 fix','20 var, 20 fix')
            lg.Location='northwest'
            xlabel('Expected Profit')
            ylabel('Cumulative Probability')
            title('CDF of Profit')
        end
        
        deviation = std(avetotprofit_lcf_it_sr')'
       
        confidence = quantile(avetotprofit_lcf_it_sr',[0.025,0.975])'
        
        aveslsf = mean(avetotprofit_slsf(1,starttrial:trials))
        average = mean(avetotprofit_lcf_it_sr')'
        avepercbetter=-ones(numsizes,1)+average./repmat(aveslsf,numsizes,1)
        %avepercbetter=mean((avetotprofit_lcf_it_sr./repmat(avetotprofit_slsf(1,starttrial:trials),numsizes,1)-ones(numsizes,numtrials))')'
        higherprof = avetotprofit_lcf_it_sr > repmat(avetotprofit_slsf(1,starttrial:trials),numsizes,1);
        lowerprof = avetotprofit_lcf_it_sr < repmat(avetotprofit_slsf(1,starttrial:trials),numsizes,1);
        percbetter = mean(higherprof')'
        percworse = mean(lowerprof')'
        
    elseif metric=='ma'
         %plot cdf of matches lcf-it for diff finetune ratios
        if graph == 1 
            for i_plots=1:numsizes
            p2=cdfplot(20*ones(1,numtrials)-testrejave_lcf_it_sr(i_plots,:))
            p2.Color=colors(i_plots,:);
            p2.LineStyle=symbols_nomark(i_plots,:);
            p2.LineWidth=1.5
            hold on
            end
            lg=legend('5 var, 5 fix','10 var, 10 fix','10 var, 20 fix','20 var, 10 fix','20 var, 20 fix')
            lg.Location='northwest'
            xlabel('Expected Matches')
            ylabel('Cumulative Probability')
            title('CDF of Matches')
        end
      
         deviation = std(testrejave_lcf_it_sr')'
       
        confidence = quantile(testrejave_lcf_it_sr',[0.025,0.975])'
        
        aveslsf = mean(testrejave_slsf(1,starttrial:trials))
        average = mean(testrejave_lcf_it_sr')'
        avepercbetter=ones(numsizes,1)-average./repmat(aveslsf,numsizes,1)
        %=mean((ones(numsizes,numtrials)-testrejave_lcf_it_sr./repmat(testrejave_slsf(1,starttrial:trials),numsizes,1))')'
        higherunmat = testrejave_lcf_it_sr > repmat(testrejave_slsf(1,starttrial:trials),numsizes,1);
        lowerunmat = testrejave_lcf_it_sr < repmat(testrejave_slsf(1,starttrial:trials),numsizes,1);
        percbetter = mean(lowerunmat')'
        percworse = mean(higherunmat')'
        
     elseif metric=='un'
         %plot cdf of unhappy drivers lcf-it for diff finetune ratios
       if graph == 1
            for i_plots=1:numsizes
            p2=cdfplot(testdupave_lcf_it_sr(i_plots,:))
            p2.Color=colors(i_plots,:);
            p2.LineStyle=symbols_nomark(i_plots,:);
            p2.LineWidth=1.5
            hold on
            end
            lg=legend('5 var, 5 fix','10 var, 10 fix','10 var, 20 fix','20 var, 10 fix','20 var, 20 fix')
            lg.Location='southeast'
            xlabel('Expected Unhappy Driver Requests')
            ylabel('Cumulative Probability')
            title('CDF of Unhappy Driver Requests')
       end
        
        deviation = std(testdupave_lcf_it_sr')'
       
        confidence = quantile(testdupave_lcf_it_sr',[0.025,0.975])'
        
        aveslsf = mean(testdupave_slsf(1,starttrial:trials))
        average = mean(testdupave_lcf_it_sr')'
        avepercbetter=ones(numsizes,1)-average./repmat(aveslsf,numsizes,1)
        %avepercbetter=mean((ones(numsizes,numtrials)-testdupave_lcf_it_sr./repmat(testdupave_slsf(1,starttrial:trials),numsizes,1))')'
        higherunhap = testdupave_lcf_it_sr > repmat(testdupave_slsf(1,starttrial:trials),numsizes,1);
        lowerunhap = testdupave_lcf_it_sr < repmat(testdupave_slsf(1,starttrial:trials),numsizes,1);
        percbetter = mean(lowerunhap')'
        percworse = mean(higherunhap')'
        
    elseif metric=='ru'
        %%% runtime info for lcf-it for diff finetune ratios
        if graph == 1
            for i_plots=1:numsizes
            p2=cdfplot(runtimes_lcf_it_sr(i_plots,:))
            p2.Color=colors(i_plots,:);
            p2.LineStyle=symbols_nomark(i_plots,:);
            p2.LineWidth=1.5
            hold on
            end
            lg=legend('5 var, 5 fix','10 var, 10 fix','10 var, 20 fix','20 var, 10 fix','20 var, 20 fix')
            lg.Location='southeast'
            xlabel('Runtime')
            ylabel('Cumulative Probability')
            title('CDF of Runtime')
        end
        deviation = std(runtimes_lcf_it_sr')'
       
        confidence = quantile(runtimes_lcf_it_sr',[0.025,0.975])'
        
        aveslsf = mean(runtimes_slsf(1,starttrial:trials))
        average = mean(runtimes_lcf_it_sr')'
        ratio = average/aveslsf
        
    end
    
    
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% for the premium tuning graphs
    %%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif tunparam=='pr'
    if needload==1
        numsizes = 8;
        testobjave_lcf_it_pr=zeros(numsizes,trials);
        testrejave_lcf_it_pr=zeros(numsizes,trials);
        testdupave_lcf_it_pr=zeros(numsizes,trials);
        avetotprofit_lcf_it_pr=zeros(numsizes,trials);
        runtimes_lcf_it_pr=zeros(numsizes,trials);
        prem_sizes=[0.65,0.7,0.75,0.8,0.85,0.9,0.95,1];
        premstr_sizes=['65';'70';'75';'80';'85';'90';'95';'10'];
        for i_plots=1:numsizes
          
            stem= sprintf('lcf_it_bestperfmaxI10P%sFS5VS5.mat',premstr_sizes(i_plots,:));
            filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Paper_experiments\LCF_it_bestperf\' stem];
            load(filename)
            testobjave_lcf_it_pr(i_plots,:)=testobjave_best_lcf_it_bestperf;
            testrejave_lcf_it_pr(i_plots,:)=testrejave_best_lcf_it_bestperf;
            testdupave_lcf_it_pr(i_plots,:)=testdupave_best_lcf_it_bestperf;
            avetotprofit_lcf_it_pr(i_plots,:)=avetotprofit_best_lcf_it_bestperf;
            runtimes_lcf_it_pr(i_plots,:)=runtimes_total_lcf_it_noperf;
        end
    end
    
    if graph == 1
    figure('Renderer', 'painters', 'Position', [300 300 350 350])
    end
    
    
    if metric=='ob'
        %plot cdf of lcf-it obj for different premiums
        for i_plots=1:numsizes
        p2=cdfplot(testobjave_lcf_it_pr(i_plots,:))
        p2.Color=colors(i_plots,:);
        p2.LineStyle=symbols_nomark(i_plots,:);
        p2.LineWidth=1.5
        hold on
        end
        lg=legend('prem=0.65','prem=0.7','prem=0.75','prem=0.8','prem=0.85','prem=0.9','prem=0.95','prem=1')
        lg.Location='northwest'
        xlabel('Objective Estimate')
        ylabel('Cumulative Probability')
        title('CDF of Objective Estimates')
        
        
        deviation = std(testobjave_lcf_it_pr')'
       
        confidence = quantile(testobjave_lcf_it_pr',[0.025,0.975])'
        
        aveslsf = mean(testobjave_slsf)
        average = mean(testobjave_lcf_it_pr')'
        %avepercbetter=mean((testobjave_lcf_it_pr./repmat(testobjave_slsf,numsizes,1)-ones(numsizes,trials))')'
         avepercbetter=-ones(numsizes,1)+average./repmat(aveslsf,numsizes,1)
        
        
       
    elseif metric=='pr'
         %plot cdf of lcf-it profit for different prems
       
        for i_plots=1:numsizes
        p2=cdfplot(avetotprofit_lcf_it_pr(i_plots,:))
        p2.Color=colors(i_plots,:);
        p2.LineStyle=symbols_nomark(i_plots,:);
        p2.LineWidth=1.5
        hold on
        end
        lg=legend('prem=0.65','prem=0.7','prem=0.75','prem=0.8','prem=0.85','prem=0.9','prem=0.95','prem=1')
        lg.Location='northwest'
        xlabel('Expected Profit')
        ylabel('Cumulative Probability')
        title('CDF of Profit')
        
       deviation = std(avetotprofit_lcf_it_pr')'
       
        confidence = quantile(avetotprofit_lcf_it_pr',[0.025,0.975])'
        
        aveslsf = mean(avetotprofit_slsf)
        average = mean(avetotprofit_lcf_it_pr')'
        %avepercbetter=mean((avetotprofit_lcf_it_pr./repmat(avetotprofit_slsf,numsizes,1)-ones(numsizes,trials))')'
        avepercbetter=-ones(numsizes,1)+average./repmat(aveslsf,numsizes,1)
        
    elseif metric=='ma'
         %plot cdf of lcf-it matches for diff prems
        for i_plots=1:numsizes
        p2=cdfplot(20*ones(1,trials)-testrejave_lcf_it_pr(i_plots,:))
        p2.Color=colors(i_plots,:);
        p2.LineStyle=symbols_nomark(i_plots,:);
        p2.LineWidth=1.5
        hold on
        end
        lg=legend('prem=0.65','prem=0.7','prem=0.75','prem=0.8','prem=0.85','prem=0.9','prem=0.95','prem=1')
        lg.Location='northwest'
        xlabel('Expected Matches')
        ylabel('Cumulative Probability')
        title('CDF of Matches')
     
        
        deviation = std(testrejave_lcf_it_pr')'
       
        confidence = quantile(testrejave_lcf_it_pr',[0.025,0.975])'
        
        aveslsf = mean(testrejave_slsf)
        average = mean(testrejave_lcf_it_pr')'
        %avepercbetter=mean((ones(numsizes,trials)-testrejave_lcf_it_pr./repmat(testrejave_slsf,numsizes,1))')'
        avepercbetter=ones(numsizes,1)-average./repmat(aveslsf,numsizes,1)
        
         elseif metric=='un'
         %plot cdf of lcf-it unhappy driver requests for diff prems
        for i_plots=1:numsizes
        p2=cdfplot(testdupave_lcf_it_pr(i_plots,:))
        p2.Color=colors(i_plots,:);
        p2.LineStyle=symbols_nomark(i_plots,:);
        p2.LineWidth=1.5
        hold on
        end
        lg=legend('prem=0.65','prem=0.7','prem=0.75','prem=0.8','prem=0.85','prem=0.9','prem=0.95','prem=1')
        lg.Location='northwest'
        xlabel('Expected Unhappy Driver Requests')
        ylabel('Cumulative Probability')
        title('CDF of Unhappy Driver Requests')
     
        
        deviation = std(testdupave_lcf_it_pr')'
       
        confidence = quantile(testdupave_lcf_it_pr',[0.025,0.975])'
        
        aveslsf = mean(testdupave_slsf)
        average = mean(testdupave_lcf_it_pr')'
        %avepercbetter=mean((ones(numsizes,trials)-testdupave_lcf_it_pr./repmat(testdupave_slsf,numsizes,1))')'
        avepercbetter=ones(numsizes,1)-average./repmat(aveslsf,numsizes,1)
        
    elseif metric=='ru'
        %%% runtime info for lcf-it for diff prems
        
        for i_plots=1:numsizes
        p2=cdfplot(runtimes_lcf_it_pr(i_plots,:))
        p2.Color=colors(i_plots,:);
        p2.LineStyle=symbols_nomark(i_plots,:);
        p2.LineWidth=1.5
        hold on
        end
        lg=legend('prem=0.65','prem=0.7','prem=0.75','prem=0.8','prem=0.85','prem=0.9','prem=0.95','prem=1')
        lg.Location='southeast'
        xlabel('Runtime')
        ylabel('Cumulative Probability')
        title('CDF of Runtime')
        
        
       deviation = std(runtimes_lcf_it_pr')'
       
        confidence = quantile(runtimes_lcf_it_pr',[0.025,0.975])'
        
        aveslsf = mean(runtimes_slsf)
        average = mean(runtimes_lcf_it_pr')'
        
    end
    
    
    



 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% for the stats analysis (different number of iterations and
    %%%% alternate methods significance tests)
    %%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif tunparam=='st'
   if needload == 1
      stem = 'param_tuning_vals.mat';
  
        filename = [ 'C:\Users\horneh\documents\LCF_Paper_Experiments\' stem];
        load(filename) 
   end

    if graph == 1
    figure('Renderer', 'painters', 'Position', [300 300 350 350])
    end
    
    if metric=='ob'
        %plot cdf of obj for lcf-it 
        if graph == 1
            for i_plots=1:numsizes
            p2=cdfplot(testobjave_lcf_it_sr(i_plots,:))
            p2.Color=colors(i_plots,:);
            p2.LineStyle=symbols_nomark(i_plots,:);
            p2.LineWidth=1.5
            hold on
            end
            lg=legend('5 var, 5 fix','10 var, 10 fix','10 var, 20 fix','20 var, 10 fix','20 var, 20 fix')
            lg.Location='northwest'
            xlabel('Objective Estimate')
            ylabel('Cumulative Probability')
            title('CDF of Objective Estimates')
        end
         
        
        %%%% for our base problem sizes 10 iters
        means_10 = mean(testobjave_lcf_it_10')'
        [best_metric_10,best_index_10] = max(mean(testobjave_lcf_it_10'))
        best_index_10 = 2;
        pvals_10 = zeros (numsizes_10,1);
        diffs_10 = repmat(testobjave_lcf_it_10(best_index_10,:),numsizes_10,1)-testobjave_lcf_it_10;
        
        for i_plots = 1:numsizes_10
            [h,p] = ttest(diffs_10(i_plots,:),0,'Tail','right');
            pvals_10(i_plots,1)=p;
        end
         disp('pvals_10=')
         fprintf('%.4f\n', pvals_10);
         exp_10 = floor(log10(pvals_10));
         
         CI_low_10 = mean(diffs_10')'-.258*std(diffs_10')'
         CI_high_10 = mean(diffs_10')'+.258*std(diffs_10')'
         
         %%%%% for fewer iterations
          means_1257 = mean(testobjave_lcf_it_1257')'
          pvals_1257 = zeros (numsizes_1257,1);
        diffs_1257 = repmat(testobjave_lcf_it_10(best_index_10,:),numsizes_1257,1)-testobjave_lcf_it_1257;
 
        for i_plots = 1:numsizes_1257
            [h,p] = ttest(diffs_1257(i_plots,:),0,'Tail','right');
            pvals_1257(i_plots,1)=p;
        end
         disp('pvals_1257=')
         fprintf('%.4f\n', pvals_1257);
         exp_1257 = floor(log10(pvals_1257))
         
         CI_low_1257 = mean(diffs_1257')'-.258*std(diffs_1257')'
         CI_high_1257 = mean(diffs_1257')'+.258*std(diffs_1257')'
         
         %%%% for 13 iters
          means_13 = mean(testobjave_lcf_it_13')'
          pvals_13 = zeros(numsizes_13,1);
        diffs_13 = repmat(testobjave_lcf_it_10(best_index_10,:),numsizes_13,1)-testobjave_lcf_it_13; 
        for i_plots = 1:numsizes_13
            [h,p] = ttest(diffs_13(i_plots,:),0,'Tail','right');
            pvals_13(i_plots,1) = p;
        end
         disp('pvals_13=')
         fprintf('%.4f\n', pvals_13);
         exp_13 = floor(log10(pvals_13))
         
         CI_low_13 = mean(diffs_13')'-.258*std(diffs_13')'
         CI_high_13 = mean(diffs_13')'+.258*std(diffs_13')'
         
         %%% for worse methods
          means_mthds = mean(testobjave_lcf_mthds')'
          pvals_mthds = zeros (numsizes_mthds,1);
        diffs_mthds = repmat(testobjave_lcf_it_10(best_index_10,:),numsizes_mthds,1)-testobjave_lcf_mthds;
 
        for i_plots = 1:numsizes_mthds
            [h,p] = ttest(diffs_mthds(i_plots,:),0,'Tail','right');
            pvals_mthds(i_plots,1)=p;
        end
        fprintf('%.4f\n', pvals_mthds)
         exp_mthds = floor(log10(pvals_mthds))
         
         CI_low_mthds = mean(diffs_mthds')'-.258*std(diffs_mthds')'
         CI_high_mthds = mean(diffs_mthds')'+.258*std(diffs_mthds')'
         
        %%%
         
        %avepercbetter=mean(mean((testobjave_lcf_base./testobjave_slsf)-ones(1,trials)))
    elseif metric=='pr'
         %plot cdf of profit lcf-it for diff finetune ratios
        if graph == 1
            for i_plots=1:numsizes
            p2=cdfplot(avetotprofit_lcf_it_sr(i_plots,:))
            p2.Color=colors(i_plots,:);
            p2.LineStyle=symbols_nomark(i_plots,:);
            p2.LineWidth=1.5
            hold on
            end
            lg=legend('5 var, 5 fix','10 var, 10 fix','10 var, 20 fix','20 var, 10 fix','20 var, 20 fix')
            lg.Location='northwest'
            xlabel('Expected Profit')
            ylabel('Cumulative Probability')
            title('CDF of Profit')
        end
        
       %%%% for our base problem sizes 10 iters
        means_10 = mean(avetotprofit_lcf_it_10')'
        [best_metric_10,best_index_10] = max(mean(avetotprofit_lcf_it_10(2:numsizes_10,:)'))
        best_index_10 = best_index_10 +1;
        best_index_10 = 2
        pvals_10 = zeros (numsizes_10,1);
        diffs_10 = repmat(avetotprofit_lcf_it_10(best_index_10,:),numsizes_10,1)-avetotprofit_lcf_it_10;
 
        for i_plots = 1:numsizes_10
            [h,p] = ttest(diffs_10(i_plots,:),0,'Tail','right');
            pvals_10(i_plots,1)=p;
        end
        disp('pvals_10=')
         fprintf('%.4f\n', pvals_10);
         exp_10 = floor(log10(pvals_10))
         
         CI_low_10 = mean(diffs_10')'-.258*std(diffs_10')'
         CI_high_10 = mean(diffs_10')'+.258*std(diffs_10')'
         
         %%%%% for fewer iterations
          means_1257 = mean(avetotprofit_lcf_it_1257')'
          pvals_1257 = zeros (numsizes_1257,1);
        diffs_1257 = repmat(avetotprofit_lcf_it_10(best_index_10,:),numsizes_1257,1)-avetotprofit_lcf_it_1257;
 
        for i_plots = 1:numsizes_1257
            [h,p] = ttest(-diffs_1257(i_plots,:),0,'Tail','right');
            pvals_1257(i_plots,1)=p;
        end
         disp('pvals_1257=')
         fprintf('%.4f\n', pvals_1257);
         exp_1257 = floor(log10(pvals_1257))
         
         CI_low_1257 = mean(diffs_1257')'-.258*std(diffs_1257')'
         CI_high_1257 = mean(diffs_1257')'+.258*std(diffs_1257')'
         
         %%%% for 13 iters
           %%%% for 13 iters
          means_13 = mean(avetotprofit_lcf_it_13')'
          pvals_13 = zeros(numsizes_13,1);
        diffs_13 = repmat(avetotprofit_lcf_it_10(best_index_10,:),numsizes_13,1)-avetotprofit_lcf_it_13; 
        for i_plots = 1:numsizes_13
            [h,p] = ttest(diffs_13(i_plots,:),0,'Tail','right');
            pvals_13(i_plots,1) = p;
        end
         disp('pvals_13=')
         fprintf('%.4f\n', pvals_13);
         exp_13 = floor(log10(pvals_13))
         
         CI_low_13 = mean(diffs_13')'-.258*std(diffs_13')'
         CI_high_13 = mean(diffs_13')'+.258*std(diffs_13')'
         
         %%% for worse methods
          means_mthds = mean(avetotprofit_lcf_mthds')'
          pvals_mthds = zeros (numsizes_mthds,1);
        diffs_mthds = repmat(avetotprofit_lcf_it_10(best_index_10,:),numsizes_mthds,1)-avetotprofit_lcf_mthds;
 
        for i_plots = 1:numsizes_mthds
            [h,p] = ttest(diffs_mthds(i_plots,:),0,'Tail','right');
            pvals_mthds(i_plots,1)=p;
        end
         disp('pvals_mthds=')
         fprintf('%.4f\n', pvals_mthds);
         exp_mthds = floor(log10(pvals_mthds))
         
         CI_low_mthds = mean(diffs_mthds')'-.258*std(diffs_mthds')'
         CI_high_mthds = mean(diffs_mthds')'+.258*std(diffs_mthds')'
        
    elseif metric=='ma'
         %plot cdf of matches lcf-it for diff finetune ratios
        if graph == 1 
            for i_plots=1:numsizes
            p2=cdfplot(20*ones(1,numtrials)-testrejave_lcf_it_sr(i_plots,:))
            p2.Color=colors(i_plots,:);
            p2.LineStyle=symbols_nomark(i_plots,:);
            p2.LineWidth=1.5
            hold on
            end
            lg=legend('5 var, 5 fix','10 var, 10 fix','10 var, 20 fix','20 var, 10 fix','20 var, 20 fix')
            lg.Location='northwest'
            xlabel('Expected Matches')
            ylabel('Cumulative Probability')
            title('CDF of Matches')
        end
       
        %%%% for our base problem sizes 10 iters
        means_10 = mean(testrejave_lcf_it_10')'
        [best_metric_10,best_index_10] = min(mean(testrejave_lcf_it_10'))
        best_index_10 = 2;
        pvals_10 = zeros (numsizes_10,1);
        diffs_10 = repmat(testrejave_lcf_it_10(best_index_10,:),numsizes_10,1)-testrejave_lcf_it_10;
        
        for i_plots = 1:numsizes_10
            [h,p] = ttest(diffs_10(i_plots,:),0,'Tail','left');
            pvals_10(i_plots,1)=p;
        end
         disp('pvals_10=')
         fprintf('%.4f\n', pvals_10);
         exp_10 = floor(log10(pvals_10))
         
         CI_low_10 = mean(diffs_10')'-.258*std(diffs_10')'
         CI_high_10 = mean(diffs_10')'+.258*std(diffs_10')'
         
         %%%%% for fewer iterations
          means_1257 = mean(testrejave_lcf_it_1257')'
          pvals_1257 = zeros (numsizes_1257,1);
        diffs_1257 = repmat(testrejave_lcf_it_10(best_index_10,:),numsizes_1257,1)-testrejave_lcf_it_1257;
 
        for i_plots = 1:numsizes_1257
            [h,p] = ttest(diffs_1257(i_plots,:),0,'Tail','left');
            pvals_1257(i_plots,1)=p;
        end
         disp('pvals_1257=')
         fprintf('%.4f\n', pvals_1257);
         exp_1257 = floor(log10(pvals_1257))
         
         CI_low_1257 = mean(diffs_1257')'-.258*std(diffs_1257')'
         CI_high_1257 = mean(diffs_1257')'+.258*std(diffs_1257')'
         
         %%%% for 13 iters
          means_13 = mean(testrejave_lcf_it_13')'
          pvals_13 = zeros(numsizes_13,1);
        diffs_13 = repmat(testrejave_lcf_it_10(best_index_10,:),numsizes_13,1)-testrejave_lcf_it_13; 
        for i_plots = 1:numsizes_13
            [h,p] = ttest(diffs_13(i_plots,:),0,'Tail','left');
            pvals_13(i_plots,1) = p;
        end
         disp('pvals_13=')
         fprintf('%.4f\n', pvals_13);
         exp_13 = floor(log10(pvals_13))
         
         CI_low_13 = mean(diffs_13')'-.258*std(diffs_13')'
         CI_high_13 = mean(diffs_13')'+.258*std(diffs_13')'
         
         %%% for worse methods
          means_mthds = mean(testrejave_lcf_mthds')'
          pvals_mthds = zeros (numsizes_mthds,1);
        diffs_mthds = repmat(testrejave_lcf_it_10(best_index_10,:),numsizes_mthds,1)-testrejave_lcf_mthds;
 
        for i_plots = 1:numsizes_mthds
            [h,p] = ttest(diffs_mthds(i_plots,:),0,'Tail','left');
            pvals_mthds(i_plots,1)=p;
        end
        fprintf('%.4f\n', pvals_mthds)
         exp_mthds = floor(log10(pvals_mthds))
         
         CI_low_mthds = mean(diffs_mthds')'-.258*std(diffs_mthds')'
         CI_high_mthds = mean(diffs_mthds')'+.258*std(diffs_mthds')'
        
        
        
     elseif metric=='un'
         %plot cdf of unhappy drivers lcf-it for diff finetune ratios
       if graph == 1
            for i_plots=1:numsizes
            p2=cdfplot(testdupave_lcf_it_sr(i_plots,:))
            p2.Color=colors(i_plots,:);
            p2.LineStyle=symbols_nomark(i_plots,:);
            p2.LineWidth=1.5
            hold on
            end
            lg=legend('5 var, 5 fix','10 var, 10 fix','10 var, 20 fix','20 var, 10 fix','20 var, 20 fix')
            lg.Location='southeast'
            xlabel('Expected Unhappy Driver Requests')
            ylabel('Cumulative Probability')
            title('CDF of Unhappy Driver Requests')
       end
        
        %%%% for our base problem sizes 10 iters
        means_10 = mean(testdupave_lcf_it_10')'
        [best_metric_10,best_index_10] = min(mean(testdupave_lcf_it_10'))
        best_index_10 = 2 
        pvals_10 = zeros (numsizes_10,1);
        diffs_10 = repmat(testdupave_lcf_it_10(best_index_10,:),numsizes_10,1)-testdupave_lcf_it_10;
 
        for i_plots = 1:numsizes_10
            [h,p] = ttest(diffs_10(i_plots,:),0,'Tail','left');
            pvals_10(i_plots,1)=p;
        end
         disp('pvals_10=')
         fprintf('%.4f\n', pvals_10);
         exp_10 = floor(log10(pvals_10))
         
         CI_low_10 = mean(diffs_10')'-.258*std(diffs_10')'
         CI_high_10 = mean(diffs_10')'+.258*std(diffs_10')'
         
         %%%%% for fewer iterations
          means_1257 = mean(testdupave_lcf_it_1257')'
          pvals_1257 = zeros (numsizes_1257,1);
        diffs_1257 = repmat(testdupave_lcf_it_10(best_index_10,:),numsizes_1257,1)-testdupave_lcf_it_1257;
 
        for i_plots = 1:numsizes_1257
            [h,p] = ttest(diffs_1257(i_plots,:),0,'Tail','left');
            pvals_1257(i_plots,1)=p;
        end
         disp('pvals_1257=')
         fprintf('%.4f\n', pvals_1257);
         exp_1257 = floor(log10(pvals_1257))
         
         CI_low_1257 = mean(diffs_1257')'-.258*std(diffs_1257')'
         CI_high_1257 = mean(diffs_1257')'+.258*std(diffs_1257')'
         
         %%%% for 13 iters
          means_13 = mean(testdupave_lcf_it_13')'
          pvals_13 = zeros(numsizes_13,1);
        diffs_13 = repmat(testdupave_lcf_it_10(best_index_10,:),numsizes_13,1)-testdupave_lcf_it_13; 
        for i_plots = 1:numsizes_13
            [h,p] = ttest(diffs_13(i_plots,:),0,'Tail','left');
            pvals_13(i_plots,1) = p;
        end
         disp('pvals_13=')
         fprintf('%.4f\n', pvals_13);
         exp_13 = floor(log10(pvals_13))
         
         CI_low_13 = mean(diffs_13')'-.258*std(diffs_13')'
         CI_high_13 = mean(diffs_13')'+.258*std(diffs_13')'
         
         %%% for worse methods
          means_mthds = mean(testdupave_lcf_mthds')'
          pvals_mthds = zeros (numsizes_mthds,1);
        diffs_mthds = repmat(testdupave_lcf_it_10(best_index_10,:),numsizes_mthds,1)-testdupave_lcf_mthds;
 
        for i_plots = 1:numsizes_mthds
            [h,p] = ttest(diffs_mthds(i_plots,:),0,'Tail','left');
            pvals_mthds(i_plots,1)=p;
        end
        fprintf('%.4f\n', pvals_mthds)
         exp_mthds = floor(log10(pvals_mthds))
         
         CI_low_mthds = mean(diffs_mthds')'-.258*std(diffs_mthds')'
         CI_high_mthds = mean(diffs_mthds')'+.258*std(diffs_mthds')'
        
    elseif metric=='ru'
        %%% runtime info for lcf-it for diff finetune ratios
        if graph == 1
            for i_plots=1:numsizes
            p2=cdfplot(runtimes_lcf_it_sr(i_plots,:))
            p2.Color=colors(i_plots,:);
            p2.LineStyle=symbols_nomark(i_plots,:);
            p2.LineWidth=1.5
            hold on
            end
            lg=legend('5 var, 5 fix','10 var, 10 fix','10 var, 20 fix','20 var, 10 fix','20 var, 20 fix')
            lg.Location='southeast'
            xlabel('Runtime')
            ylabel('Cumulative Probability')
            title('CDF of Runtime')
        end
        %%%% for our base problem sizes 10 iters
        
        means_10 = mean(runtimes_lcf_it_10')';
        disp('means_10=')
         fprintf('%.4f\n', means_10);
        [best_metric_10,best_index_10] = min(mean(runtimes_lcf_it_10'))
        best_index_10 = 2 
        pvals_10 = zeros (numsizes_10,1);
        diffs_10 = repmat(runtimes_lcf_it_10(best_index_10,:),numsizes_10,1)-runtimes_lcf_it_10;
 
        for i_plots = 1:numsizes_10
            [h,p] = ttest(diffs_10(i_plots,:),0,'Tail','left');
            pvals_10(i_plots,1)=p;
        end
         disp('pvals_10=')
         fprintf('%.4f\n', pvals_10);
         exp_10 = floor(log10(pvals_10))
         
         CI_low_10 = mean(diffs_10')'-.258*std(diffs_10')'
         CI_high_10 = mean(diffs_10')'+.258*std(diffs_10')'
         
         %%%%% for fewer iterations
          means_1257 = mean(runtimes_lcf_it_1257')'
          pvals_1257 = zeros (numsizes_1257,1);
        diffs_1257 = repmat(runtimes_lcf_it_10(best_index_10,:),numsizes_1257,1)-runtimes_lcf_it_1257;
 
        for i_plots = 1:numsizes_1257
            [h,p] = ttest(diffs_1257(i_plots,:),0,'Tail','left');
            pvals_1257(i_plots,1)=p;
        end
         disp('pvals_1257=')
         fprintf('%.4f\n', pvals_1257);
         exp_1257 = floor(log10(pvals_1257))
         
         CI_low_1257 = mean(diffs_1257')'-.258*std(diffs_1257')'
         CI_high_1257 = mean(diffs_1257')'+.258*std(diffs_1257')'
         
         %%%% for 13 iters
          means_13 = mean(runtimes_lcf_it_13')'
          pvals_13 = zeros(numsizes_13,1);
        diffs_13 = repmat(runtimes_lcf_it_10(best_index_10,:),numsizes_13,1)-runtimes_lcf_it_13; 
        for i_plots = 1:numsizes_13
            [h,p] = ttest(diffs_13(i_plots,:),0,'Tail','left');
            pvals_13(i_plots,1) = p;
        end
         disp('pvals_13=')
         fprintf('%.4f\n', pvals_13);
         exp_13 = floor(log10(pvals_13))
         
         CI_low_13 = mean(diffs_13')'-.258*std(diffs_13')'
         CI_high_13 = mean(diffs_13')'+.258*std(diffs_13')'
         
         %%% for worse methods
          means_mthds = mean(runtimes_lcf_mthds')'
          pvals_mthds = zeros (numsizes_mthds,1);
        diffs_mthds = repmat(runtimes_lcf_it_10(best_index_10,:),numsizes_mthds,1)-runtimes_lcf_mthds;
 
        for i_plots = 1:numsizes_mthds
            [h,p] = ttest(diffs_mthds(i_plots,:),0,'Tail','left');
            pvals_mthds(i_plots,1)=p;
        end
        fprintf('%.4f\n', pvals_mthds)
         exp_mthds = floor(log10(pvals_mthds))
         
         CI_low_mthds = mean(diffs_mthds')'-.258*std(diffs_mthds')'
         CI_high_mthds = mean(diffs_mthds')'+.258*std(diffs_mthds')'
        
    end

end
% testsampweights=kron(testscenprobslongslsf,ones(m,n));
%  offeredlong=zeros(m*trials,1);
%         for t=1:trials
%             offeredlong((t-1)*m+1:t*m,1)=sum(xlongslsf(:,(t-1)*n+1:t*n),2);
%         end
%         
% 
%        tbl=tabulate(offeredlong(:));
%       tblperc=tbl
%       tblperc(:,2)=tblperc(:,2)/sum(tbl(:,2));%trials/testsamps/n;
%       plot(tblperc(:,1),tblperc(:,2),'-x','LineWidth',2) 
%       hold on
%       ylabel('Probability')
%       xlabel('Number of Menus Containing Request')
%     title('Number of Driver Menus Containing a Given Request')
    