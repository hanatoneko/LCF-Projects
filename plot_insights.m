%this code is used to make all graphs, data analysis etc used to gain
%insights about the SOL-IT_10(5,5) solutions, including insights between
%the different solutions made each iteration. The analysis uses the
%variable data file 'concat_vals.mat' created by load_iter_insights

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%To make the plots/get analysis numbers, simply adjust the values for needload,  category, and metric
% as desired and then run the code. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

needload = 0; %since loading the data takes time, just set needload =1 when you need to load the data in and set as 0 after that
if needload == 1
    load('C:\Users\horneh\Google Drive\RPI\Research\code\LCF_Paper_experiments\concat_vals.mat')
end


category = 'c'; %%% category is insights on iteration data ('i'), compensation ('c') or other ('o')
metric = 'fc'; %%% There are different metrics that can be analyzed for each category: 
%%% for comp: 'mm'=min/max comp, 'fp'=fare vs percent comp, 'fc'=fare vs
%%% comp, 'bc'=fare(incl booking) vs comp, 'ei'= expected (driver) income, 'md'=comp
%%% perc distribution based on menu size, 'cd'=comp (%) distribution, 'cp'=
%%% comp % vs ``pij, 'cb'=comp % vs yprobs (under initial slsf comp), 'fa' =fare vs comp only incl ones assigned in solver
%%% for iterations: 'mo'= menu overlap, 'ta'=minitest accuracy,
%%% 'cf'=coinflip best soln (accuracy of using coinflip instead of minitest), 'rs'=random
%%%iter best soln (accuracy of picking random solution instead of
%%%minitest), 'si'=soln improvement each iteration
%%% for other: 'ms'=menu size, 'pd'=pij distribution, 'ru'=runtime averages, 'cd' =chicago data




trials = 100;
testsamps = 5000;
m = 20;
n = 20;
iters = 10;

%%% decides the size and location in which the graph is made on the screen, first two digits are the (pixel?) coordinates of
%%% the top left corner, then 3rd and 4th numbers are the (pixel?) width and hieght respectively
figure('Renderer', 'painters', 'Position', [300 300 400 330])

%%% rgb of some colors to use in plots
red=[0.6350 0.0780 0.1840];
orange=[0.8500 0.3250 0.0980];
yellow=[0.9290 0.6940 0.1250];
green=[0.4660 0.6740 0.1880];
blue=[0 0.4470 0.7410];
purple=[0.4940 0.1840 0.5560];

mean(testobjave_best_lcf_it_bestperf)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% comp %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if category == 'c'
    
    
%        
%          percoffered=(ubestlong+alphavalslong)./farelong;
% 
%         offeredlong=zeros(m,trials);
%         fareshort=zeros(m,trials);
%         menusizeslong=zeros(1,n*trials);
%         menusizeslong_incl=zeros(1,n*trials);
% 
%         for t=1:trials
%             offeredlong(:,t)=sum(xbestlong(:,(t-1)*n+1:t*n),2);
%             menusizeslong(1,(t-1)*n+1:n*t)=sum(xbestlong(:,(t-1)*n+1:t*n),1);
%             if nnz(xbestlong(:,(t-1)*n+1:t*n))>0
%                 menusizeslong_incl(1,(t-1)*n+1:n*t)=sum(xbestlong(:,(t-1)*n+1:t*n),1);
%             else
%                 menusizeslong_incl(1,(t-1)*n+1:n*t)=sum(x_slsf(:,(t-1)*n+1:t*n),1);
%             end
%             fareshort(:,t)=farelong(:,t*n);
%         end
%         mean(menusizeslong_incl)
%         tabulate(menusizeslong_incl)


    if metric == 'mm'
        %%%% calculates min/max compensation (or % comp) for each request and each
        %%%% driver (uncomment histogram lines of code below for whatever you
        %%%% want to plot
        
        %construct compensation offers of the returned menu set of every trial
        compinmenu=ubestlong+alphavalslong;
        for t = 1:100 
           if guessbestiter_lcf_it_final(1,t) == 0
               compinmenu(:,(t-1)*n+1:t*n) = slsfcomplong(:,(t-1)*n+1:t*n);
           end
        end
        
        %construct empty variables/initialize variables
        maxreqcomp=zeros(m,trials); %max comp offer for each request
        minreqcomp=-1*ones(m,trials); %min comp offer for each request
        meanreqcomp=zeros(m,trials); %average comp offer for each request
        maxdriv_perccomp=zeros(1,n*trials); %max comp offer divided by fare for each driver
        mindriv_perccomp=zeros(1,n*trials); %min comp offer divided by fare for each driver
        testobjave_lcf_incl=testobjave_lcf;
        testrejave_lcf_incl=testrejave_lcf;
        runtimes_lcf_incl=runtimes(1,:);
        
        %calculate the variable values
        for t=1:trials
            maxreqcomp(:,t)=max(compinmenu(:,(t-1)*n+1:t*n),[],2);
            maxdriv_perccomp(1,(t-1)*n+1:t*n)=max(compinmenu(:,(t-1)*n+1:t*n)./farelong(:,(t-1)*n+1:t*n),[],1);
            if testobjave_lcf(1,t)==0
                testobjave_lcf_incl(1,t)=testobjave_slsf(1,t);
                testrejave_lcf_incl(1,t)=testrejave_slsf(1,t);
                runtimes_lcf_incl(1,t)=runtimes_slsf(1,t);
            end
            for i=1:m
                if nnz(ubestlong(i,(t-1)*n+1:t*n))>1
                    tempcomp=compinmenu(i,(t-1)*n+1:t*n);
                     minreqcomp(i,t)=min(tempcomp(ubestlong(i,(t-1)*n+1:t*n)>0));
                end
            end
                for j=1:n
                if nnz(ubestlong(:,(t-1)*n+j))>1
                    tempcomp=compinmenu(:,(t-1)*n+j)./farelong(:,(t-1)*n+j);
                     mindriv_perccomp(1,(t-1)*n+j)=min(tempcomp(ubestlong(:,(t-1)*n+j)>0));
                end
            end

        end
        
        %%%%%% calculate averages etc, or uncomment any (one) histogram/plot
        %%%%%% line to plot it
        compreqrange=maxreqcomp-minreqcomp;
        %hist(compreqrange(offeredlong>1))
        compreqpercs=compreqrange(offeredlong>1)./fareshort(offeredlong>1);
        %hist(comppercs)
        compdriv_percrange=maxdriv_perccomp-mindriv_perccomp;
        %hist(compdriv_percrange(menusizeslong>1))
        %hist(mindriv_perccomp(menusizeslong>1))
        %hist(percoffered(ubestlong>0 & percoffered<2))
         %%% comp vs ave assign
        %plot(compinmenu(ubestlong>0),aveassign_lcf(ubestlong>0),'.','LineWidth',2)

        %%% percent comp vs ave assign
        %plot(compinmenu(ubestlong>0)./farelong(ubestlong>0),aveassign_lcf(ubestlong>0),'.','LineWidth',2)
    elseif metric == 'fp'
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% fare vs percent comp (of
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
            %construct compensation offers of the returned menu set of every trial
            compinmenu=ubest_lcf_it_bestperf+alphavalslong;
            for t = 1:100 
               if guessbestiter_lcf_it_final(1,t) == 0
                   compinmenu(:,(t-1)*n+1:t*n) = slsfcomplong(:,(t-1)*n+1:t*n);
               end
            end
            
            %plot scatterplot of fare vs comp/fare 
            blue=[0 0.4470 0.7410,0.5];
            plot(farelong(ubest_lcf_it_bestperf>0),compinmenu(ubest_lcf_it_bestperf>0)./farelong(ubest_lcf_it_bestperf>0),'.','MarkerSize',15,'color',blue)
            hold on
            
            %%%plot maximum allowed compensation/fare as a function of the fare
            
            [fareincr,fareind]=sort(farelong(ubest_lcf_it_bestperf>0));
            max_comp_allowed=alphavalslong(ubest_lcf_it_bestperf>0)+betavalslong(ubest_lcf_it_bestperf>0);
            max_compperc_allowed=(alphavalslong(ubest_lcf_it_bestperf>0)+betavalslong(ubest_lcf_it_bestperf>0))./farelong(ubest_lcf_it_bestperf>0);
            
            orange=[0.8500 0.3250 0.0980,0.6];
            plot(fareincr,max_compperc_allowed(fareind),'-','LineWidth',4,'color',orange)
            hold on
            
            %%%plot maximum allowed compensation/fare as a function of the fare
            yellow=[0.9290 0.6940 0.1250,0.8];
            green=[0.4660 0.6740 0.1880,1];
            mincurvey=horzcat(4*ones(1,201)./[3:0.01:5],0.8*ones(1,4000));
            plot([3:0.01:45],mincurvey,'-','LineWidth',4,'color',yellow)
            hold on
               xlabel('Fare (dollars)')
              ylabel('Portion of Fare Offered')
            title('Portion of Fare Offered to a Driver')
            legend('Offered','Maximum','Minimum')
    elseif metric == 'fc'
        
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% fare vs comp
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
             %construct compensation offers of the returned menu set of every trial
            compinmenu=ubest_lcf_it_bestperf+alphavalslong;
            for t = 1:100 
               if guessbestiter_lcf_it_final(1,t) == 0
                   compinmenu(:,(t-1)*n+1:t*n) = slsfcomplong(:,(t-1)*n+1:t*n);
               end
            end
            
            
            blue=[0 0.4470 0.7410,0.5];
            plot(farelong(ubest_lcf_it_bestperf>0),compinmenu(ubest_lcf_it_bestperf>0),'.','MarkerSize',15,'color',blue)
            hold on
            %%%plot maximum allowed compensation as a function of the fare
            [fareincr,fareind]=sort(farelong(ubest_lcf_it_bestperf>0));
            max_comp_allowed=alphavalslong(ubest_lcf_it_bestperf>0)+betavalslong(ubest_lcf_it_bestperf>0);
            max_compperc_allowed=(alphavalslong(ubest_lcf_it_bestperf>0)+betavalslong(ubest_lcf_it_bestperf>0))./farelong(ubest_lcf_it_bestperf>0);
            
            orange=[0.8500 0.3250 0.0980,0.6];
            plot(fareincr,max_comp_allowed(fareind),'-','LineWidth',4,'color',orange)
            hold on
            
            %%%plot maximum allowed compensation as a function of the fare
            yellow=[0.9290 0.6940 0.1250,0.8];
            green=[0.4660 0.6740 0.1880,1];
            mincurvey=horzcat(4*ones(1,201),0.8*[5.01:0.01:45]);
            plot([3:0.01:45],mincurvey,'-','LineWidth',4,'color',yellow)
            hold on

            %plot the fare=comp line for reference
            plot([3:0.01:46.85],[3:0.01:46.85],'-','LineWidth',2,'color',green)
               xlabel('Fare (dollars)')
              ylabel('Offer (dollars)')
            title('Compensation Offer to a Driver')
            lg = legend('Offered','Maximum','Minimum','Fare=Comp')
            lg.Location = 'northwest'
            
        elseif metric == 'fa'
        
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% fare vs comp only incl ones assigned in SOL-IT solver 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %construct compensation offers of the returned menu set of every trial
            compinmenu=ubest_lcf_it_bestperf+alphavalslong;
            
            
            %calculate vsim
            vsim_totassign = zeros(m*trials,n); %total number of training (fixed/vari) scenarios in which a driver/requeset pair is assigned in each trial
            vsim_totassign_horiz = zeros(m,n*trials); %rearranged so is same dim as the other data
            for i=1:10
                vsim_totassign = vsim_totassign + vbest_lcf_it_bestperf(:,(i-1)*n+1:i*n);
            end
        
    
            for t = 1:100  
                vsim_totassign_horiz(:,(t-1)*n+1:t*n) = vsim_totassign((t-1)*m+1:t*m,:);
               if guessbestiter_lcf_it_final(1,t) == 0
                   compinmenu(:,(t-1)*n+1:t*n) = slsfcomplong(:,(t-1)*n+1:t*n);
                  
               end
            end
            
            %%% plot comp vs fare of driver-requests pairs offered in menu but never assigned in the training scenarios
            plot(farelong(xbest_lcf_it_bestperf>0 & vsim_totassign_horiz==0),compinmenu(xbest_lcf_it_bestperf>0 & vsim_totassign_horiz==0),'^','MarkerSize',4,'MarkerEdgeColor',blue,'MarkerFaceColor',blue)
            %blue=[0 0.4470 0.7410,0.5];
            hold on
            
            %%% plot comp vs fare of driver-requests pairs assigned in at least one training scenario
            plot(farelong(xbest_lcf_it_bestperf>0 & vsim_totassign_horiz>0),compinmenu(xbest_lcf_it_bestperf>0& vsim_totassign_horiz>0),'.','MarkerSize',15,'color',green)
            hold on
            
            %%% calculate and plot maximum allowed compensation as a function of the fare
            [fareincr,fareind]=sort(farelong(ubest_lcf_it_bestperf>0));
            max_comp_allowed=alphavalslong(ubest_lcf_it_bestperf>0)+betavalslong(ubest_lcf_it_bestperf>0);
            max_comp_allowed2=alphavalslong+betavalslong;
            max_compperc_allowed=(alphavalslong(ubest_lcf_it_bestperf>0)+betavalslong(ubest_lcf_it_bestperf>0))./farelong(ubest_lcf_it_bestperf>0);
            
            orange=[0.8500 0.3250 0.0980,0.6];
            plot(fareincr,max_comp_allowed(fareind),'-','LineWidth',2,'color',orange)
            hold on
            
            %%% calculate and plot maximum allowed compensation as a function of the fare
            yellow=[0.9290 0.6940 0.1250,0.8];
            %green=[0.4660 0.6740 0.1880,1];
            mincurvey=horzcat(4*ones(1,201),0.8*[5.01:0.01:45]);
            plot([3:0.01:45],mincurvey,'--','LineWidth',2,'color',yellow)
            hold on

            %plot the fare+booking fee= comp line for reference
            plot([3:0.01:46.85],[4.85:0.01:48.7],':','LineWidth',3,'color',purple)
            
            xlabel('\sl fare_i \rm ($)')
            ylabel('\sl comp_{ij} \rm ($)')
            title('Compensation Offer vs Fare of Menu Items')
            lg = legend('Offered (not assigned)','Offered (and assigned)','Maximum','Minimum','Fare + Book = Comp')
            lg.Location = 'northwest'
            
            %portion of pairs with mincomp
            size(compinmenu(xbest_lcf_it_bestperf>0 & compinmenu-slsfcomplong<0.01),1)/ size(compinmenu(xbest_lcf_it_bestperf>0),1)
            %portion of pairs with perc <=1
            size(compinmenu(xbest_lcf_it_bestperf>0 & compinmenu./farelong<=1),1)/ size(compinmenu(xbest_lcf_it_bestperf>0),1)
            %portion of pairs with comp > fare+ booking
            size(compinmenu(xbest_lcf_it_bestperf>0 & max_comp_allowed2-compinmenu<=4.99),1)/ size(compinmenu(xbest_lcf_it_bestperf>0),1)
           %portion of pairs with comp > fare+ booking that was assigned
            size(compinmenu(xbest_lcf_it_bestperf>0 & max_comp_allowed2-compinmenu<=5.01 & vsim_totassign_horiz>0),1)/ size(compinmenu(xbest_lcf_it_bestperf>0),1)
            
    elseif metric == 'bc'
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% fare (incl booking fee) vs comp
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %construct compensation offers of the returned menu set of every trial
            compinmenu=ubest_lcf_it_bestperf+alphavalslong;
            for t = 1:100 
               if guessbestiter_lcf_it_final(1,t) == 0
                   compinmenu(:,(t-1)*n+1:t*n) = slsfcomplong(:,(t-1)*n+1:t*n);
               end
            end
            
            %%% plot fare + booking fee vs comp
            blue=[0 0.4470 0.7410,0.5];
            farelong_incl=farelong+1.85*ones(m,n*trials);
            plot(farelong_incl(ubest_lcf_it_bestperf>0),compinmenu(ubest_lcf_it_bestperf>0),'.','MarkerSize',15,'color',blue)
            hold on
            %%% calculate and plot maximum allowed compensation as a function of the fare
            [fareincr,fareind]=sort(farelong_incl(ubest_lcf_it_bestperf>0));
            max_comp_allowed=alphavalslong(ubest_lcf_it_bestperf>0)+betavalslong(ubest_lcf_it_bestperf>0);
            max_compperc_allowed=(alphavalslong(ubest_lcf_it_bestperf>0)+betavalslong(ubest_lcf_it_bestperf>0))./farelong(ubest_lcf_it_bestperf>0);
            
            orange=[0.8500 0.3250 0.0980,0.6];
            plot(fareincr,max_comp_allowed(fareind),'-','LineWidth',4,'color',orange)
            hold on
            
            %%% calculate and plot minimum allowed compensation as a function of the fare
            yellow=[0.9290 0.6940 0.1250,0.8];
            green=[0.4660 0.6740 0.1880,1];
            mincurvey=horzcat(4*ones(1,201),0.8*[5.01:0.01:45]);
            plot([4.85:0.01:46.85],mincurvey,'-','LineWidth',4,'color',yellow)
            hold on
            
            %plot the fare + booking fee= comp line for reference
            plot([4.85:0.01:46.85],[4.85:0.01:46.85],'-','LineWidth',2,'color',green)
            hold on
               xlabel('Fare (dollars)')
              ylabel('Offer (dollars)')
            title('Compensation Offers to Drivers')
            lg = legend('Offered','Maximum','Minimum','Fare + Book=Comp')
            lg.Location = 'northwest'
    elseif metric == 'ei'
        %%%%%%%%%%%%%%%%%%
        %%%% expected driver income
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
       %construct compensation offers of the returned menu set of every trial
        compinmenu = ubest_lcf_it_bestperf + alphavalslong; %slsf comp is calculated separately (i.e. trials where slsf soln is returned)
      
        exp_income_slsf = zeros(1,n*trials); %expected income of initial slsf solutions
        exp_income_lcf = zeros(1,n*trials); %expected income of SOL-IT solutions (including when slsf is returned)
        exp_totalrev_lcf = zeros(1,trials); %total revenue for platform in SOL-IT solutions
        
        %calculate the values
        for t=1:trials
            bestiter = guessbestiter_lcf_it_final(1,t);
           for j=1:n
              for k=1:5000
                     exp_income_slsf(1,(t-1)*n+j) = exp_income_slsf(1,(t-1)*n+j)+sum(testscenprobs_lcf_it_concat(t,k)*testv_lcf_it_concat((t-1)*m+1:t*m,(k-1)*n+j).*slsfcomp_concat(1:m,(t-1)*n+j));
                 
                  if guessbestiter_lcf_it_final(1,t) ~= 0
                      exp_income_lcf(1,(t-1)*n+j) = exp_income_lcf(1,(t-1)*n+j)+sum(testscenprobs_best_lcf_it_bestperf(t,k)*testv_best_lcf_it_bestperf((t-1)*m+1:t*m,(k-1)*n+j).*compinmenu(:,(t-1)*n+j));
                  else
                      %exp_income_lcf(1,(t-1)*n+j)=-1;
                      exp_income_lcf(1,(t-1)*n+j) = exp_income_slsf(1,(t-1)*n+j);
                  end
                  if j ==1
                     exp_totalrev_lcf(1,t) =  exp_totalrev_lcf(1,t) + sum(testscenprobs_best_lcf_it_bestperf(t,k)*(ones(m,1)-testw_best_lcf_it_bestperf((t-1)*m+1:t*m,k)).*(farelong(:,t*m)+1.85*ones(m,1)));        
                  end
              end
           end
        end
        
        %plot results 
        histogram(exp_income_slsf,10)
        hold on
        histogram(exp_income_lcf,10)
        xlabel("A Driver's Expected Income ($)")
        ylabel("Count")
        title("Frequency of Drivers' Expected Incomes")
        legend('SLSF','SOL-IT')
       
        
        mean(exp_income_slsf)
        mean(exp_income_lcf)
        mean(exp_totalrev_lcf-avetotprofit_best_lcf_it_bestperf)/20
        drivers_getting_less = find(exp_income_slsf>exp_income_lcf);
        size(drivers_getting_less)
%     rejfare_lcf = zeros(m*trials,testsamps);
%     rejfare_slsf = zeros(m*trials,testsamps);
%     for t=1:trials
%         for k=1:testsamps
%             rejfare_lcf((t-1)*m+1:t*m,k) = farelong(:,t*m).*testw_best_lcf_it_bestperf((t-1)*m+1:t*m,k);
%             rejfare_slsf((t-1)*m+1:t*m,k) = farelong(:,t*m).*testw_lcf_it_concat((t-1)*m+1:t*m,k);
%         end
%     end
%     rejfare_lcf = rejfare_lcf(:);
%     rejfare_slsf = rejfare_slsf(:);
%     rejfare_lcf = rejfare_lcf(rejfare_lcf>0);
%     rejfare_slsf = rejfare_slsf(rejfare_slsf>0);
%     mean(rejfare_lcf)
%     mean(rejfare_slsf)
%     
    


    elseif metric == 'md' % percent comp  distribution for each menu size
            
            
            menusizes_all = zeros(1,n*trials); %menu size of each driver in each trial
             for t=1:trials                 
                menusizes_all(1,(t-1)*n+1:n*t) = sum(xbest_lcf_it_bestperf(:,(t-1)*n+1:t*n),1);
             end
             tabulate(menusizes_all)
             
             menusizes_big = repmat(menusizes_all,m,1); 
             
             %construct compensation offers of the returned menu set of every trial
             compinmenu=ubest_lcf_it_bestperf+alphavalslong;
             for t = 1:100 
               if guessbestiter_lcf_it_final(1,t) == 0
                   compinmenu(:,(t-1)*n+1:t*n) = slsfcomplong(:,(t-1)*n+1:t*n);
               end
            end
             colors=[blue;green;yellow;orange;red];
            symbols=[':o ';'-^ ';'--+';'-.d';' -x']; 
             
            %calculate % comp (comp/fare) distribution for each menu size
             for menusize = 1:5
                 %min(min(compinmenu(ubest_lcf_it_bestperf>0 & menusizes_big == menusize)./farelong(ubest_lcf_it_bestperf>0 & menusizes_big == menusize)))
                 bincounts0 = histc(compinmenu(xbest_lcf_it_bestperf>0 & menusizes_big == menusize)./farelong(xbest_lcf_it_bestperf>0 & menusizes_big == menusize),0.799:0.1:1.999)
                 if menusize == 1
                     tabulate(compinmenu(xbest_lcf_it_bestperf>0 & menusizes_big == menusize)./farelong(xbest_lcf_it_bestperf>0 & menusizes_big == menusize))
                 end
                 bincounts0=bincounts0/sum(bincounts0);
                 plot(0.8:0.1:2,bincounts0,symbols(menusize,:),'color',colors(menusize,:),'LineWidth',2);
                % histogram(compinmenu(ubest_lcf_it_bestperf>0 & menusizes_big == menusize)./farelong(ubest_lcf_it_bestperf>0 & menusizes_big == menusize))
               hold on
             end
 
           
        xlabel("Compensation Percent for Given Menu Size")
        ylabel("Probability")
        title("Compensation Percent Distribution for Each Menu Size")
        legend('Menu Size = 1','Menu Size = 2','Menu Size = 3','Menu Size = 4','Menu Size = 5')
            
    elseif metric == 'cd' %distribution of the % compensation (comp/fare)
               menusizes_all = zeros(1,n*trials);
             for t=1:trials                 
                menusizes_all(1,(t-1)*n+1:n*t) = sum(xbest_lcf_it_bestperf(:,(t-1)*n+1:t*n),1);
             end
           
             totaloffers = sum(menusizes_all)
             
             %construct compensation offers of the returned menu set of every trial
             compinmenu=ubest_lcf_it_bestperf+alphavalslong;
             for t = 1:100 
               if guessbestiter_lcf_it_final(1,t) == 0
                   compinmenu(:,(t-1)*n+1:t*n) = slsfcomplong(:,(t-1)*n+1:t*n);
               end
            end
            %calculate portion of offers with 80% (minimum) comp  
            bincounts0 = histc(compinmenu(xbest_lcf_it_bestperf>0)./farelong(xbest_lcf_it_bestperf>0),0.799:0.002:0.801)
               bincounts0/totaloffers 
             
                 %min(min(compinmenu(ubest_lcf_it_bestperf>0 & menusizes_big == menusize)./farelong(ubest_lcf_it_bestperf>0 & menusizes_big == menusize)))
                 histogram(compinmenu(xbest_lcf_it_bestperf>0)./farelong(xbest_lcf_it_bestperf>0))
%                  bincounts0=bincounts0/sum(bincounts0);
%                  plot(0.8:0.1:2,bincounts0,symbols(menusize,:),'color',colors(menusize,:),'LineWidth',2);
                % histogram(compinmenu(ubest_lcf_it_bestperf>0 & menusizes_big == menusize)./farelong(ubest_lcf_it_bestperf>0 & menusizes_big == menusize))
               hold on
             
 
           
        xlabel("Percent Compensation")
        ylabel("Probability")
        title("Percent Compensation Distribution")
        %legend('Menu Size = 1','Menu Size = 2','Menu Size = 3','Menu Size = 4','Menu Size = 5')
        
        
    elseif metric == 'cp' %comp % vs ``pij
        %ptruebest_lcf_it_bestperf = ptruebest_lcf_it_noperf;
        %ubest_lcf_it_bestperf = ubest_lcf_it_noperf;
        %xbest_lcf_it_bestperf = xbest_lcf_it_noperf;
        
        %construct compensation offers of the returned menu set of every trial
        compinmenu=ubest_lcf_it_bestperf+alphavalslong;
             for t = 1:100 
               if guessbestiter_lcf_it_final(1,t) == 0
                   compinmenu(:,(t-1)*n+1:t*n) = slsfcomplong(:,(t-1)*n+1:t*n);
               end
             end
             
             
        
        pbest_is_multiple_total = 0; %keep track of how many offeres are on the 0.1333 multiple
        pbest_offmultiple = pbest_lcf_it_bestperf; %is pbest but with any pij that are a multiple of 0.1333 are set to 0
        vsim_totassign = zeros(m*trials,n); %is the number of training scenarios each driver-request pair is assigned to 
        vsim_totassign_horiz = zeros(m,n*trials); %rearranged so is same dim as the other data
        
        %calculate/store the values
        for i=1:10
            vsim_totassign = vsim_totassign + vbest_lcf_it_bestperf(:,(i-1)*n+1:i*n);
        end
        
        for t=1:100
            vsim_totassign_horiz(:,(t-1)*n+1:t*n) = vsim_totassign((t-1)*m+1:t*m,:);
            for i = 1:m
                for j = 1:n
                    for k=1:10
                       if  pbest_lcf_it_bestperf(i,(t-1)*n+j)<0.133333333*k +0.001
                           if pbest_lcf_it_bestperf(i,(t-1)*n+j)>0.1333333333*k 
                               pbest_offmultiple(i,(t-1)*n+j) = 0;
                           end
                       end
                    end
                end
            end
        end
        hold on
        figure('Renderer', 'painters', 'Position', [500 100 700 500])
        %figure('Renderer', 'painters', 'Position', [300 300 500 330])
         color1 = [0.8,0.1,0.7,0.3]
       
      %plot the multiples of 0.13333 lines   
      x = [0.8:0.001:1.3];
      mult = 1;
      y = ones(size(x))*mult*4/30
      m1 = plot(x,y,'color',color1,'LineWidth',6)
      hold on
      
      x =[0.8:0.001:1.7];
      mult = 2;
      y = ones(size(x))*mult*4/30
      m2 = plot(x,y,'color',color1,'LineWidth',6)
      hold on
      
      x =[0.8:0.001:2];
      mult = 3;
      y = ones(size(x))*mult*4/30
      m3 = plot(x,y,'color',color1,'LineWidth',6)
      hold on
      
      x =[0.8:0.001:2];
      mult = 4;
      y = ones(size(x))*mult*4/30
     m4 = plot(x,y,'color',color1,'LineWidth',6)
      hold on
      
      x =[0.8:0.001:1.8];
      mult = 5;
      y = ones(size(x))*mult*4/30
      m5 = plot(x,y,'color',color1,'LineWidth',6)
      hold on
      
      x =[0.8:0.001:1.8];
      mult = 6;
      y = ones(size(x))*mult*4/30
      m6 = plot(x,y,'color',color1,'LineWidth',6)
      hold on
      
       x =[0.8:0.001:1.8];
      mult = 7;
      y = ones(size(x))*mult*4/30
      m7 = plot(x,y,'color',color1,'LineWidth',6)
      hold on
      
       x =[0.83:0.001:1.6];
      mult = 8;
      y = ones(size(x))*mult*4/30
      m8 = plot(x,y,'color',color1,'LineWidth',6)
      hold on
      
       x =[0.9:0.001:1.5];
      mult = 9;
      y = ones(size(x))*mult*4/30
      m9 = plot(x,y,'color',color1,'LineWidth',6)
      hold on
      
       x =[0.97:0.001:1];
      mult = 10;
      y = ones(size(x))*mult*4/30
      m10 = plot(x,y,'color',color1,'LineWidth',6)
      hold on
      
      %makes it so only the first 0.13333 line is in the legend
      %set(get(get(m1,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      set(get(get(m2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      set(get(get(m3,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      set(get(get(m4,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      set(get(get(m5,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      set(get(get(m6,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      set(get(get(m7,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      set(get(get(m8,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      set(get(get(m9,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      set(get(get(m10,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        
        %scatter(compinmenu(xbest_lcf_it_bestperf>0 & pbest_lcf_it_bestperf<2 )./farelong(xbest_lcf_it_bestperf>0 & pbest_lcf_it_bestperf<2),pbest_lcf_it_bestperf(xbest_lcf_it_bestperf>0 & pbest_lcf_it_bestperf<2));
       % hold on
        
        p1 = scatter(compinmenu(xbest_lcf_it_bestperf>0 & pbest_lcf_it_bestperf<2 & vsim_totassign_horiz == 0 )./farelong(xbest_lcf_it_bestperf>0 & pbest_lcf_it_bestperf<2 & vsim_totassign_horiz == 0),pbest_lcf_it_bestperf(xbest_lcf_it_bestperf>0 & pbest_lcf_it_bestperf<2 & vsim_totassign_horiz == 0),60,'p');
        p1.MarkerFaceColor = yellow
        p1.MarkerEdgeColor = yellow
        hold on 
%         p2 = scatter(compinmenu(xbest_lcf_it_bestperf>0 & pbest_lcf_it_bestperf<2 & compinmenu<5 )./farelong(xbest_lcf_it_bestperf>0 & pbest_lcf_it_bestperf<2 & compinmenu<5),pbest_lcf_it_bestperf(xbest_lcf_it_bestperf>0 & pbest_lcf_it_bestperf<2 & compinmenu<5),'o');
        p2 = scatter(compinmenu(xbest_lcf_it_bestperf>0 & pbest_lcf_it_bestperf<2 & farelong<5 )./farelong(xbest_lcf_it_bestperf>0 & pbest_lcf_it_bestperf<2 & farelong<5),pbest_lcf_it_bestperf(xbest_lcf_it_bestperf>0 & pbest_lcf_it_bestperf<2 & farelong<5),60,'o');
       
        p2.MarkerEdgeColor = green
         hold on 
        p3 = scatter(compinmenu(xbest_lcf_it_bestperf>0 & pbest_lcf_it_bestperf<2 & pbest_offmultiple==0 )./farelong(xbest_lcf_it_bestperf>0 & pbest_lcf_it_bestperf<2 & pbest_offmultiple==0),pbest_lcf_it_bestperf(xbest_lcf_it_bestperf>0 & pbest_lcf_it_bestperf<2 & pbest_offmultiple==0),60,'.');
       p3.MarkerFaceColor = blue
        p3.MarkerEdgeColor = blue
        
        
        
        
         lg = legend('$\mathsf{Multiple}$ $\mathsf{of}$ $0.1\bar{3}$','$\mathsf{Not}$ $\mathsf{assigned}$','$\mathsf{Fare}$ $<\$5$','\sl $\ddot{p}_{ij}$ $\mathsf{on}$ $\mathsf{multiple}$','Interpreter','latex','FontSize',20);
         xlabel("\sl $comp_{ij} / fare_i$",'Interpreter','latex','FontSize',20)
        ylabel("\sl $\ddot{p}_{ij}$",'Interpreter','latex','FontSize',20)
        title("  $\mathsf{Compensation}$  $\mathsf{Level}$ $\mathsf{(in}$ $\mathsf{Menu)}$ $\mathsf{vs}$  $\ddot{p}_{ij}$",'Interpreter','latex','FontSize',20)
         lg.Location = 'east'
         
         %%%%%%%% this part is used to figure out that all of the offers
         %%%%%%%% made are on a 0.13333 line, the fare is < $5, or the
         %%%%%%%% driver-request pair wasn't assigned in a training
         %%%%%%%% scenario
        %number of offered requests not assigned 
        size(vsim_totassign_horiz(vsim_totassign_horiz == 0 & xbest_lcf_it_bestperf>0))
        
        %number of offered requests off multiple, >80%, but not assigned in
        %lcf best soln
        size(compinmenu(xbest_lcf_it_bestperf>0 & compinmenu./farelong>0.8 & pbest_offmultiple>0 & vsim_totassign_horiz == 0 ))
        %size(compinmenu(xbest_lcf_it_bestperf>0  & pbest_offmultiple>0 & vsim_totassign_horiz == 0 ))
        compinmenu_offmultiple = compinmenu(xbest_lcf_it_bestperf>0 & compinmenu./farelong>0.8 & pbest_offmultiple>0);
        fare_offmultiple = farelong(xbest_lcf_it_bestperf>0 & compinmenu./farelong>0.8 & pbest_offmultiple>0);
%         size(compinmenu_offmultiple)
%         size(compinmenu_offmultiple(compinmenu_offmultiple<5),1)/size(compinmenu_offmultiple,1)
        size(fare_offmultiple)
        size(fare_offmultiple(fare_offmultiple<5),1)/size(fare_offmultiple,1)
        for i =1:10 %for each multiple of 0.133
            pbest_is_multiple_total = pbest_is_multiple_total +size(pbest_lcf_it_bestperf(xbest_lcf_it_bestperf>0 & pbest_lcf_it_bestperf>0.133*i & pbest_lcf_it_bestperf<0.134*i & compinmenu./farelong>0.8),1);
        end
        
        %portion of requests with >80% with pij = a multiple of 0.1333
        pbest_is_multiple_total/size(pbest_lcf_it_bestperf(xbest_lcf_it_bestperf>0 & compinmenu./farelong>0.8),1)
        
        %portion of requests with >80% comp that have pij>0.5
       size(pbest_lcf_it_bestperf(xbest_lcf_it_bestperf>0 & compinmenu>slsfcomplong & pbest_lcf_it_bestperf>0.1334*4),1)/size(pbest_lcf_it_bestperf(xbest_lcf_it_bestperf>0 & compinmenu>slsfcomplong),1)
   
    elseif metric == 'cb' %comp % vs baseline pij (yprobs)
        %ptruebest_lcf_it_bestperf = ptruebest_lcf_it_noperf;
        %ubest_lcf_it_bestperf = ubest_lcf_it_noperf;
        %xbest_lcf_it_bestperf = xbest_lcf_it_noperf;
        
        %construct compensation offers of the returned menu set of every trial
        compinmenu=ubest_lcf_it_bestperf+alphavalslong;
             for t = 1:100 
               if guessbestiter_lcf_it_final(1,t) == 0
                   compinmenu(:,(t-1)*n+1:t*n) = slsfcomplong(:,(t-1)*n+1:t*n);
               end
             end
             
             
        
        pbest_is_multiple_total = 0; %keeps track of how many offers are on a multiple of 0.133333
        pbest_offmultiple = pbest_lcf_it_bestperf; %is pbest with any pij that are a multiple of 0.1333 are set to 0
        vsim_totassign = zeros(m*trials,n); %is the number of training scenarios each driver-request pair is assigned to 
        vsim_totassign_horiz = zeros(m,n*trials); %rearranged so is same dim as the other data
        
        %calculate the values
        for i=1:10
            vsim_totassign = vsim_totassign + vbest_lcf_it_bestperf(:,(i-1)*n+1:i*n);
        end
        
        for t=1:100
            vsim_totassign_horiz(:,(t-1)*n+1:t*n) = vsim_totassign((t-1)*m+1:t*m,:);
            for i = 1:m
                for j = 1:n
                    for k=1:10
                       if  pbest_lcf_it_bestperf(i,(t-1)*n+j)<0.133333333*k +0.001
                           if pbest_lcf_it_bestperf(i,(t-1)*n+j)>0.1333333333*k 
                               pbest_offmultiple(i,(t-1)*n+j) = 0;
                           end
                       end
                    end
                end
            end
        end
%         scatter(compinmenu(xbest_lcf_it_bestperf>0)./farelong(xbest_lcf_it_bestperf>0 ),yprobslong(xbest_lcf_it_bestperf>0 ));
%        %size(compinmenu(xbest_lcf_it_bestperf>0 & vsim_totassign_horiz ~= 0 & compinmenu>5 &  pbest_offmultiple>=0)
%         hold on
       color1 = [0.8,0.1,0.7,0.3]
       figure('Renderer', 'painters', 'Position', [500 100 700 500])
       %figure('Renderer', 'painters', 'Position', [300 300 500 330])
       
       
       %plot the curves representing what compensation has to be paid to
       %get ''pij on a 0.13333 multiple
      x = [0.8:0.001:0.96];
      mult = 1;
      y = (0.8*(15*4/30*mult +10)*ones(size(x))./x-10*ones(size(x)))/15;
      m1 = plot(x,y,'color',color1,'LineWidth',6)
      hold on
      
      x =[0.8:0.001:1.12];
      mult = 2;
      y = (0.8*(15*4/30*mult +10)*ones(size(x))./x-10*ones(size(x))) /15;
      m2 = plot(x,y,'color',color1,'LineWidth',6)
      hold on
      
      x =[0.8:0.001:1.28];
      mult = 3;
      y = (0.8*(15*4/30*mult +10)*ones(size(x))./x-10*ones(size(x)))/15;
      m3 = plot(x,y,'color',color1,'LineWidth',6)
      hold on
      
      x =[0.8:0.001:1.44];
      mult = 4;
      y = (0.8*(15*4/30*mult +10)*ones(size(x))./x-10*ones(size(x)))/15;
     m4 = plot(x,y,'color',color1,'LineWidth',6)
      hold on
      
      x =[0.8:0.001:1.6];
      mult = 5;
      y = (0.8*(15*4/30*mult +10)*ones(size(x))./x-10*ones(size(x)))/15;
      m5 = plot(x,y,'color',color1,'LineWidth',6)
      hold on
      
      x =[0.8:0.001:1.76];
      mult = 6;
      y = (0.8*(15*4/30*mult +10)*ones(size(x))./x-10*ones(size(x)))/15;
      m6 = plot(x,y,'color',color1,'LineWidth',6)
      hold on
      
       x =[0.8:0.001:1.76];
      mult = 7;
      y = (0.8*(15*4/30*mult +10)*ones(size(x))./x-10*ones(size(x)))/15;
      m7 = plot(x,y,'color',color1,'LineWidth',6)
      hold on
      
       x =[0.83:0.001:1.76];
      mult = 8;
      y = (0.8*(15*4/30*mult +10)*ones(size(x))./x-10*ones(size(x)))/15;
      m8 = plot(x,y,'color',color1,'LineWidth',6)
      hold on
      
       x =[0.9:0.001:1.8];
      mult = 9;
      y = (0.8*(15*4/30*mult +10)*ones(size(x))./x-10*ones(size(x)))/15;
      m9 = plot(x,y,'color',color1,'LineWidth',6)
      hold on
      
       x =[0.97:0.001:1.9];
      mult = 10;
      y = (0.8*(15*4/30*mult +10)*ones(size(x))./x-10*ones(size(x)))/15;
      m10 = plot(x,y,'color',color1,'LineWidth',6)
      hold on
      
      %%% this makes it so only the first of the 0.1333 multiple curves is
      %%% on the legend
      %set(get(get(m1,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      set(get(get(m2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      set(get(get(m3,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      set(get(get(m4,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      set(get(get(m5,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      set(get(get(m6,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      set(get(get(m7,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      set(get(get(m8,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      set(get(get(m9,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      set(get(get(m10,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
      
      %plot the other parts of the graph
        p1 = scatter(compinmenu(xbest_lcf_it_bestperf>0 & vsim_totassign_horiz == 0 )./farelong(xbest_lcf_it_bestperf>0 & vsim_totassign_horiz == 0),yprobslong(xbest_lcf_it_bestperf>0 & vsim_totassign_horiz == 0),60,'p');
        p1.MarkerFaceColor = yellow
        p1.MarkerEdgeColor = yellow
        hold on 
         p2 = scatter(compinmenu(xbest_lcf_it_bestperf>0 & farelong<5 )./farelong(xbest_lcf_it_bestperf>0  & farelong<5),yprobslong(xbest_lcf_it_bestperf>0 & farelong<5),60,'o');
      hold on
       %p2.MarkerFaceColor = green
        p2.MarkerEdgeColor = green
        p3 = scatter(compinmenu(xbest_lcf_it_bestperf>0 & pbest_offmultiple==0 )./farelong(xbest_lcf_it_bestperf>0  & pbest_offmultiple==0),yprobslong(xbest_lcf_it_bestperf>0 & pbest_offmultiple==0),60,'.');
         hold on 
          p3.MarkerFaceColor = blue
        p3.MarkerEdgeColor = blue
         
            xlabel("\sl $comp_{ij} / fare_i$",'Interpreter','latex','FontSize',20)
        ylabel("$\mathsf{Initial}$ \sl $p_{ij}$",'Interpreter','latex','FontSize',20)
       % title("Percent Compensation (in Menu) vs Initial \sl  p_{ij}")
       lg = legend('$0.1\bar{3}$ $\mathsf{multiple}$ $\mathsf{curve}$ ','$\mathsf{Not}$ $\mathsf{assigned}$','$\mathsf{Fare}$ $<\$5$','\sl $\ddot{p}_{ij}$ $\mathsf{on}$ $\mathsf{multiple}$','Interpreter','latex','FontSize',18);

        title("   $\mathsf{Compensation}$ $\mathsf{Level}$ $\mathsf{(in}$ $\mathsf{Menu)}$ $\mathsf{vs}$ $\mathsf{Initial}$  ${p}_{ij}$",'Interpreter','latex','FontSize',20)
         lg.Location = 'east'
        
        ylim([0 1])
     xlim([0.8 2.8])
      
    
%     a=0.10921;
%     b = 0.13333;
%     newcomp = 0.962359
%     %(15*b+10)/(15*a+10)/0.8
%     fareoverextra = (15*a+10)/0.8;
%     newpij = (newcomp*fareoverextra -10)/15
    
    
    end %metric 
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% iteration insights %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif category == 'i'
    
    if metric == 'mo'
       %%% menu overlap between each iteration and the next 
          menu_overlap_big = zeros(m*(iters-1),n*trials);
          menusizes_big = zeros(iters,trials); %average menu size of each problem instance in each iteration
          menu_overlap_percent = zeros(iters-1,trials); %percent that a new menu overlaps with the menu of the previous iteration
           menu_overlap_big_slsf = zeros(m*(iters-1),n*trials); %each iter compared to slsf
          menu_overlap_percent_slsf = zeros(iters-1,trials);
          menu_overlap_big_final = xbest_lcf_it_bestperf.*x_lcf_it_concat(1:m,:); %final soln compared to slsf
          menu_overlap_percent_final = zeros(1,trials); 
          menu_total = x_lcf_it_concat(1:m,:); %like ave assign, counts how many iter's menu each pair is in
          all10_menu_portions = zeros(iters,trials); %calculates what portion of each menu are items offered in all 10 iters
          
          %calculate the values
          for i = 1:iters-1
              menu_overlap_big((i-1)*m+1:i*m,:) = x_lcf_it_concat((i-1)*m+1:i*m,:).*x_lcf_it_concat(i*m+1:(i+1)*m,:);
              menu_overlap_big_slsf((i-1)*m+1:i*m,:) = x_lcf_it_concat(1:m,:).*x_lcf_it_concat(i*m+1:(i+1)*m,:);
              menu_total = menu_total + x_lcf_it_concat(i*m+1:(i+1)*m,:);
              for t = 1:trials
                 menusizes_big(i,t) = sum(sum(x_lcf_it_concat((i-1)*m+1:i*m,(t-1)*n+1:t*n)))/n;
                 if i == iters-1
                     menusizes_big(iters,t) = sum(sum(x_lcf_it_concat((iters-1)*m+1:iters*m,(t-1)*n+1:t*n)))/n;
                 end
                 menu_overlap_percent(i,t) = sum(sum(menu_overlap_big((i-1)*m+1:i*m,(t-1)*n+1:t*n)))/sum(sum(x_lcf_it_concat((i-1)*m+1:i*m,(t-1)*n+1:t*n))); 
                  menu_overlap_percent_slsf(i,t) = sum(sum(menu_overlap_big((i-1)*m+1:i*m,(t-1)*n+1:t*n)))/sum(sum(x_lcf_it_concat(1:m,(t-1)*n+1:t*n))); 
                if i == 1
                      menu_overlap_percent_final(1,t) = sum(sum(menu_overlap_big_final(:,(t-1)*n+1:t*n)))/sum(sum(x_lcf_it_concat(1:m,(t-1)*n+1:t*n))); 
               
                end
              end
          end
          
          for t=1:trials
             num_all10 = size(find(menu_total(:,(t-1)*n+1:t*n)==10),1);
             all10_menu_portions(:,t) = repmat(num_all10,10,1)./menusizes_big(:,t)/n;
          end
          
%           hist(menu_total(menu_total>0))
%           menu_total_long = menu_total(:);
%           tabulate(menu_total_long(menu_total_long>0))
%           tabulate(menu_total_long)
          %hist(menu_total(:))
          %menu_overlap_percent
%           menu_overlap_avepercent = mean(menu_overlap_percent,2)
%           menu_overlap_avepercent_slsf = mean(menu_overlap_percent_slsf,2)
            mean(mean(menu_overlap_percent))
           mean(mean(menu_overlap_percent_slsf))
%           mean(menu_overlap_percent_final)
           mean(menu_overlap_percent_final(guessbestiter_lcf_it_final > 0))
%           mean(menu_overlap_avepercent)
%           mean(mean(yprobslong(menu_total == 10)))
%           mean(mean(yprobslong(menu_total == 9)))
%           mean(menusizes_big,2)
%           mean(mean(all10_menu_portions))
     
          
          
          
    elseif metric == 'ta'
        %calculates which iterations had correct minitest results, and
        %compare best solns to returned solns (absolute error and %)
        minitest_accuracy = zeros(iters,trials);
        [bestobj_true,bestiter_true] = max(testobjave_lcf_it_concat);
        [worstobj_true,worstiter_true] = min(testobjave_lcf_it_concat);
        solngap_abs = max(testobjave_lcf_it_concat)-testobjave_best_lcf_it_bestperf
        nnz(solngap_abs) %how often the wrong soln was returned
        solngap_perc = (max(testobjave_lcf_it_concat)-testobjave_best_lcf_it_bestperf)./max(testobjave_lcf_it_concat)
        solngap_perc_worse = (max(testobjave_lcf_it_concat)-min(testobjave_lcf_it_concat))./max(testobjave_lcf_it_concat)
       
        guessbestiter_history_with0 = vertcat(zeros(1,trials),guessbestiter_history);
        
        for t = 1:trials
            
            for i=1:iters
                newishigher_temp = 0;
                %check if the next iteration has better soln
                if testobjave_lcf_it_concat(guessbestiter_history_with0(i,t)+1,t) < testobjave_lcf_it_concat(i+1,t)
                    newishigher_temp = 1;
                end
                %record accuracy
                if newishigher_temp == guessbestiter_changes(i,t)
                    minitest_accuracy(i,t) = 1;
                end                  
            end     
        end
      minitest_accuracy;
      mean(solngap_abs)
      mean(solngap_perc)
       mean(solngap_perc_worse)
      nnz(solngap_abs)
      nnz(minitest_accuracy)/trials/iters
      nnz(bestiter_true-ones(1,trials))
%        t=57;
%     bestiter = guessbestiter_lcf_it_final(1,t)
%     nnz(xbest_lcf_it_bestperf(:,(t-1)*n+1:t*n)-x_lcf_it_concat((bestiter-1)*m+1:(bestiter)*m,(t-1)*n+1:t*n))
%     nnz(ubest_lcf_it_bestperf(:,(t-1)*n+1:t*n)-u_lcf_it_concat((bestiter-1)*m+1:(bestiter)*m,(t-1)*n+1:t*n))
%     nnz(testv_best_lcf_it_bestperf((t-1)*m+1:t*m,:)-testv_lcf_it_concat(bestiter*m*trials+ (t-1)*m+1:bestiter*m*trials+t*m,:))
%             

        
    
     elseif metric == 'cf' %coin flip best soln    
    bestiter_coinflip = zeros(1,trials); %what the returned soln is using coin flip
    testobjave_coinflip = testobjave_lcf_it_concat(1,:);
    
    %do the 'coin flips' and save the solution results
    for iter = 1:10
        flips = round(rand(1,trials)); % the flip values
        for t = 1:trials
            if flips(1,t) == 1
                bestiter_coinflip(1,t) = iter;
                testobjave_coinflip(1,t) = testobjave_lcf_it_concat(iter+1,t);
            end
        end
    end
    mean(testobjave_coinflip)
    mean(testobjave_best_lcf_it_bestperf)
     (mean(testobjave_best_lcf_it_bestperf)-mean(testobjave_coinflip))/ mean(testobjave_best_lcf_it_bestperf)
   
     
     elseif metric == 'rs' %random iter best soln  
    bestiter_rand = randi([0 10],1,trials); %the returned iteration picking randomly
    testobjave_rand = testobjave_lcf_it_concat(1,:);

    for t = 1:trials
            testobjave_rand(1,t) = testobjave_lcf_it_concat(bestiter_rand(1,t)+1,t);
    end
    
    mean(testobjave_rand)
    mean(testobjave_best_lcf_it_bestperf)
     (mean(testobjave_best_lcf_it_bestperf)-mean(testobjave_rand))/ mean(testobjave_best_lcf_it_bestperf)
    
    elseif metric == 'si' %soln improvement with each iteration
        guessbest_obj_history = zeros(11, trials);
        truebest_obj_history = zeros(11, trials);
        %percent improvement of iteration i soln vs i-1 soln
        improvement_vs_prev = zeros(10, trials);
        %percent improvement of iteration i soln vs true best soln as of i-1 
        improvement_vs_truebest = zeros(10, trials);
         %percent improvement of iteration i soln vs guessed best soln as of i-1 
        improvement_vs_bestguess = zeros(10, trials);
         %percent improvement of iteration i true best vs true best soln as of i-1 
        improvement_vs_truebest_true = zeros(10, trials);
         %percent improvement of guessed iter i soln vs guessed best soln as of i-1 
        improvement_vs_bestguess_mini = zeros(10, trials);
        for i=1:10
            for t = 1:100
                improvement_vs_prev(i,t) = (testobjave_lcf_it_concat(i+1,t) - testobjave_lcf_it_concat(i,t))/testobjave_lcf_it_concat(i,t);
                improvement_vs_truebest(i,t) = (testobjave_lcf_it_concat(i+1,t) - max(testobjave_lcf_it_concat(1:i,t)))/max(testobjave_lcf_it_concat(1:i,t));
                improvement_vs_bestguess(i,t) = (testobjave_lcf_it_concat(i+1,t) - testobjave_lcf_it_concat(guessbestiter_history_with0(i,t)+1,t))/testobjave_lcf_it_concat(guessbestiter_history_with0(i,t)+1,t);
                 improvement_vs_truebest_true(i,t) = (max(testobjave_lcf_it_concat(1:i+1,t)) - max(testobjave_lcf_it_concat(1:i,t)))/max(testobjave_lcf_it_concat(1:i,t));
                improvement_vs_bestguess_mini(i,t) = (testobjave_lcf_it_concat(guessbestiter_history_with0(i+1,t)+1,t) - testobjave_lcf_it_concat(guessbestiter_history_with0(i,t)+1,t))/testobjave_lcf_it_concat(guessbestiter_history_with0(i,t)+1,t);
            end
        end
      
        mean(improvement_vs_prev,2)
        mean(improvement_vs_truebest,2)
        mean(improvement_vs_bestguess,2)
        mean(improvement_vs_truebest_true,2)
        mean(improvement_vs_bestguess_mini,2)
        all_improves = horzcat( mean(improvement_vs_prev,2),...
        mean(improvement_vs_bestguess,2),... 
            mean(improvement_vs_truebest,2),...
       mean(improvement_vs_bestguess_mini,2),...
         mean(improvement_vs_truebest_true,2))
        
        
        %%% histogram and average for found best and true best iter
        %      histogram(guessbestiter_lcf_it_final)
        %         hold on
        %         histogram(bestiter_true-ones(1,trials))
        %         xlabel("Iteration")
        %         ylabel("Count")
        %         title("Frequency of Best Iteration Iter")
        %         legend('Found Best','True Best')
        %         mean(guessbestiter_lcf_it_final)
        %         mean(bestiter_true-ones(1,trials))
     
     
     
    end %%end for metric for iter
    
    
    
    
    
    
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% other insights %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif category == 'o'    
    
    if metric == 'ms'
          %%% menu sizes for all returned menus, menus only from lcf (i.e.
          %%% don't count when opt soln is slsf), and menus only including
          %%% items with positive pij
             menusizes_all = zeros(1,n*trials);
             menusizes_slsf = zeros(1,n*trials); %of initial slsf solns
            menusizes_noslsf = zeros(1,n*trials); %menu sizes of SOL-IT solns not counting when slsf is returned
            menusizes_posp = zeros(1,n*trials); %used to check if any menu items are offered with pij=0
            xbest_withposp = ceil(xbest_lcf_it_bestperf.*ptruebest_lcf_it_bestperf); %used to check if any menu items are offered with pij=0
            
            %calculate/save the values
            for t=1:trials
                 menusizes_slsf(1,(t-1)*n+1:n*t) = sum(x_lcf_it_concat(1:m,(t-1)*n+1:t*n),1);
                menusizes_all(1,(t-1)*n+1:n*t) = sum(xbest_lcf_it_bestperf(:,(t-1)*n+1:t*n),1);
                menusizes_posp(1,(t-1)*n+1:n*t) = sum(xbest_withposp(:,(t-1)*n+1:t*n),1);
                if guessbestiter_lcf_it_final(1,t) == 0
                    menusizes_noslsf(1,(t-1)*n+1:n*t)= -1*ones(1,n);      
                else
                    menusizes_noslsf(1,(t-1)*n+1:n*t)=sum(xbest_lcf_it_bestperf(:,(t-1)*n+1:t*n),1);
                   
                end
       
            end
            
            %print results
            mean(menusizes_slsf)
            mean(menusizes_all)
            mean(menusizes_noslsf(menusizes_noslsf>-1))
            mean(menusizes_posp)
            tabulate(menusizes_slsf)
            tabulate(menusizes_all)
            tabulate(menusizes_noslsf)
            tabulate(menusizes_posp)
            %significance test that lcf menu size > slsf
            diffs = menusizes_all-menusizes_slsf;
         [h,p] = ttest(diffs,0,'Tail','right')
            
    elseif metric == 'pd'
        %distribution of the pij for menu items for slsf and SOL-IT
        slsfmenu_vector = x_lcf_it_concat(1:m,:); %the menu(s) as a vector
        slsfmenu_vector = slsfmenu_vector(:);
        
        lcfmenu_vector = xbest_lcf_it_bestperf(:);%the menu(s) as a vector
        slsfpij_inmenu = yprobslong(:);
        
        slsfpij_inmenu = slsfpij_inmenu(slsfmenu_vector>0);
        lcfpij_inmenu = ptruebest_lcf_it_bestperf(:);
        lcfpij_inmenu = lcfpij_inmenu(lcfmenu_vector>0);
        
        %hist(slsfpij_inmenu)
        %hist(lcfpij_inmenu)
        pij_assigned_slsf = testv_lcf_it_concat(1:m*trials,:);
        pij_assigned_lcf = vertcat(testv_best_lcf_it_bestperf,testv_lcf_it_concat(99*m+1:100*m,:));
        testv_shorthand = vertcat(testv_best_lcf_it_bestperf,testv_lcf_it_concat(99*m+1:100*m,:));
        totassign_lcf = zeros(m,n*trials); %total number of testscens where each pair is assigned
        totaccept_lcf = zeros(m,n*trials); %total number of testscens where each pair is accepted
         for t = 1: trials
             pij_assigned_slsf((t-1)*m+1:t*n,:) = pij_assigned_slsf((t-1)*m+1:t*m,:).*repmat(yprobslong(:,(t-1)*n+1:t*n),1,testsamps);
             
             pij_assigned_lcf((t-1)*m+1:t*n,:) = pij_assigned_lcf((t-1)*m+1:t*m,:).*repmat(ptruebest_lcf_it_bestperf(:,(t-1)*n+1:t*n),1,testsamps);
            for k=1:testsamps
               totassign_lcf(:,(t-1)*n+1:t*n) = totassign_lcf(:,(t-1)*n+1:t*n) +testv_shorthand((t-1)*m+1:t*m,(k-1)*n+1:k*n);
               totaccept_lcf(:,(t-1)*n+1:t*n) = totaccept_lcf(:,(t-1)*n+1:t*n) +testyhat_best_lcf_it_bestperf((t-1)*m+1:t*m,(k-1)*n+1:k*n);
            end
         end
        pij_assigned_slsf = pij_assigned_slsf(pij_assigned_slsf > 0);
        pij_assigned_lcf = pij_assigned_lcf(pij_assigned_lcf > 0);
        
        size(pij_assigned_slsf(pij_assigned_slsf == 1),1)/size(pij_assigned_slsf,1)
        mean(pij_assigned_slsf)
        size(pij_assigned_lcf(pij_assigned_lcf == 1),1)/size(pij_assigned_lcf,1)
        mean(pij_assigned_lcf)
        
        histogram(slsfpij_inmenu,10)
        hold on
        histogram(lcfpij_inmenu,10)
        hold on
        xlabel("\sl p_{ij}\rm of Driver-Requeset Pair in a Menu")
        ylabel("Count")
        title("\rm Frequency of \sl p_{ij}\rm Values (Offered)")
        lg = legend('SLSF','SOL-IT')
        lg.Location = 'northwest';
       
        
       size(slsfpij_inmenu(slsfpij_inmenu == 1),1)/size(slsfpij_inmenu,1)
        mean(slsfpij_inmenu)
        size(lcfpij_inmenu(lcfpij_inmenu == 1),1)/size(lcfpij_inmenu,1)
        mean(lcfpij_inmenu)
        
           size(pij_assigned_slsf(pij_assigned_slsf >= 0.9),1)/size(pij_assigned_slsf,1)
        size(pij_assigned_lcf(pij_assigned_lcf >= 0.9),1)/size(pij_assigned_lcf,1)
        size(slsfpij_inmenu(slsfpij_inmenu >= 0.9),1)/size(slsfpij_inmenu,1)
        size(lcfpij_inmenu(lcfpij_inmenu >= 0.9),1)/size(lcfpij_inmenu,1)
        assign_accept_fraction_lcf =  totassign_lcf./ totaccept_lcf;
        mean(assign_accept_fraction_lcf(ptruebest_lcf_it_bestperf > 0 & ptruebest_lcf_it_bestperf < 0.2 & totaccept_lcf > 0))
        
%         mean(guessbestiter_lcf_it_final)
%         nnz(guessbestiter_lcf_it_final)
        
    elseif metric == 'pa'
        %distribution of the pij for assigned items for slsf and lcf
        slsfmenu_vector = x_lcf_it_concat(1:m,:);
        slsfmenu_vector = slsfmenu_vector(:);
        lcfmenu_vector = xbest_lcf_it_bestperf(:);
        slsfpij_inmenu = yprobslong(:);
        slsfpij_inmenu = slsfpij_inmenu(slsfmenu_vector>0);
        lcfpij_inmenu = ptruebest_lcf_it_bestperf(:);
        lcfpij_inmenu = lcfpij_inmenu(lcfmenu_vector>0);
        
    
        pij_assigned_slsf = testv_lcf_it_concat(1:m*trials,:);
        %add 100th prob instance v vals (which is slsf) to best v
        pij_assigned_lcf = vertcat(testv_best_lcf_it_bestperf,testv_lcf_it_concat(99*m+1:100*m,:));
         for t = 1: trials
             if guessbestiter_lcf_it_final(1,t)==0
                 pij_assigned_lcf((t-1)*m+1:t*n,:) = testv_lcf_it_concat((t-1)*m+1:t*n,:);
             end
             pij_assigned_slsf((t-1)*m+1:t*n,:) = pij_assigned_slsf((t-1)*m+1:t*m,:).*repmat(yprobslong(:,(t-1)*n+1:t*n),1,testsamps);
             
             pij_assigned_lcf((t-1)*m+1:t*n,:) = pij_assigned_lcf((t-1)*m+1:t*m,:).*repmat(ptruebest_lcf_it_bestperf(:,(t-1)*n+1:t*n),1,testsamps);
         end
%         pij_assigned_slsf = pij_assigned_slsf(pij_assigned_slsf > 0);
%         pij_assigned_lcf = pij_assigned_lcf(pij_assigned_lcf > 0);
     
        
        histogram(pij_assigned_slsf(pij_assigned_slsf >0),10)
        hold on
        histogram(pij_assigned_lcf(pij_assigned_lcf >0),10)
        hold on
%         histogram(slsfpij_inmenu,10)
%         hold on
%         histogram(lcfpij_inmenu,10)
        xlabel("\sl p_{ij}\rm of Assigned Driver-Request Pair ")
        ylabel("Count")
        title("\rm Frequency of \sl p_{ij}\rm Values (Assigned)")
        lg = legend('SLSF','SOL-IT')
        lg.Location = 'northwest';
        
           
        size(pij_assigned_slsf(pij_assigned_slsf == 1),1)/size(pij_assigned_slsf(pij_assigned_slsf >0),1)
        mean(pij_assigned_slsf(pij_assigned_slsf >0))
        size(pij_assigned_lcf(pij_assigned_lcf == 1),1)/size(pij_assigned_lcf(pij_assigned_lcf >0),1)
        mean(pij_assigned_lcf(pij_assigned_lcf >0))
        
%         size(pij_assigned_slsf(pij_assigned_slsf >0),1)
%         size(pij_assigned_lcf(pij_assigned_lcf >0),1)
        
%         mean(guessbestiter_lcf_it_final)
%         nnz(guessbestiter_lcf_it_final)
        
        
    elseif metric == 'ru'
     %%%% runtime info
     mean(sum(runtimes_lcf_it_concat))
     mean(sum(runtimes_mini_concat))
     mean(runtimes_scens_lcfinput)
     mean(sum(runtimes_slsf_concat))
        
        
     
    elseif metric == 'cd' 
        distfromreq = xbest_lcf_it_bestperf.*OjOiminslong;
        hist(distfromreq(distfromreq>0))
        mean(distfromreq(distfromreq>0))
     
     
        
    end
    
    
    
    
    
    
    
    




    
    
    
end
