%[]function=plot_phase3(stage,metric,percent)

%this code is used to make all graphs, data analysis etc of the problem
%instances run for phase 3 (which became phase 4 after adding heuristic
%comparisons as phase 2), that is the menu size experiment, wages
%experiment, and unhappy drivers experiment

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%To make the plots/get analysis numbers, simply adjust the values for experiment, stage, metric, and tall as
%desired and then run the code. The data is loaded in from on of the three
%experiment files (depending on which analysis is to be done: 
%'phase3zeffectw100samps2.mat' for the experiment using no unhappy driver penalties, 'phase3thetaeffectnoloop.mat' 
%for the menu size experiment, and 'phase3wageeffectfixedparams.mat' for the wates experiment. These can be changed to new files if
%desired
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

experiment='w'; %the experiment to run analysis on, make sure it matches the experiment value 9 lines lower. 'z'=unhap driver experiment,
%'t'=menu size (theta) experiment, 'w'=wages experiment
if experiment=='z'
    load('C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_4\phase3zeffectw100samps2.mat');
elseif experiment=='t'
     load('C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_4\phase3thetaeffectnoloop.mat');
elseif experiment=='w'
    load('C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_4\phase3wageeffectfixedparams.mat');    
end
experiment='w';




metric='w'; %%%metric to be analyzed, options for unhap driver experiment (METRIC='z'): 'o' is analysis of the objective value,
%but you must make metric into three letters so that one of four methods is used: the second letter is 'a' if we're looking at 
%the objective 'average' of each instance and is 'i' if we're looking at the objective value of each 'individual' test scenario 
%of each instance. The third letter is 's' to plot the difference in objective performance between using SLSF and SLSF-noZ 
%(i.e. plots one line), while 'b' just plots the objectives of both SLSF and SLSF-noZ. So for example metric='oab'  will plot the
%instance objective values for SLSF and SLSF-noz.  Metric='ms' for menu size but the code is all over the place so I'd skip that one, 
%'z' finds the number of positive z per scenario and number of unhappy drivers per scenario, 'd' calculates the overlap in the SLSF-noZ
%and SLSF menus, 'w' calculates and plots the number of unfullfilled requests.

%%% for the menu size experiment (METRIC='t'): 'o' is analysis of the objective value, but you must make metric into two letters so that
%one of two methods is used: the second letter is 'a' if we're looking at the objective 'average' of each instance and is 'i' if we're
%looking at the objective value of each 'individual' test scenario of each instance. Metric='ms' is menu size, 'd' is menu overlap 
%between different menu sizes, 'yh' is the number of nonzero pij/yhat vs number of requests offered, 'z' is the number of unhappy drivers, 
%'w' calculates and plots the number of unfullfilled requests

%%% for the wages experiment (METRIC='w'): 'o' is analysis of the objective value, but you must make metric into two letters so that one 
%of two methods is used: the second letter is 'a' if we're looking at the objective 'average' of each instance and is 'i' if we're looking
%at the objective value of each 'individual' test scenario of each instance. Metric='ms' is menu size, 'd' is kind of menu overlap but it's
%inactive code, 'yh' is the number of nonzero pij/yhat vs number of requests offered, 'w' is number of unfullfilled requests per scenario, 
%'c' is the expected income of hte platform and drivers, 'p' is the pij distribution of different wages, 'n' is the number of drivers willing 
%to fulfill each request

tall=1; %this alters the dimensions of outputted graphs, was added to allow for slightly skinnier/taller graphs that
%would fit three in the same row in the latex version of the SLSF paper.
%tall=1 for the skinnier graphs, otherwise tall=0



[n,trials]=size(Ojlong);
testsamps=size(testobjlong,2);
percent=1;

%%% decides the size and location in which the graph is made on the screen, first two digits are the (pixel?) coordinates of
    %%% the top left corner, then 3rd and 4th numbers are the (pixel?) width and hieght respectively
%figure('Renderer', 'painters', 'Position', [300 300 600 350])
if tall == 0
    figure('Renderer', 'painters', 'Position', [300 300 400 350])
else
    figure('Renderer', 'painters', 'Position', [300 300 400 250])
end

%%% rgb of some rainbow colors to use in plots
red=[0.6350 0.0780 0.1840];
orange=[0.8500 0.3250 0.0980];
yellow=[0.9290 0.6940 0.1250];
green=[0.4660 0.6740 0.1880];
blue=[0 0.4470 0.7410];
purple=[0.4940 0.1840 0.5560];

%%%%%%%%%%%% z effect %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if experiment=='z'
 

    %%%% obj value
    if metric(1,1)=='o'
        if metric(1,2)=='a' %average objective value of each instance
            objlong
            objlongnoz
            if metric(1,3)=='s' %calculates and plots the difference in objectives between SLSF and SLSF-noZ
            obj=(testobjavelong-testobjavelongnoz)./testobjavelong*100;
            objsorted=sort(obj,'ascend');
     
              plot(1:10,objsorted,'-x','color',blue,'LineWidth',2) 
              hold on
              
              ylabel('% Obj Value Decrease of Instance')
              xlabel('Instance (Sorted by Increasing Performance Change)')

            title('Instance Performance Decrease from Omitting \sl z')
            
            elseif metric(1,3)=='b' %plots the objectives of SLSF and SLSF-noZ
                [objsorted,ind]=sort(testobjavelong,'ascend');
                
                 %objsorted=testobjavelong;

              plot(1:10,objsorted,'k','LineWidth',1.5) 
              hold on
              objsorted=sort(testobjavelongnoz,'ascend');
              %objsorted=testobjavelongnoz;
              objsorted=testobjavelongnoz(ind);

              plot(1:10,objsorted,'--k','LineWidth',1.5) 
              hold on
              ylabel('Instance Test Objective Values')
              xlabel('Instance (Sorted by Increasing Obj Val)')
              lg=legend('SLSF','SLSFnoZ')
              lg.Location='southeast'

            title('Test Objective Values by Instance')
            end
            
        elseif metric(1,2)=='i' %consideres each individual test scenario's objective
            if metric(1,3)=='s' %calculates and plots the difference in objectives between SLSF and SLSF-noZ
                obj=(testobjlong-testobjlongnoz)./testobjlong*100;
                objsorted=sort(obj(:),'ascend');

                    plot(1:50000,objsorted,'-','color',blue,'LineWidth',2) 
                  hold on
                   plot(1:50000,zeros(1,50000),'--','color',orange,'LineWidth',2) %[0.7,0.7,0.7],'LineWidth',1.5)
                 hold on
    
                   legend('\sl y\rm=0 guideline','Performance Decrease')
                 ylabel('% Obj Value Decrease of Scen')
                  xlabel('Scenario (Sorted by Increasing Performance Change)') 
                  title('Scenario Performance Decrease from Omitting \sl z')

                legend('Performance Decrease','\sl y\rm=0 guideline')
            elseif metric(1,3)=='b'  %plots the objectives of SLSF and SLSF-noZ

              
                  objsorted=sort(testobjlongnoz(:),'ascend');
           
                  plot(1:50000,objsorted,'--k','LineWidth',1.5) 
                  hold on
                  [objsorted,ind]=sort(testobjlong(:),'ascend');
                    plot(1:50000,objsorted,'k','LineWidth',1.5) 
                  hold on


    %              plot(1:50000,objsorted,'k','LineWidth',1.5) 
    %              hold on 
    %              plot(1:50000,zeros(1,50000),'--','color',[0.7,0.7,0.7],'LineWidth',1.5)
    %              hold on
    
    
%                     [objsorted,ind]=sort(testobjlong(:),'ascend');
%                     objsorted=sort(testobjlongnoz(:),'ascend');
%                     full=testobjlongnoz(:);
%                     objsorted=full(ind);
%                   plot(1:50000,objsorted,'o','color',[0.9,0.9,0.9],'LineWidth',1.5) 
%                   hold on
%                   [objsorted,ind]=sort(testobjlong(:),'ascend');
%                     plot(1:50000,objsorted,'k','LineWidth',1.5) 
%                   hold on
                  
                   lg=legend('\sl y\rm=0 guideline','Performance Decrease')
                   lg.Location='southeast'
                 ylabel('% Objective Value Decrease of Scenario')
                  xlabel('Scenario (Sorted by Increasing Performance Change)') 
                  title('Performance Decrease from Omitting \sl z')

                legend('Performance Decrease','\sl y\rm=0 guideline')
            end
        end
        
    elseif metric=='ms' 
        
        
        yhatsum=zeros(m*trials,n);
        for i=1:100
           yhatsum=yhatsum+saayhatlong(:,(i-1)*n+1:i*n); 
        end
        yhatsumsum=zeros(trials,n);
        yprobssum=zeros(trials,n);
        for t=1:trials
            for j=1:n
                yhatsumsum(t,j)=nnz(yhatsum((t-1)*m+1:t*m,j));
                yprobssum(t,j)=nnz(yprobslong(:,(t-1)*n+j));
            end
        end
        blah=size(find(yhatsumsum<5))
        menusize=sum(xlongnoz,1)
        find(menusize<5)
        size(find(menusize<4))
        yprobscropped=yprobslong(:,find(menusize<5));
        
        timeslong
        timeslongnoz
        mean(timeslong)
        median(timeslong)
        mean(timeslongnoz)
        
        median(timeslongnoz)
%         for t=1:10
%             for j=1:n
%                if menusize(1,(t-1)*n+j)<5
%                    if nnz(yhatsum((t-1)*m+1:t*m,j))>menusize(1,(t-1)*n+j)
%                        menusize(1,(t-1)*n+j)
%                      nnz(yhatsum((t-1)*m+1:t*m,j))
%                      bit='oh noes'
%                    end
%                end
%             end
%         end
        
         
                 %yprobssum=sum(yprobslong~=0);
                  a=[3 0 0;0 2 0; 1 0 4] ;  %input matrix
         sum(a~=0);
         %%% check if yhat has only 4 diff pos vals for menus that aren't max size 
%             tbl=tabulate(menusize);
%           tblperc=tbl
%           tblperc(:,2)=tblperc(:,2)/sum(tbl(:,2))
%           plot(tblperc(:,1),tblperc(:,2),'k','LineWidth',1.5) 
%           hold on
%          end
%           ylabel('Probability')
%           xlabel('Menu Size')
%           set(gca,'xtick',0:5)


       %%% number of positive z per scenario and number of unhappy drivers
    elseif metric=='z'  
            %%% first calculate and plot for SLSF-noZ
            %number of positive zij values
            ztotal=zeros(trials,testsamps);
            for t=1:trials
                for k=1:testsamps
                    ztotal(t,k)=sum(sum(testzlongnoz((t-1)*m+1:t*m,(k-1)*n+1:k*n)));
                end
            end
            
            %number of unhappy drivers
            unhappy=zeros(trials,testsamps);
            for t=1:trials
                for k=1:testsamps
                    for j=1:n
                        if sum(testzlongnoz((t-1)*m+1:t*m,(k-1)*n+j))>0
                        unhappy(t,k)=unhappy(t,k)+1;
                        end
                    end
                end
            end

            %tabulate how many cases there are of each number of positive
            %z/ unhappy drivers
              [bincountsz,indz]=histc(ztotal(:),min(ztotal(:)):max(ztotal(:)));
            zweights=accumarray(indz,testscenprobslong(:));
            zperc=zweights/sum(zweights);
            [bincountsu,indu]=histc(unhappy(:),min(unhappy(:)):max(unhappy(:)));
            unweights=accumarray(indu,testscenprobslong(:));
            unperc=unweights/sum(unweights);
              

      %%% plot
      rgb=horzcat(orange,0.6);
      plot(min(ztotal(:)):max(ztotal(:)),zperc,'color',rgb,'LineWidth',7) 
      hold on
      alpha(0.2)
      plot(min(unhappy(:)):max(unhappy(:)),unperc,':x','color',purple,'LineWidth',2) 
      hold on
      alpha(0.2)
      
      [min(unhappy(:)):max(unhappy(:))]*unperc/20
      %%%%%%%%%%%%%%
      %%% now calcualte for SLSF number of positive z per scenario and number of unhappy drivers
        ztotal=zeros(trials,testsamps);
            for t=1:trials
                for k=1:testsamps
                    ztotal(t,k)=sum(sum(testzlong((t-1)*m+1:t*m,(k-1)*n+1:k*n)));
                end
            end
            
            unhappy=zeros(trials,testsamps);
            for t=1:trials
                for k=1:testsamps
                    for j=1:n
                        if sum(testzlong((t-1)*m+1:t*m,(k-1)*n+j))>0
                        unhappy(t,k)=unhappy(t,k)+1;
                        end
                    end
                end
            end       
      
            %tabulate how many cases there are of each number of positive
            %z/ unhappy drivers
        [bincountsz,indz]=histc(ztotal(:),min(ztotal(:)):max(ztotal(:)));
            zweights=accumarray(indz,testscenprobslong(:));
            zperc=zweights/sum(zweights);
            [bincountsu,indu]=histc(unhappy(:),min(unhappy(:)):max(unhappy(:)));
            unweights=accumarray(indu,testscenprobslong(:));
            unperc=unweights/sum(unweights);
               

      %plot for SLSF
      rgb=horzcat(yellow,0.6);
      plot(min(ztotal(:)):max(ztotal(:)),zperc,'color',rgb,'LineWidth',7) 
      hold on
      alpha(0.2)
      plot(min(unhappy(:)):max(unhappy(:)),unperc,'-.d','color',green,'LineWidth',2) 
      hold on
      alpha(0.2)
  
      ylabel('Probability')
      xlabel('Count in a Random Test Scenario')
      title('Positive \sl z_{ij}\rm\bf Count and Unhappy Drivers')
      legend('Positive \sl z_{ij}\rm (SLSFnoZ)','Unhappy Drivers\rm (SLSFnoZ)','Positive \sl z_{ij}\rm (SLSF)','Unhappy Drivers \rm(SLSF)');

      [min(unhappy(:)):max(unhappy(:))]*unperc/20
      
    elseif metric(1,1)=='d' %calculate  overlap in the two menu sets (duplicate menu items)
        xsum=xlong+xlongnoz;
        unique=size(find(xsum==1))
        overlap=size(find(xsum==2))
        offered=size(find(xsum>=1))
        
        %portion of all requests that are in at least menu that are in
        %exactly one menu
        unique/offered
        
        %portion of all requests that are in at least menu that are in
        %both menus
        overlap/offered
      
    elseif metric=='w' %%% number of unfullfilled requests per scenario
        wtotal=zeros(trials,testsamps);
        for t=1:trials
            wtotal(t,:)=sum(testwlongnoz((t-1)*m+1:t*m,:));
        end

             [bincounts,ind]=histc(wtotal(:),min(wtotal(:)):max(wtotal(:)));
                rejweights=accumarray(ind,testscenprobslong(:));
                rejperc=rejweights/sum(rejweights);
              plot(min(wtotal(:)):max(wtotal(:)),rejperc,'k','LineWidth',1.5) 
              hold on
                [min(wtotal(:)):max(wtotal(:))]*rejperc/20
            
      
      wtotal=zeros(trials,testsamps);
        for t=1:trials
            wtotal(t,:)=sum(testwlong((t-1)*m+1:t*m,:));
        end


             [bincounts,ind]=histc(wtotal(:),min(wtotal(:)):max(wtotal(:)));
                rejweights=accumarray(ind,testscenprobslong(:));
                rejperc=rejweights/sum(rejweights);
              plot(min(wtotal(:)):max(wtotal(:)),rejperc,'--k','LineWidth',1.5) 
              hold on
              ylabel('Probability')
              xlabel('Unfulfilled Requests in a Random Test Scenario')
                [min(wtotal(:)):max(wtotal(:))]*rejperc/20
     
        legend('SLSFnoZ','SLSF')
        
        title('Unfulfilled Requests')
    end
  
%%%%%%%%%%%%%%%%%%% theta effect %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif experiment=='t'
    
       %%%% obj value
    if metric(1,1)=='o'
        if metric(1,2)=='a' % objective average of each instance for each menu size
            
            [obj,ind]=sort(testobjavelong(1,:));
            objsorted=testobjavelong(:,ind);
            
%              colors=[ 0 0 0;
%                 0.3 0.3 0.3;
%                 0.5 0.5 0.5;
%                 0.7 0.7 0.7;
%                 0.8 0.8 0.8];
            colors=[blue;green;yellow;orange;red];
            %symbols=[': ';'- ';'--';'-.';' -'];
            symbols=[':o ';'-^ ';'--+';'-.d';' -x'];  
            for i=numthetas:-1:1
                plot(1:10,objsorted(i,:),symbols(i,:),'color',colors(i,:),'LineWidth',2);
                hold on
            end
            
            mean((testobjavelong(1,:)-testobjavelong(5,:))./testobjavelong(5,:))
            
            ylabel("Probability")
            xlim([1,10])
            lg=legend('\theta=20','\theta=10','\theta=5','\theta=3','\theta=1');
            lg.Location='northwest';

              ylabel('Objectve Value Est of Instance')
              xlabel('Instance (Sorted by Increasing Obj Value of \theta=1)')

            title('Instance Performance Effect of \theta')
            
        elseif metric(1,2)=='i' %objective value of each test scenario of each instance
            obs=zeros(5,testsamps*trials);
            
%              colors=[ 0 0 0;
%                 0.3 0.3 0.3;
%                 0.5 0.5 0.5;
%                 0.7 0.7 0.7;
%                 0.8 0.8 0.8];
            colors=[blue;green;yellow;orange;red];
            %symbols=[': ';'- ';'--';'-.';' -'];
            symbols=[':o ';'-^ ';'--+';'-.d';' -x'];  
            for i=1:5
                objs=testobjlong((i-1)*trials+1:i*trials,:);
                objsorted=sort(objs(:));
                plot(1:testsamps*trials,objsorted,symbols(i,:),'color',colors(i,:),'LineWidth',2);
                hold on
            end
            
            ylabel("Probability")
            lg=legend('\theta=20','\theta=10','\theta=5','\theta=3','\theta=1');
            lg.Location='southeast';

              ylabel('Objectve Value Estimate of Scenario')
              xlabel('Scenario (Sorted by Increasing Value)')

            title('Scenario Performance Effect of \theta')
        end
    elseif metric=='ms' %menu size
%          colors=[ 0 0 0;
%                 0.3 0.3 0.3;
%                 0.5 0.5 0.5;
%                 0.7 0.7 0.7;
%                 0.8 0.8 0.8];
            colors=[blue;green;yellow;orange;red];
            %symbols=[': ';'- ';'--';'-.';' -'];
            symbols=[':o ';'-^ ';'--+';'-.d';' -x']; 
            i=4                                  
            menu10=sum(xlong((i-1)*m+1:i*m,:));
            i=5
            menu20=sum(xlong((i-1)*m+1:i*m,:));
            size(find(menu10==menu20),2)/n/trials
         for i=numthetas:-1:1
         menusize=sum(xlong((i-1)*m+1:i*m,:));
         tbl=tabulate(menusize);
          tblperc=tbl;
          tblperc(:,2)=tblperc(:,2)/sum(tbl(:,2))
          plot(tblperc(:,1),tblperc(:,2),symbols(i,:),'color',colors(i,:),'LineWidth',2) 
          sum(tblperc(:,1).*tblperc(:,2));
          hold on
         end
          ylabel('Probability')
          xlabel('Menu Size')
          lg=legend('\theta=20','\theta=10','\theta=5','\theta=3','\theta=1');
          title('Menu Size')
          set(gca,'xtick',0:20)
          
    elseif metric(1,1)=='d' %menus' overlaps
        total=xlong(1:m,:)+10*xlong(m+1:2*m,:)+100*xlong(2*m+1:3*m,:)+1000*xlong(3*m+1:4*m,:)+10000*xlong(4*m+1:5*m,:);
        totals=zeros(4,4);
        for i=1:4
            for j=i:4
                totals(i,j)=size(find(xlong((i-1)*m+1:i*m,:)+xlong(j*m+1:(j+1)*m,:)==2),1)/nnz(xlong((i-1)*m+1:i*m,:)); 
            end       
        end

    totals
    totals*100
    
    sums=zeros(m,trials);
    for t=1:trials
       sums(:,t)=sum(xlong(1:m,(t-1)*n+1:t*n),2) 
    end
    
    elseif metric=='yh' %number of nonzero pij/yhat vs number of requests offered
        
        yhatsum=zeros(m*trials,n);
        for i=1:100
           yhatsum=yhatsum+saayhatlong(:,(i-1)*n+1:i*n); 
        end
        yhatsumsum=zeros(trials,n);
        yprobssum=zeros(trials,n);
        xsum=zeros(trials,n);
        for t=1:trials
            for j=1:n
                xsum(t,j)=sum(xlong(4*m+1:5*m,(t-1)*n+j))
                yhatsumsum(t,j)=nnz(yhatsum((t-1)*m+1:t*m,j));
                yprobssum(t,j)=nnz(yprobslong(:,(t-1)*n+j));
            end
        end
        blah=size(find(yhatsumsum>xsum))
        blah/n*trials
        sum(sum(xsum))/trials/n
%         menusize=sum(xlongnoz,1)
%         find(menusize<5)
%         size(find(menusize<4))
%         yprobscropped=yprobslong(:,find(menusize<5));
        
        mean(timeslong,2)
         median(timeslong,2)
         timeslong

          %%% number of unhappy drivers
    elseif metric=='z'
%         colors=[ 0 0 0;
%                 0.3 0.3 0.3;
%                 0.5 0.5 0.5;
%                 0.7 0.7 0.7;
%                 0.8 0.8 0.8];
            colors=[blue;green;yellow;orange;red];
            %symbols=[': ';'- ';'--';'-.';' -'];
            symbols=[':o ';'-^ ';'--+';'-.d';' -x'];  
            
        for i=numthetas:-1:1
            
            unhappy=zeros(trials,testsamps);
            for t=1:trials
                for k=1:testsamps
                    for j=1:n
                        if sum(testzlong((i-1)*m*trials+(t-1)*m+1:(i-1)*m*trials+t*m,(k-1)*n+j))>0
                        unhappy(t,k)=unhappy(t,k)+1;
                        end
                    end
                end
            end

            [bincountsu,indu]=histc(unhappy(:),min(unhappy(:)):max(unhappy(:)));
            unweights=accumarray(indu,testscenprobslong(:));
            unperc=unweights/sum(unweights);
        if max(unhappy(:))==0
            
          plot(min(unhappy(:)):max(unhappy(:)),unperc,symbols(i,:),'color',colors(i,:),'LineWidth',2) 
          hold on
        else
            plot(min(unhappy(:)):max(unhappy(:)),unperc,symbols(i,:),'color',colors(i,:),'LineWidth',2) 
          hold on
        end
          [min(unhappy(:)):max(unhappy(:))]*unperc/20
        end
          
          ylabel('Probability')
          xlabel('Unhappy Drivers in a Random Test Scenario')
          title('Unhappy Drivers')
          lg=legend('\theta=20','\theta=10','\theta=5','\theta=3','\theta=1');
            %lg.Location='northwest';
        
     %%% number of unfullfilled requests per scenario
        elseif metric=='w'
%             colors=[ 0 0 0;
%                 0.3 0.3 0.3;
%                 0.5 0.5 0.5;
%                 0.7 0.7 0.7;
%                 0.8 0.8 0.8];
            colors=[blue;green;yellow;orange;red];
            %symbols=[': ';'- ';'--';'-.';' -'];
            symbols=[':o ';'-^ ';'--+';'-.d';' -x'];
            for i=numthetas:-1:1
                wtotal=zeros(trials,testsamps);
                for t=1:trials
                    wtotal(t,:)=sum(testwlong((i-1)*m*trials+(t-1)*m+1:(i-1)*m*trials+t*m,:));
                end

                    %min(wtotal(:)):max(wtotal(:))
                 [bincounts,ind]=histc(wtotal(:),min(wtotal(:)):max(wtotal(:)));
                    
                    rejweights=accumarray(ind,testscenprobslong(:));
                    rejperc=rejweights/sum(rejweights);
                    [min(wtotal(:)):max(wtotal(:))]*rejperc/20
                  plot(min(wtotal(:)):max(wtotal(:)),rejperc,symbols(i,:),'color',colors(i,:),'LineWidth',2) 
                  hold on
            end
              ylabel('Probability')
              xlabel('Unfulfilled Requests in a Random Test Scenario')
              lg=legend('\theta=20','\theta=10','\theta=5','\theta=3','\theta=1');
            %lg.Location='northwest';
                
      
            
            title('Unfulfilled Requests')
            
            
    end 
       
%%%%%%%%%%%%%%%%%%% wages effect %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif experiment=='w'
    
       %%%% obj value
    if metric(1,1)=='o'
        if metric(1,2)=='a' %objective averages of each instance
            
            [sorted,ind]=sort(testobjavelong(1,:));
            objsorted=testobjavelong(:,ind);
          mean(testobjavelong,2)
%              colors=[ 0 0 0;
%                 0.3 0.3 0.3;
%                 0.5 0.5 0.5;
%                 0.6 0.6 0.6;
%                 0.7 0.7 0.7;
%                 0.8 0.8 0.8];
            colors=[purple;blue;green;yellow;orange;red];
            %symbols=['- ';': ';'--';'- ';'-.';'--'];
            symbols=['-^ ';':o ';'--+';'-x ';'-.d';'--v']; 
            for i=numwages:-1:1
                plot(1:10,objsorted(i,:),symbols(i,:),'color',colors(i,:),'LineWidth',2);
                hold on
            end
            
            ylabel("Probability")
            lg=legend('wage=90%','wage=80%','wage=70%','wage=60%','wage=50%','wage=40%');
            lg.Location='southeast';

              ylabel('Objectve Value Est of Instance')
              xlabel('Instance (Sorted by Increasing Value of Wage=40% Objs)')
                xlim([1,10])
            title('Instance Perf Estimates of Compensation Levels')
            
        elseif metric(1,2)=='i' %objectives of each individual scenario
            obs=zeros(6,testsamps*trials);
            
%              colors=[ 0 0 0;
%                 0.3 0.3 0.3;
%                 0.5 0.5 0.5;
%                 0.6 0.6 0.6;
%                 0.7 0.7 0.7;
%                 0.8 0.8 0.8];
            colors=[purple;blue;green;yellow;orange;red];
            symbols=['- ';': ';'--';'- ';'-.';'--'];
            %symbols=['- ';': ';'--';'- ';'-.';'--'];  
            for i=1:6
                objs=testobjlong((i-1)*trials+1:i*trials,:);
                objsorted=sort(objs(:));
                plot(1:testsamps*trials,objsorted,symbols(i,:),'color',colors(i,:),'LineWidth',1.5);
                hold on
            end
            
            ylabel("Probability")
            lg=legend('wage=90%','wage=80%','wage=70%','wage=60%','wage=50%','wage=40%');
            lg.Location='southeast';

              ylabel('Objectve Value Estimate of Instance')
              xlabel('Scenario (Sorted by Increasing Obj Value of Wage Level)')

            title('Scenario Performance Estimates of Compensation Levels')
        end
    elseif metric=='ms' %menu size
         colors=[ 0 0 0;
                0.3 0.3 0.3;
                0.5 0.5 0.5;
                0.6 0.6 0.6;
                0.7 0.7 0.7;
                0.8 0.8 0.8];
            symbols=['- ';': ';'--';'- ';'-.';'--'];
            %symbols=['-^ ';':o ';'--+';'-x ';'-.d';'--v'];  
         for i=1:numwages
         menusize=sum(xlong((i-1)*m+1:i*m,:));
         tbl=tabulate(menusize);
          tblperc=tbl
          tblperc(:,2)=tblperc(:,2)/sum(tbl(:,2))
          plot(tblperc(:,1),tblperc(:,2),symbols(i,:),'color',colors(i,:),'LineWidth',2.5) 
          sum(tblperc(:,1).*tblperc(:,2))
          hold on
         end
          ylabel('Probability')
          xlabel('Menu Size')
          lg=legend('wage=40%','wage=50%','wage=60%','wage=70%','wage=80%','wage=90%');
          lg.Location='northwest';
          title('Menu Size')
          set(gca,'xtick',0:5)
          
    elseif metric(1,1)=='d' %was made to look at what entries are in what menus, but I would say it's inactive code
        total=xlong(1:m,:)+10*xlong(m+1:2*m,:)+100*xlong(2*m+1:3*m,:)+1000*xlong(3*m+1:4*m,:)+10000*xlong(4*m+1:5*m,:);
        totals=zeros(4,4);
        for i=1:4
            for j=i:4
                totals(i,j)=size(find(xlong((i-1)*m+1:i*m,:)+xlong(j*m+1:(j+1)*m,:)==2),1)/nnz(xlong((i-1)*m+1:i*m,:)); 
            end       
        end

    totals
    totals*100
    
    elseif metric=='yh' %number of nonzero pij/yhat vs number of requests offered
        
        yhatsum=zeros(m*trials,n);
        for i=1:100
           yhatsum=yhatsum+saayhatlong(:,(i-1)*n+1:i*n); 
        end
        yhatsumsum=zeros(trials,n);
        yprobssum=zeros(trials,n);
        xsum=zeros(trials,n);
        for t=1:trials
            for j=1:n
                xsum(t,j)=sum(xlong(4*m+1:5*m,(t-1)*n+j))
                yhatsumsum(t,j)=nnz(yhatsum((t-1)*m+1:t*m,j));
                yprobssum(t,j)=nnz(yprobslong(:,(t-1)*n+j));
            end
        end
        blah=size(find(yhatsumsum>xsum))
%         menusize=sum(xlongnoz,1)
%         find(menusize<5)
%         size(find(menusize<4))
%         yprobscropped=yprobslong(:,find(menusize<5));
        
        mean(timeslong,2)
        median(timeslong,2)
        timeslong

        
        %%% number of unfullfilled requests per scenario
        elseif metric=='w'
%             colors=[ 0 0 0;
%                 0.3 0.3 0.3;
%                 0.5 0.5 0.5;
%                 0.6 0.6 0.6;
%                 0.7 0.7 0.7;
%                 0.8 0.8 0.8];

            colors=[purple;blue;green;yellow;orange;red];    
            %symbols=['- ';': ';'--';'- ';'-.';'--']; 
            symbols=['-^ ';':o ';'--+';'-x ';'-.d';'--v'];
            for i=numwages:-1:1
                wtotal=zeros(trials,testsamps);
                for t=1:trials
                    wtotal(t,:)=sum(testwlong((i-1)*m*trials+(t-1)*m+1:(i-1)*m*trials+t*m,:));
                end

                    %min(wtotal(:)):max(wtotal(:))
                 [bincounts,ind]=histc(wtotal(:),min(wtotal(:)):max(wtotal(:)));
                    testcropped=testscenprobslong((i-1)*trials+1:i*trials,:);
                    rejweights=accumarray(ind,testcropped(:));
                    rejperc=rejweights/sum(rejweights);
                    [min(wtotal(:)):max(wtotal(:))]*rejperc/20
                  plot(min(wtotal(:)):max(wtotal(:)),rejperc,symbols(i,:),'color',colors(i,:),'LineWidth',2) 
                  hold on
            end
              ylabel('Probability')
              xlabel('Unfulfilled Requests in a Random Test Scenario')
              lg=legend('wage=90%','wage=80%','wage=70%','wage=60%','wage=50%','wage=40%');
            %lg.Location='northwest';
                
      
            
            title('Unfulfilled Requests')
        
     %%% number of unhappy drivers
    elseif metric=='z'
%         colors=[ 0 0 0;
%                 0.3 0.3 0.3;
%                 0.5 0.5 0.5;
%                 0.6 0.6 0.6;
%                 0.7 0.7 0.7;
%                 0.8 0.8 0.8];
            colors=[purple;blue;green;yellow;orange;red];
            %symbols=['- ';': ';'--';'- ';'-.';'--'];
            symbols=['-^ ';':o ';'--+';'-x ';'-.d';'--v'];
            
        for i=numwages:-1:1
            
            unhappy=zeros(trials,testsamps);
            for t=1:trials
                for k=1:testsamps
                    for j=1:n
                        if sum(testzlong((i-1)*m*trials+(t-1)*m+1:(i-1)*m*trials+t*m,(k-1)*n+j))>0
                        unhappy(t,k)=unhappy(t,k)+1;
                        end
                    end
                end
            end

            [bincountsu,indu]=histc(unhappy(:),min(unhappy(:)):max(unhappy(:)));
            testcropped=testscenprobslong((i-1)*trials+1:i*trials,:);
            unweights=accumarray(indu,testcropped(:));
            unperc=unweights/sum(unweights);

          plot(min(unhappy(:)):max(unhappy(:)),unperc,symbols(i,:),'color',colors(i,:),'LineWidth',2) 
          hold on
          [min(unhappy(:)):max(unhappy(:))]*unperc/20
        end
          
          ylabel('Probability')
          xlabel('Unhappy Drivers in a Random Test Scenario')
          title('Unhappy Drivers')
          lg=legend('wage=90%','wage=80%','wage=70%','wage=60%','wage=50%','wage=40%');
            %lg.Location='northwest';
             
            
    elseif metric(1,1)=='c' %expected income by platform and by drivers
        [arcdata,dem]=loadchicago_regional_proper();

        [miles,mins]=loadtripinfo();
        tripinfo=cat(3,miles,mins);
        drivpay=zeros(trials,numwages);
        platpay=zeros(trials,numwages);   
        for t=1:trials
           
                %%% pull out trip info for our drawn OD pairs
                OjDj=zeros(n,2);
                for j=1:n
                    OjDj(j,:)=horzcat(miles(Oj(j),Dj(j)),mins(Oj(j),Dj(j)));
                end

                OiDi=zeros(m,2);
                for i=1:m
                    OiDi(i,:)=horzcat(miles(Oi(i),Di(i)),mins(Oi(i),Di(i)));
                end

                %row is request, column is driver, and first entry is miles, second is minutes
                OjOi=permute(tripinfo(Oj,Oi,:),[2 1 3]);
                DiDj=tripinfo(Di,Dj,:);

                fare=repmat(max(1.79*ones(m,1)+0.81*OiDi(:,1)+0.28*OiDi(:,2),3*ones(m,1)),1,n);
                
            %%%     
            for w=1:numwages
                wage=wagelevels(w,1);
                weightmatrix=kron(testscenprobslong(trials*(w-1)+t,:),ones(m,n));
                %driverwages is the assignment times wage*fare
                drivpay(t,w)=sum(sum(weightmatrix.*(wage*repmat(fare,1,testsamps).*testvlong((w-1)*m*trials+(t-1)*m+1:(w-1)*m*trials+t*m,:))))/sum(testscenprobslong(trials*(w-1)+t,:));
                %platform wage is assignment times wage*far + booking
                
               platpay(t,w)=sum(sum((weightmatrix.*(1.85*ones(m,n*testsamps)+(1-wage)*repmat(fare,1,testsamps)).*testvlong((w-1)*m*trials+(t-1)*m+1:(w-1)*m*trials+t*m,:))))/sum(testscenprobslong(trials*(w-1)+t,:));
                                
            end
            
%             for t=1:trials
%                 plot(0.4:0.1:0.9,drivpay(t,:))
%                 hold on
%                 plot(0.4:0.1:0.9,platpay(t,:),'--')
%                 hold on
%             end
            
        end
      color1=orange %[0,0,0];
            color2=blue%[0.8,0.8,0.8];
            sym1=':o';
            sym2='-^';
            sym3='--d';
         
          plot(0.4:0.1:0.9,max(platpay,[],1),sym1,'color',color1,'LineWidth',2)
          hold on
          plot(0.4:0.1:0.9,mean(platpay,1),sym2,'color',color1,'LineWidth',2)
          hold on
          plot(0.4:0.1:0.9,min(platpay,[],1),sym3,'color',color1,'LineWidth',2)
          hold on
          plot(0.4:0.1:0.9,max(drivpay,[],1),sym1,'color',color2,'LineWidth',2)
          hold on
          plot(0.4:0.1:0.9,mean(drivpay,1),sym2,'color',color2,'LineWidth',2)
          hold on
          plot(0.4:0.1:0.9,min(drivpay,[],1),sym3,'color',color2,'LineWidth',2)
          hold on  
          
          title('Expected \sl inc^{s^*}_{plat} \rm\bf and \sl inc^{s^*}_{driv} \rm\bf of Instances')
            xlabel('Portion of Compensation Drivers Receive (\slwage\rm)')
            xticks(0.4:0.1:0.9)
            ylabel('Dollars')
            lg=legend('Platform Max','Platform Ave','Platform Min','Drivers Max','Drivers Ave','Drivers Min')
            lg.Location='northwest';
   
     elseif metric=='p' %pij distribution
            colors=[purple;blue;green;yellow;orange;red];
            %symbols=['- ';': ';'--';'- ';'-.';'--'];
            symbols=['-^ ';':o ';'--+';'-x ';'-.d';'--v'];  
         for i=numwages:-1:1
         %[bins,inds]=histc(-0.5:0.1:11,0:10);
            %result=horzcat([-0.5:0.1:11]',inds');
  
                
            bincounts = histc(yprobslong((i-1)*m+1:m*i,:),[0:0.1:1]);
            bincounts=bincounts/sum(bincounts);
            plot([0:0.1:1],bincounts,symbols(i,:),'color',colors(i,:),'LineWidth',2);
            
          hold on
         end
          ylabel('Probability')
          xlabel('\sl p_{ij}')
          lg=legend('wage=90%','wage=80%','wage=70%','wage=60%','wage=50%','wage=40%');
          %lg.Location='northwest';
          title('\sl p_{ij}\rm\bf of Different Wage Levels')
          %set(gca,'xtick',0:5)
          
      elseif metric=='n' %the number of drivers willing to fulfill each request
            colors=[purple;blue;green;yellow;orange;red];
            %symbols=['- ';': ';'--';'- ';'-.';'--'];
            symbols=['-^ ';':o ';'--+';'-x ';'-.d';'--v'];  
         for i=numwages:-1:1
         %[bins,inds]=histc(-0.5:0.1:11,0:10);
            %result=horzcat([-0.5:0.1:11]',inds');
           willing=zeros(m*trials,testsamps);
            for t=1:trials
                for s=1:testsamps
                    willing((t-1)*m+1:t*m,s)=sum(testyhatlong((i-1)*trials*m+(t-1)*m+1:(i-1)*trials*m+t*m,(s-1)*n+1:s*n),2);
                end
            end
            [bincountsu,indu]=histc(willing(:),min(willing(:)):max(willing(:)));
            testcropped=kron(testscenprobslong((i-1)*trials+1:i*trials,:),ones(m,1));
            unweights=accumarray(indu,testcropped(:));
            unperc=unweights/sum(unweights)

          plot(min(willing(:)):max(willing(:)),unperc,symbols(i,:),'color',colors(i,:),'LineWidth',2)             
          hold on
         end
          ylabel('Probability')
          xlabel('Number of Drivers')
          lg=legend('wage=90%','wage=80%','wage=70%','wage=60%','wage=50%','wage=40%');
          %lg.Location='northwest';
          title('Drivers Willing to Accept Request \sl i ')
          %set(gca,'xtick',0:5)
    
    end 
end