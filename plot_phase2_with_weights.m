% []function=plot_phase2_with_weights(stage,metric,percent)

%this code is used to make all graphs, data analysis etc of the problem
%instances run for phase 2 (which became phase 3 after adding heuristic
%comparisons as phase 2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%To make the plots/get analysis numbers, simply adjust the values for skinny, stage, metric, and ranktype as
%desired and then run the code. The data is loaded in from
%'phase2instw5000testsamps.mat' which can be changed to a different file if
%desired
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

skinny = 1; %this alters the dimensions of outputted graphs, was added to allow for slightly skinnier graphs that
%would fit three in the same row in the latex version of the SLSF paper.
%skinny=1 for the skinnier graphs, otherwise skinny=0
stage=[0 0 1]; %a row vector of what stage you want to analyze. If you want to analyze date from just one stage, only one
% entry is 1 (e.g. menu size analysis would be stage=[1 0 0] and assignment
% analysis would be stage=[0 0 1]. For the analysis comparing multiple
% stages, including the data comparison and ranking comparison across 6
% different metrics as well as the pij vs cij graph , stage=[1 1 1].
metric='w'; %%% the metric to be analysed. Options for stage=[1 0 0]: 'o'= # of times each request is offered,
%'a'= ave pij vs #times offered, 's'=menu size, 'p'=pij of menu items. For
%stage= [0 1 0], the only option is 'p'=pij of accepted items. For stage =
%[0 0 1], 'z'=number of positive z per scenario, 'u'=number of penalties
%per unhappy driver (when there is at least one), 'p'=Pij of assigned Items, 
% 'w'=number of unfullfilled requests per scenario, 'a'=percent of the time an item is assigned (when >0).   
%For stage=[1 1 1], 'p'= pij values of requests in each stage, 'c'= pij vs
%cij of raw data and offered requests, 'r' is used for all six metrics that
%are plotted both as is and with respect to their ranking
ranktype='pu'; %%% this is only used when stage = [1 1 1] and metric='r'. It conssists of two letters, first letter is what data we extract from the OD data: 
%%%d=request trip duration, o=distance to req orig, e=extra driving time, 
%%% u=unpaid time/paid time, n= new path/old path, p=pij value. The second
%%% letter is 'u' if you want to plot the raw data, that is, unranked, and
%%% 'r' is ranked where each request is ranked from 1 to m for each driver
%%% (1 is best) for the given metric, then the graph shows the relative
%%% rank of the requests that get offered, accepted, and assigned


percent=1;
load('C:\Users\horneh\Google Drive\RPI\Research\code\Paper_experiments\phase_3\phase2instw5000testsamps.mat');
m=size(Clong,1);
[n,trials]=size(Ojlong);
testsamps=size(testobjlong,2);
%saasampweights=kron(saascenprobslong,ones(m,n));
testsampweights=kron(testscenprobslong,ones(m,n));
if skinny == 1
    %%% decides the size and location in which the graph is made on the screen, first two digits are the (pixel?) coordinates of
    %%% the top left corner, then 3rd and 4th numbers are the (pixel?) width and hieght respectively
    
    figure('Renderer', 'painters', 'Position', [300 300 350 230])%figure('Renderer', 'painters', 'Position', [300 300 500 350])
else
  
   %%% decides the size and location in which the graph is made on the screen, first two digits are the (pixel?) coordinates of
    %%% the top left corner, then 3rd and 4th numbers are the (pixel?) width and hieght respectively
     figure('Renderer', 'painters', 'Position', [300 300 400 250]) % figure('Renderer', 'painters', 'Position', [300 300 600 350])
end

%%% rgb of some rainbow colors to use in plots
red=[0.6350 0.0780 0.1840];
orange=[0.8500 0.3250 0.0980];
yellow=[0.9290 0.6940 0.1250];
green=[0.4660 0.6740 0.1880];
blue=[0 0.4470 0.7410];
purple=[0.4940 0.1840 0.5560];




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% for menu graphs (stage=[1 0 0]) %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if stage(1,1)==1
    %%%% # of times an item is offered
    if metric=='o'
        offeredlong=zeros(m*trials,1);
        for t=1:trials
            offeredlong((t-1)*m+1:t*m,1)=sum(xlong(:,(t-1)*n+1:t*n),2);
        end
        
        if percent==0
            hist(offeredlong,10)
        else
           tbl=tabulate(offeredlong(:));
          tblperc=tbl
          tblperc(:,2)=tblperc(:,2)/sum(tbl(:,2));%trials/testsamps/n;
          plot(tblperc(:,1),tblperc(:,2),'-x','color',blue,'LineWidth',2) 
          hold on
          ylabel('Probability')
          xlabel('Number of Menus Containing Request \sl i')
            
        end
        
        title('Driver Menus Containing Request \sl i')
    
    %%%% ave pij vs #times offered
    elseif metric=='a'
        offeredlong=zeros(m*trials,1);
        avepijlong=zeros(m*trials,1);
        for t=1:trials
            offeredlong((t-1)*m+1:t*m,1)=sum(xlong(:,(t-1)*n+1:t*n),2);
            avepijlong((t-1)*m+1:t*m,1)=sum(yprobslong(:,(t-1)*n+1:t*n),2)/n;
        end
        r = corrcoef(avepijlong,offeredlong);
        scatter(avepijlong,offeredlong,30,blue)
        title('Average \sl p_{ij}\rm\bf vs Times Offered')
        xlabel('Average \sl p_{ij}\rm of request \sli')
        ylabel('Number of menus containing i')
        str=['     r= ',num2str(r(1,2))]
        T = text(max(get(gca, 'xlim')), max(get(gca, 'ylim')), str); 
        set(T, 'fontsize', 14, 'verticalalignment', 'top', 'horizontalalignment', 'right');
    
    %%%% menu size
    elseif metric=='s'
       
        
        
        if percent==0
            hist(sum(xlong,1),theta)
        else
            menusize=sum(xlong,1);
            tbl=tabulate(menusize(:));
          tblperc=tbl
          tblperc(:,2)=tblperc(:,2)/sum(tbl(:,2));
          plot(tblperc(:,1),tblperc(:,2),'-x','color',blue,'LineWidth',2) 
          hold on
          ylabel('Probability')
          xlabel('Menu Size')
          set(gca,'xtick',0:5)
            
        end
        title('Menu Size')
    %%%% pij of menu items
    elseif metric=='p'
        pijoffered=xlong.*yprobslong;
        pijofferedlong=pijoffered(:);
        pijofferedshortp1=pijofferedlong(find(pijofferedlong>0));
        if nnz(stage)==1
            hist(pijofferedshortp1,10)
            title('Pij of Menu Items')
        end
    %%%% distance ranking of assigned Items (for a few different rank metrics)
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %the rest of the 'stage 1 code' just does some calculations and creates
    %some data to use for the ranked/unranked graphs for stage=[1 1 1]
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif metric=='r'
        ranklong=zeros(m,n*trials);
        offeredranklong=zeros(m,n*trials);
        extralong=zeros(m,n*trials);
        originlong=zeros(m,n*trials);
        destlong=zeros(m,n*trials);
        newpathlong=zeros(m,n*trials);
        triplong=zeros(m,n*trials);
        [miles,mins]=loadtripinfo();
        tripinfo=cat(3,miles,mins);
        OjDjlong=zeros(n,2*trials);
        OiDilong=zeros(m,2*trials);
        OjOilong=zeros(m,n,2*trials);
        DiDjlong=zeros(m,n,2*trials);
        OjDjgrid=zeros(m,n*trials);
        for t=1:trials

            for j=1:n
                OjDjlong(j,(t-1)*2+1:2*t)=horzcat(miles(Ojlong(j,t),Djlong(j,t)),mins(Ojlong(j,t),Djlong(j,t)));
            end

            for i=1:m
                OiDilong(i,(t-1)*2+1:2*t)=horzcat(miles(Oilong(i,t),Dilong(i,t)),mins(Oilong(i,t),Dilong(i,t)));
            end

            %row is request, column is driver, and first entry is miles, second is minutes
            OjOilong(:,:,(t-1)*2+1:2*t)=permute(tripinfo(Ojlong(:,t),Oilong(:,t),:),[2 1 3]);

            DiDjlong(:,:,(t-1)*2+1:2*t)=tripinfo(Dilong(:,t),Djlong(:,t),:);
                                        
            extralong(:,(t-1)*n+1:t*n)=OjOilong(:,:,2*t) + repmat(OiDilong(:,2*t),1,n) + DiDjlong(:,:,2*t) -repmat(OjDjlong(:,2*t)',m,1);
            originlong(:,(t-1)*n+1:t*n)=OjOilong(:,:,2*t);
            triplong(:,(t-1)*n+1:t*n)=repmat(OiDilong(:,2*t),1,n);
            OjDjgrid(:,(t-1)*n+1:t*n)=repmat(OjDjlong(:,2*t)',m,1);
            destlong(:,(t-1)*n+1:t*n)=DiDjlong(:,:,2*t);
        end
        newpathlong=originlong+triplong+destlong;
        
        %%% if the rank is extra driving time
        if ranktype=='er'
           [B,I]=sort(extralong);
           [C,ranklong]=sort(I);
           offeredranklong=xlong.*ranklong; 
           if percent==0
                offered=offeredranklong(:);
                hist(offered(find(offered>0)),m);
                title('Extra Driving Time Rank of Offered Requests')
           else
              tbl=tabulate(offeredranklong(:));
              tblperc=tbl;
              tblperc(:,2)=tblperc(:,2)/sum(tbl(2:21,2));%trials/n;
              rankpercp1=tblperc(2:21,2);
              if nnz(stage)==1
                  plot(tblperc(2:21,1),tblperc(2:21,2))
                  xlabel('Extra Driving Time Rank')
                  ylabel('Percent of Scenarios Request is Offered') 
                  title('Extra Driving Time Rank Distribution of Offered Requests')
              end

           end
           %%% if the rank is the driver's distance to the reques's origin
        elseif ranktype=='or'
                [B,I]=sort(originlong);
               [C,ranklong]=sort(I);
               offeredranklong=xlong.*ranklong; 
               if percent==0
                   offered=offeredranklong(:);
                    hist(offered(find(offered>0)),m);
                    title('Wait Time Rank of Offered Requests')
               else
                  tbl=tabulate(offeredranklong(:));
                  tblperc=tbl;
                  tblperc(:,2)=tblperc(:,2)/sum(tbl(2:21,2));%trials/n;
                  rankpercp1=tblperc(2:21,2);
                  if nnz(stage)==1
                      plot(tblperc(2:21,1),tblperc(2:21,2))
                      xlabel('Wait Time Rank')
                      ylabel('Percent of Scenarios Request is Offered') 
                      title('Wait Time Rank Distribution of Offered Requests')
                  end
               end
         %%% if the rank is the length of the request trip
         elseif ranktype=='dr'
                [B,I]=sort(triplong);
               [C,ranklong]=sort(I);
                offeredranklong=xlong.*ranklong; 
               if percent==0
                   offered=offeredranklong(:);
                    hist(offered(find(offered>0)),m);
                    title('Request Trip Duration Rank of Offered Requests')
               else
                  tbl=tabulate(offeredranklong(:));
                  tblperc=tbl;
                  tblperc(:,2)=tblperc(:,2)/sum(tbl(2:21,2));%trials/testsamps/n;
                  rankpercp1=tblperc(2:21,2);
                  if nnz(stage)==1
                      plot(tblperc(2:21,1),tblperc(2:21,2))
                      xlabel('Request Trip Duration Rank')
                      ylabel('Percent of Scenarios Request is Offered') 
                      title('Request Trip Duration Rank Distribution of Offered Requests')
                  end
               end
               
                %%% if the rank is unpaid/paid
         elseif ranktype=='ur'
                [B,I]=sort(-triplong./(originlong+destlong));
               [C,ranklong]=sort(I);
                offeredranklong=xlong.*ranklong; 
               if percent==0
                   offered=offeredranklong(:);
                    hist(offered(find(offered>0)),m);
                    title('Request Trip Duration Rank of Offered Requests')
               else
                  tbl=tabulate(offeredranklong(:));
                  tblperc=tbl;
                  tblperc(:,2)=tblperc(:,2)/sum(tbl(2:21,2));%trials/testsamps/n;
                  rankpercp1=tblperc(2:21,2);
                  if nnz(stage)==1
                      plot(tblperc(2:21,1),tblperc(2:21,2))
                      xlabel('Unpaid/Paid Rank')
                      ylabel('Percent of Scenarios Request is Offered') 
                      title('Unpaid/Paid Rank Distribution of Offered Requests')
                  end
               end
               
                %%% if the rank is new path/old path
         elseif ranktype=='nr'
                [B,I]=sort(-OjDjgrid./newpathlong);
               [C,ranklong]=sort(I);
                offeredranklong=xlong.*ranklong; 
               if percent==0
                   offered=offeredranklong(:);
                    hist(offered(find(offered>0)),m);
                    title('New Path/Old Path Rank of Offered Requests')
               else
                  tbl=tabulate(offeredranklong(:));
                  tblperc=tbl;
                  tblperc(:,2)=tblperc(:,2)/sum(tbl(2:21,2));%trials/testsamps/n;
                  rankpercp1=tblperc(2:21,2);
                  if nnz(stage)==1
                      plot(tblperc(2:21,1),tblperc(2:21,2))
                      xlabel('New Path/Old Path Rank')
                      ylabel('Percent of Scenarios Request is Offered') 
                      title('New Path/Old Path Rank Distribution of Offered Requests')
                  end
               end
               
         %%% if the rank is new path/old path
         elseif ranktype=='pr'
                [B,I]=sort(ones(m,n*trials)-yprobslong);
               [C,ranklong]=sort(I);
                offeredranklong=xlong.*ranklong; 
               if percent==0
                   offered=offeredranklong(:);
                    hist(offered(find(offered>0)),m);
                    title('\sl p_{ij}\rm\bf Rank of Offered Requests')
               else
                   tbl=tabulate(offeredranklong(:));
                  tblperc=tbl;
                  tblperc(:,2)=tblperc(:,2)/sum(tbl(2:21,2));%trials/testsamps/n;
                  rankpercp1=tblperc(2:21,2);
              if nnz(stage)==1
                      plot(tblperc(2:21,1),tblperc(2:21,2))
                      xlabel('\sl p_{ij}\rm Rank')
                      ylabel('Percent of Scenarios Request is Offered') 
                      title('\sl p_{ij}\rm\bf Rank Distribution of Offered Requests')
                  end
               end
        end
    
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% for accepted graphs (stage = [0 1 0])   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
if stage(1,2)==1
       %%%% Pij of accepted Items    
        if metric=='p'
            pijaccepted=zeros(m*trials,n*testsamps);
            for t=1:trials
                pijaccepted((t-1)*m+1:t*m,:)=testyhatlong((t-1)*m+1:t*m,:).*repmat(yprobslong(:,(t-1)*n+1:t*n),1,testsamps);
            end
            
            pijacceptedlong=pijaccepted(:);
            pijacceptedshortp2=pijacceptedlong(find(pijacceptedlong>0));
            if nnz(stage)==1
                hist(pijacceptedshortp2,10)
                title('Pij of Accepted Items')
            end
        %%%% distance ranking of assigned Items (for a few different rank metrics)    
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %the rest of the 'stage 2 code' just does some calculations and creates
        %some data to use for the ranked/unranked graphs for stage=[1 1 1]
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif metric=='r'
            ranklong=zeros(m,n*trials);
            acceptedranklong=zeros(m*trials,n*testsamps);
            extralong=zeros(m,n*trials);
            originlong=zeros(m,n*trials);
            destlong=zeros(m,n*trials);
            newpathlong=zeros(m,n*trials);
            triplong=zeros(m,n*trials);
            [miles,mins]=loadtripinfo();
            tripinfo=cat(3,miles,mins);
            OjDjlong=zeros(n,2*trials);
            OiDilong=zeros(m,2*trials);
            OjOilong=zeros(m,n,2*trials);
            DiDjlong=zeros(m,n,2*trials);
            OjDjgrid=zeros(m,n*trials);
            for t=1:trials
                
                for j=1:n
                    OjDjlong(j,(t-1)*2+1:2*t)=horzcat(miles(Ojlong(j,t),Djlong(j,t)),mins(Ojlong(j,t),Djlong(j,t)));
                end

                for i=1:m
                    OiDilong(i,(t-1)*2+1:2*t)=horzcat(miles(Oilong(i,t),Dilong(i,t)),mins(Oilong(i,t),Dilong(i,t)));
                end

                %row is request, column is driver, and first entry is miles, second is minutes
                OjOilong(:,:,(t-1)*2+1:2*t)=permute(tripinfo(Ojlong(:,t),Oilong(:,t),:),[2 1 3]);

                DiDjlong(:,:,(t-1)*2+1:2*t)=tripinfo(Dilong(:,t),Djlong(:,t),:);
                extralong(:,(t-1)*n+1:t*n)=OjOilong(:,:,2*t) + repmat(OiDilong(:,2*t),1,n) + DiDjlong(:,:,2*t) -repmat(OjDjlong(:,2*t)',m,1);
                originlong(:,(t-1)*n+1:t*n)=OjOilong(:,:,2*t);
                triplong(:,(t-1)*n+1:t*n)=repmat(OiDilong(:,2*t),1,n);
                OjDjgrid(:,(t-1)*n+1:t*n)=repmat(OjDjlong(:,2*t)',m,1);
                destlong(:,(t-1)*n+1:t*n)=DiDjlong(:,:,2*t);
            end
            newpathlong=originlong+triplong+destlong;
            
            %%% if the rank is extra driving time
            if ranktype=='er'
               [B,I]=sort(extralong);
               [C,ranklong]=sort(I);
               for t=1:trials
                  acceptedranklong((t-1)*m+1:t*m,:)=testyhatlong((t-1)*m+1:t*m,:).*repmat(ranklong(:,(t-1)*n+1:t*n),1,testsamps); 
               end
               if percent==0
                    accepted=acceptedranklong(:);
                    hist(accepted(find(accepted>0)),m);
                    title('Extra Driving Time Rank of Accepted Requests')
               else
                  [bincounts,ind]=histc(acceptedranklong(:),-0.5:1:20.5);
                  rankweights=accumarray(ind,testsampweights(:));
                  rankpercp2=rankweights(2:21,:)/sum(rankweights(2:21,:));
                  if nnz(stage)==1
                      plot(tblperc(2:21,1),tblperc(2:21,2))
                      xlabel('Extra Driving Time Rank of Accepted Requests')
                      ylabel('Percent of Scenarios Request is Accepted') 
                      title('Extra Driving Time Rank Distribution of Accepted Requests')
                  end
                  
               end
               %%% if the rank is the driver's distance to the reques's origin
            elseif ranktype=='or'
                [B,I]=sort(originlong);
               [C,ranklong]=sort(I);
               for t=1:trials
                  acceptedranklong((t-1)*m+1:t*m,:)=testyhatlong((t-1)*m+1:t*m,:).*repmat(ranklong(:,(t-1)*n+1:t*n),1,testsamps); 
               end
               if percent==0
                    accepted=acceptedranklong(:);
                    hist(accepted(find(accepted>0)),m);
                    title('Wait Time Rank of Accepted Requests')
               else
                  [bincounts,ind]=histc(acceptedranklong(:),-0.5:1:20.5);
                  rankweights=accumarray(ind,testsampweights(:));
                  rankpercp2=rankweights(2:21,:)/sum(rankweights(2:21,:));
                  if nnz(stage)==1
                      plot(tblperc(2:21,1),tblperc(2:21,2))
                      xlabel('Wait Time Rank of Accepted Requests')
                      ylabel('Percent of Scenarios Request is Accepted') 
                      title('Wait Time Rank Distribution of Accepted Requests')
                  end
               end
             %%% if the rank is the length of the request trip
             elseif ranktype=='dr'
                [B,I]=sort(triplong);
               [C,ranklong]=sort(I);
               for t=1:trials
                  acceptedranklong((t-1)*m+1:t*m,:)=testyhatlong((t-1)*m+1:t*m,:).*repmat(ranklong(:,(t-1)*n+1:t*n),1,testsamps); 
               end
               if percent==0
                    accepted=acceptedranklong(:);
                    hist(accepted(find(accepted>0)),m);
                    title('Request Trip Duration Rank of Accepted Requests')
               else
                  [bincounts,ind]=histc(acceptedranklong(:),-0.5:1:20.5);
                  rankweights=accumarray(ind,testsampweights(:));
                  rankpercp2=rankweights(2:21,:)/sum(rankweights(2:21,:));
                  if nnz(stage)==1
                      plot(tblperc(2:21,1),tblperc(2:21,2))
                      xlabel('Request Trip Duration Rank of Accepted Requests')
                      ylabel('Percent of Scenarios Request is Accepted') 
                      title('Request Trip Duration Rank Distribution of Accepted Requests')
                  end
               end
               
               %%% if the rank is the unpaid/paid
             elseif ranktype=='ur'
                [B,I]=sort(-triplong./(originlong+destlong));
               [C,ranklong]=sort(I);
               for t=1:trials
                  acceptedranklong((t-1)*m+1:t*m,:)=testyhatlong((t-1)*m+1:t*m,:).*repmat(ranklong(:,(t-1)*n+1:t*n),1,testsamps); 
               end
               if percent==0
                    accepted=acceptedranklong(:);
                    hist(accepted(find(accepted>0)),m);
                    title('Unpaid/Paid Rank of Accepted Requests')
               else
                  [bincounts,ind]=histc(acceptedranklong(:),-0.5:1:20.5);
                  rankweights=accumarray(ind,testsampweights(:));
                  rankpercp2=rankweights(2:21,:)/sum(rankweights(2:21,:));
                  if nnz(stage)==1
                      plot(tblperc(2:21,1),tblperc(2:21,2))
                      xlabel('Unpaid/Paid Rank of Accepted Requests')
                      ylabel('Percent of Scenarios Request is Accepted') 
                      title('Unpaid/Paid Rank Distribution of Accepted Requests')
                  end
               end
               
               %%% if the rank is new path/old path
             elseif ranktype=='nr'
                [B,I]=sort(-OjDjgrid./newpathlong);
               [C,ranklong]=sort(I);
               for t=1:trials
                  acceptedranklong((t-1)*m+1:t*m,:)=testyhatlong((t-1)*m+1:t*m,:).*repmat(ranklong(:,(t-1)*n+1:t*n),1,testsamps); 
               end
               if percent==0
                    accepted=acceptedranklong(:);
                    hist(accepted(find(accepted>0)),m);
                    title('New Path/Old Path Rank of Accepted Requests')
               else
                  [bincounts,ind]=histc(acceptedranklong(:),-0.5:1:20.5);
                  rankweights=accumarray(ind,testsampweights(:));
                  rankpercp2=rankweights(2:21,:)/sum(rankweights(2:21,:));
                  if nnz(stage)==1
                      plot(tblperc(2:21,1),tblperc(2:21,2))
                      xlabel('New Path/Old Path Rank of Accepted Requests')
                      ylabel('Percent of Scenarios Request is Accepted') 
                      title('New Path/Old Path Rank Distribution of Accepted Requests')
                  end
               end
               
                 %%% if the rank is pij
             elseif ranktype=='pr'
                [B,I]=sort(ones(m,n*trials)-yprobslong);
               [C,ranklong]=sort(I);
               for t=1:trials
                  acceptedranklong((t-1)*m+1:t*m,:)=testyhatlong((t-1)*m+1:t*m,:).*repmat(ranklong(:,(t-1)*n+1:t*n),1,testsamps); 
               end
               if percent==0
                    accepted=acceptedranklong(:);
                    hist(accepted(find(accepted>0)),m);
                    title('\sl p_{ij}\rm\bf Rank of Accepted Requests')
               else
                  [bincounts,ind]=histc(acceptedranklong(:),-0.5:1:20.5);
                  rankweights=accumarray(ind,testsampweights(:));
                  rankpercp2=rankweights(2:21,:)/sum(rankweights(2:21,:));
                  if nnz(stage)==1
                      plot(tblperc(2:21,1),tblperc(2:21,2))
                      xlabel('\sl p_{ij}\rm Rank of Accepted Requests')
                      ylabel('Percent of Scenarios Request is Accepted') 
                      title('\sl p_{ij}\rm\bf Rank Distribution of Accepted Requests')
                  end
               end
            end
        
        end
end  
    
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% for assigned graphs  (stage = [0 0 1])  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if stage(1,3)==1
        %%% number of positive z per scenario
        if metric=='z'
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

            
        if percent==0
            hist(ztotal,10)
            title('Number of Positive Zij')
        else
            [bincountsz,indz]=histc(ztotal(:),min(ztotal(:)):max(ztotal(:)));
            zweights=accumarray(indz,testscenprobslong(:));
            zperc=zweights/sum(zweights);
            [bincountsu,indu]=histc(unhappy(:),min(unhappy(:)):max(unhappy(:)));
            unweights=accumarray(indu,testscenprobslong(:));
            unperc=unweights/sum(unweights);
                rgb=[0.8 0.8 0.8];
          plot(min(ztotal(:)):max(ztotal(:)),zperc,'color',yellow,'LineWidth',7) 
          hold on
          plot(min(unhappy(:)):max(unhappy(:)),unperc,'-.x','color',green,'LineWidth',2) 
          hold on
          ylabel('Probability')
          xlabel('Count in a Random Test Scenario')
          title('Positive \sl z_{ij}\rm\bf Count and Unhappy Drivers')
          legend('Positive \sl z_{ij}','Unhappy Drivers')
          
             [min(unhappy(:)):max(unhappy(:))]*unperc/20
        end
        
            
        %%% number of penalties per unhappy driver (when there is at least one)
        elseif metric=='u'
           testweightslong=kron(testscenprobslong,ones(1,n));
           penalties=zeros(trials,n*testsamps);
           size(penalties)
            for t=1:trials
                for k=1:testsamps
                    for j=1:n
                        penalties(t,(k-1)*n+j)=sum(testzlong((t-1)*m+1:t*m,(k-1)*n+j));
                    end
                end
            end
            size(penalties)
            penaltlong=penalties(:);
            weightslong=testweightslong(:);
            size(penaltlong)
             penaltypos=penaltlong(find(penaltlong>0));
             weightspos=weightslong(find(penaltlong>0));
            [bincounts,ind]=histc(penaltypos,min(penaltypos):max(penaltypos));
                penweights=accumarray(ind,weightspos);
                penperc=penweights/sum(penweights);
               
          plot(min(penaltypos):max(penaltypos),penperc,'-x','color',blue,'LineWidth',2) 
          hold on
          ylabel('Probability')
          xticks([1 2 3])
          xlabel('Number of Requests Accepted by an Unhappy Driver')
%             hist(unhappypos)
            title('Number of Requests Accepted by an Unhappy Driver')
%         
            
        %%%% Pij of assigned Items    
        elseif metric=='p'
            pijassigned=zeros(m*trials,n*testsamps);
            for t=1:trials
                pijassigned((t-1)*m+1:t*m,:)=testvlong((t-1)*m+1:t*m,:).*repmat(yprobslong(:,(t-1)*n+1:t*n),1,testsamps);
            end
            
            pijassignedlong=pijassigned(:);
            pijassignedshortp3=pijassignedlong(find(pijassignedlong>0));
            if nnz(stage)==1
                hist(pijassignedshortp3,10)
                title('Pij of Assigned Items')
            end
            
        %%% number of unfullfilled requests per scenario
        elseif metric=='w'
            wtotal=zeros(trials,testsamps);
            for t=1:trials
                wtotal(t,:)=sum(testwlong((t-1)*m+1:t*m,:));
            end

            if percent==0
                hist(wtotal(:),7)
            else
                min(wtotal(:)):max(wtotal(:))
             [bincounts,ind]=histc(wtotal(:),min(wtotal(:)):max(wtotal(:)));
                rejweights=accumarray(ind,testscenprobslong(:));
                rejperc=rejweights/sum(rejweights);
              plot(min(wtotal(:)):max(wtotal(:)),rejperc,'-x','color',blue,'LineWidth',2) 
              hold on
              ylabel('Probability')
              xlabel('Unfulfilled Requests in a Random Test Scenario')
                [min(wtotal(:)):max(wtotal(:))]*rejperc/20
            end
            
            title('Unfulfilled Requests')
        
    
        
         %%% percent of the time an item is assigned (when >0)
        elseif metric=='a'
            aveassign=aveassignlong(:);
            max(aveassign)
            aveassign=aveassign(find(xlong(:)>0));
            testweightslong=testsampweights(:);
            testweights=testweightslong(find(xlong(:)>0));
            if percent==0
                hist(aveassign)
                
            else
                [bincounts,ind]=histc(aveassign,0:0.1:1);
                aveweights=accumarray(ind,testweights);
                aveperc=aveweights/sum(aveweights);
               
                ylabel('Probability')
                xlabel('Portion of Test Scens Assigning Request \sli\rm to Driver \slj')
                hold on
                plot(0:0.1:1,aveperc,'-x','color',blue,'LineWidth',2);
                
            end
        title('Test Scens Assigning Request \sli\rm\bf to Driver \slj')
            
            
        
        %%%% distance ranking of assigned Items (for a few different rank metrics)    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %the rest of the 'stage 3 code' just does some calculations and creates
        %some data to use for the ranked/unranked graphs for stage=[1 1 1]
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif metric=='r'
            ranklong=zeros(m,n*trials);
            assignedranklong=zeros(m*trials,n*testsamps);
            extralong=zeros(m,n*trials);
            originlong=zeros(m,n*trials);
            destlong=zeros(m,n*trials);
            newpathlong=zeros(m,n*trials);
            triplong=zeros(m,n*trials);
            [miles,mins]=loadtripinfo();
            tripinfo=cat(3,miles,mins);
            OjDjlong=zeros(n,2*trials);
            OiDilong=zeros(m,2*trials);
            OjOilong=zeros(m,n,2*trials);
            DiDjlong=zeros(m,n,2*trials);
            OjDjgrid=zeros(m,n*trials);
            for t=1:trials
                
                for j=1:n
                    OjDjlong(j,(t-1)*2+1:2*t)=horzcat(miles(Ojlong(j,t),Djlong(j,t)),mins(Ojlong(j,t),Djlong(j,t)));
                end

                for i=1:m
                    OiDilong(i,(t-1)*2+1:2*t)=horzcat(miles(Oilong(i,t),Dilong(i,t)),mins(Oilong(i,t),Dilong(i,t)));
                end

                %row is request, column is driver, and first entry is miles, second is minutes
                OjOilong(:,:,(t-1)*2+1:2*t)=permute(tripinfo(Ojlong(:,t),Oilong(:,t),:),[2 1 3]);

                DiDjlong(:,:,(t-1)*2+1:2*t)=tripinfo(Dilong(:,t),Djlong(:,t),:);
                extralong(:,(t-1)*n+1:t*n)=OjOilong(:,:,2*t) + repmat(OiDilong(:,2*t),1,n) + DiDjlong(:,:,2*t) -repmat(OjDjlong(:,2*t)',m,1);
                originlong(:,(t-1)*n+1:t*n)=OjOilong(:,:,2*t);
                triplong(:,(t-1)*n+1:t*n)=repmat(OiDilong(:,2*t),1,n);
                OjDjgrid(:,(t-1)*n+1:t*n)=repmat(OjDjlong(:,2*t)',m,1);
                destlong(:,(t-1)*n+1:t*n)=DiDjlong(:,:,2*t);
            end
            newpathlong=originlong+triplong+destlong;

            %%% if the rank is extra driving time
            if ranktype=='er'
               [B,I]=sort(extralong);
               [C,ranklong]=sort(I);
               for t=1:trials
                  assignedranklong((t-1)*m+1:t*m,:)=testvlong((t-1)*m+1:t*m,:).*repmat(ranklong(:,(t-1)*n+1:t*n),1,testsamps); 
               end
               if percent==0
                    assigned=assignedranklong(:);
                    hist(assigned(find(assigned>0)),m);
                    title('Extra Driving Time Rank')
               else
                  [bincounts,ind]=histc(assignedranklong(:),-0.5:1:20.5);
                    rankweights=accumarray(ind,testsampweights(:));
                    rankpercp3=rankweights(2:21,:)/sum(rankweights(2:21,:));
                  if nnz(stage)==1
                      plot(tblperc(2:21,1),tblperc(2:21,2))
                      xlabel('Extra Driving Time Rank')
                      ylabel('Percent of Scenarios Request is Assigned') 
                      title('Extra Driving Time Rank Distribution of Assignments')
                  end
                  
               end
               %%% if the rank is the driver's distance to the reques's origin
            elseif ranktype=='or'
                    [B,I]=sort(originlong);
                   [C,ranklong]=sort(I);
                   for t=1:trials
                      assignedranklong((t-1)*m+1:t*m,:)=testvlong((t-1)*m+1:t*m,:).*repmat(ranklong(:,(t-1)*n+1:t*n),1,testsamps); 
                   end
                   if percent==0
                       assigned=assignedranklong(:);
                        hist(assigned(find(assigned>0)),m);
                        title('Wait Time Distance Rank of Assigned Items')
                   else
                      [bincounts,ind]=histc(assignedranklong(:),-0.5:1:20.5);
                    rankweights=accumarray(ind,testsampweights(:));
                    rankpercp3=rankweights(2:21,:)/sum(rankweights(2:21,:));
                      if nnz(stage)==1
                          plot(tblperc(2:21,1),tblperc(2:21,2))
                          xlabel('Wait Time Rank')
                          ylabel('Percent of Scenarios Request is Assigned') 
                          title('Wait Time Rank Distribution of Assignments')
                      end
                   end
             %%% if the rank is the length of the request trip
             elseif ranktype=='dr'
                    [B,I]=sort(triplong);
                   [C,ranklong]=sort(I);
                   for t=1:trials
                      assignedranklong((t-1)*m+1:t*m,:)=testvlong((t-1)*m+1:t*m,:).*repmat(ranklong(:,(t-1)*n+1:t*n),1,testsamps); 
                   end
                   if percent==0
                   assigned=assignedranklong(:);
                    hist(assigned(find(assigned>0)),m);
                    title('Request Trip Duration Rank of Assigned Items')
                   else
                      [bincounts,ind]=histc(assignedranklong(:),-0.5:1:20.5);
                    rankweights=accumarray(ind,testsampweights(:));
                    rankpercp3=rankweights(2:21,:)/sum(rankweights(2:21,:));
                      if nnz(stage)==1
                          plot(tblperc(2:21,1),tblperc(2:21,2))
                          xlabel('Request Trip Duration Rank')
                          ylabel('Percent of Scenarios Request is Assigned') 
                          title('Request Trip Duration Rank Distribution of Assignments')
                      end
                   end
                   
                   
                    %%% if the rank is unpaid/paid
             elseif ranktype=='ur'
                    [B,I]=sort(-triplong./(originlong+destlong));
                   [C,ranklong]=sort(I);
                   for t=1:trials
                      assignedranklong((t-1)*m+1:t*m,:)=testvlong((t-1)*m+1:t*m,:).*repmat(ranklong(:,(t-1)*n+1:t*n),1,testsamps); 
                   end
                   if percent==0
                   assigned=assignedranklong(:);
                    hist(assigned(find(assigned>0)),m);
                    title('Paid/Unpaid Rank of Assigned Items')
                   else
                      [bincounts,ind]=histc(assignedranklong(:),-0.5:1:20.5);
                    rankweights=accumarray(ind,testsampweights(:));
                    rankpercp3=rankweights(2:21,:)/sum(rankweights(2:21,:));
                      if nnz(stage)==1
                          plot(tblperc(2:21,1),tblperc(2:21,2))
                          xlabel('Unpaid/Paid Rank')
                          ylabel('Percent of Scenarios Request is Assigned') 
                          title('Unpaid/Paid Rank Distribution of Assignments')
                      end
                   end
                   
                   
            %%% if the rank is the length of the request trip
             elseif ranktype=='nr'
                    [B,I]=sort(-OjDjgrid./newpathlong);
                   [C,ranklong]=sort(I);
                   for t=1:trials
                      assignedranklong((t-1)*m+1:t*m,:)=testvlong((t-1)*m+1:t*m,:).*repmat(ranklong(:,(t-1)*n+1:t*n),1,testsamps); 
                   end
                   if percent==0
                   assigned=assignedranklong(:);
                    hist(assigned(find(assigned>0)),m);
                    title('New Path/Old Path Rank of Assigned Items')
                   else
                      [bincounts,ind]=histc(assignedranklong(:),-0.5:1:20.5);
                    rankweights=accumarray(ind,testsampweights(:));
                    rankpercp3=rankweights(2:21,:)/sum(rankweights(2:21,:));
                      if nnz(stage)==1
                          plot(tblperc(2:21,1),tblperc(2:21,2))
                          xlabel('New Path/Old Path Rank')
                          ylabel('Percent of Scenarios Request is Assigned') 
                          title('New Path/Old Path Rank Distribution of Assignments')
                      end
                   end
                   
            %%% if the rank is pij
             elseif ranktype=='pr'
                    [B,I]=sort(ones(m,n*trials)-yprobslong);
                   [C,ranklong]=sort(I);
                   for t=1:trials
                      assignedranklong((t-1)*m+1:t*m,:)=testvlong((t-1)*m+1:t*m,:).*repmat(ranklong(:,(t-1)*n+1:t*n),1,testsamps); 
                   end
                   if percent==0
                   assigned=assignedranklong(:);
                    hist(assigned(find(assigned>0)),m);
                    title('\sl p_{ij}\rm\bf Rank of Assigned Items')
                   else
                     [bincounts,ind]=histc(assignedranklong(:),-0.5:1:20.5);
                    rankweights=accumarray(ind,testsampweights(:));
                    rankpercp3=rankweights(2:21,:)/sum(rankweights(2:21,:));
                      if nnz(stage)==1
                          plot(tblperc(2:21,1),tblperc(2:21,2))
                          xlabel('\sl p_{ij}\rm Rank')
                          ylabel('Percent of Scenarios Request is Assigned') 
                          title('\sl p_{ij}\rm\bf Rank Distribution of Assignments')
                      end
                   end
            end
        end
            
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% multi-stage analysis (stage = [1 1 1])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nnz(stage)==3

        colors=vertcat(orange,green,blue);
            symbols=[':o ';'-^ ';'--+']; 
    if metric=='p'
        %hist(pijassignedshortp3,'facecolor',map(1,:),'facealpha',.5,'edgecolor','none')
        x=[0:0.1:1];
        bincounts1 = histc(pijofferedshortp1,x);
        bincounts1=bincounts1/sum(bincounts1);
        plot(x,bincounts1,symbols(1,:),'color',colors(1,:),'LineWidth',1.5);
        hold on
        bincounts2 = histc(pijacceptedshortp2,x);
        bincounts2=bincounts2/sum(bincounts2);
        plot(x,bincounts2,symbols(2,:),'color',colors(2,:),'LineWidth',1.5);
        hold on
        bincounts3 = histc(pijassignedshortp3,x);
        bincounts3=bincounts3/sum(bincounts3);
        plot(x,bincounts3,symbols(3,:),'color',colors(3,:),'LineWidth',1.5);
        title('\slp_{ij}\rm\bf Value of Requests in Each Stage')
        xlabel('\slp_{ij}\rm Value of Request')
        ylabel("Probability")
        lg=legend('Offered','Accepted','Assigned');
        lg.Location='northwest';
        
    elseif metric=='c'
            measurement1=yprobslong;
            data0=measurement1;
            data1=measurement1.*xlong;
            
            measurement2=Clong + kron(rlong, ones(1,n));
            data02=measurement2;
            data12=measurement2.*xlong;
            
            data0=data0(:);
            data02=data02(:);
            data1=data1(:);
            data12=data12(:);
            %data0=data0(find(xlong(:)==0));
            %data02=data02(find(xlong(:)==0));
            data1=data1(find(xlong(:)==1));
            data12=data12(find(xlong(:)==1));
            
            r1 = corrcoef(yprobslong(:),measurement2(:));
            r2=corrcoef(data1,data12);
            rgb=[0.7 0.7 0.7];
             scatter(data0,data02,30,yellow,'filled')
             hold on
             
             scatter(data1,data12,30,purple)
            xlabel('\sl p_{ij}')
            ylabel('\sl c_{ij}-\rm match bonus')
             title('\sl p_{ij} vs \rm\bf(\slc_{ij}-\rm\bf match bonus)')
             legend('Original','Offered','Location','southeast')
             str=['r_{original}= ',num2str(round(r1(1,2),3))];
        T = text(min(get(gca, 'xlim'))+0.05, max(get(gca, 'ylim')), str); 
        set(T, 'fontsize', 14, 'verticalalignment', 'top', 'horizontalalignment', 'left');
        str2=['r_{offered}=' num2str(round(r2(1,2),3))];
        T2 = text(min(get(gca, 'xlim'))+0.05, max(get(gca, 'ylim'))-1, str2); 
        set(T2, 'fontsize', 14, 'verticalalignment', 'top', 'horizontalalignment', 'left');
        
    elseif metric=='r'
        if ranktype(1,2)=='r'
            size(rankpercp1)
            size(rankpercp2)
            size(rankpercp3)
            plot((1:20)',rankpercp1,symbols(1,:),'color',colors(1,:),'LineWidth',2);
            hold on
            plot((1:20)',rankpercp2,symbols(2,:),'color',colors(2,:),'LineWidth',2);
            hold on
            plot((1:20)',rankpercp3,symbols(3,:),'color',colors(3,:),'LineWidth',2);
            ylabel("Probability")
            lg=legend('Offered','Accepted','Assigned');
        end
        if ranktype=='er'
            xlabel('Extra Driving Time Rank')
             title('Extra Driving Time Rank')
            
        elseif ranktype=='or'
            
            xlabel('Wait Time Rank')
             title('Wait Time Rank')
            
        elseif ranktype=='dr'
             xlabel('Request Trip Duration Rank')
             title('Request Trip Duration Rank')
             lg.Location='southeast'
            
        elseif ranktype=='ur'
             xlabel('Paid/Unpaid Rank')
             title('Paid/Unpaid Rank')
             
         elseif ranktype=='nr'
             xlabel('Old Path/Newpath Rank')
             title('Old Path/Newpath Rank')
             
         elseif ranktype=='pr'
             xlabel('\sl p_{ij}\rm Rank')
             title('\sl p_{ij}\rm\bf Rank')
        end
          
         data2=zeros(m*trials,n*testsamps);
         data3=zeros(m*trials,n*testsamps);
        
         
        if ranktype=='pu'
            size(find(extralong<0))
            measurement=yprobslong;
            data0=measurement;
            data1=measurement.*xlong;
            for t=1:trials
                data2((t-1)*m+1:t*m,:)=testyhatlong((t-1)*m+1:t*m,:).*repmat(measurement(:,(t-1)*n+1:t*n),1,testsamps); 
                data3((t-1)*m+1:t*m,:)=testvlong((t-1)*m+1:t*m,:).*repmat(measurement(:,(t-1)*n+1:t*n),1,testsamps);                  
            end
            xlabel('\sl p_{ij}')
             title('\sl p_{ij}')
             hold on
         
         
        elseif ranktype=='eu'
            measurement=extralong;
            data0=measurement;
            data1=measurement.*xlong;
            for t=1:trials
                data2((t-1)*m+1:t*m,:)=testyhatlong((t-1)*m+1:t*m,:).*repmat(measurement(:,(t-1)*n+1:t*n),1,testsamps); 
                data3((t-1)*m+1:t*m,:)=testvlong((t-1)*m+1:t*m,:).*repmat(measurement(:,(t-1)*n+1:t*n),1,testsamps);                  
            end
            xlabel('Extra Driving Time (mins)')
             title('Extra Driving Time')
             hold on
            
        elseif ranktype=='ou'
            measurement=originlong;
            data0=measurement;
            data1=measurement.*xlong;
            for t=1:trials
                data2((t-1)*m+1:t*m,:)=testyhatlong((t-1)*m+1:t*m,:).*repmat(measurement(:,(t-1)*n+1:t*n),1,testsamps); 
                data3((t-1)*m+1:t*m,:)=testvlong((t-1)*m+1:t*m,:).*repmat(measurement(:,(t-1)*n+1:t*n),1,testsamps);                  
            end
            xlabel('Wait Time (mins)')
             title('Wait time')
             hold on
            
        elseif ranktype=='du'
            measurement=triplong;
            data0=measurement;
            data1=measurement.*xlong;
            for t=1:trials
                data2((t-1)*m+1:t*m,:)=testyhatlong((t-1)*m+1:t*m,:).*repmat(measurement(:,(t-1)*n+1:t*n),1,testsamps); 
                data3((t-1)*m+1:t*m,:)=testvlong((t-1)*m+1:t*m,:).*repmat(measurement(:,(t-1)*n+1:t*n),1,testsamps);                  
            end 
            xlabel('Request Trip Duration (mins)')
             title('Request Trip Duration')
             hold on
            
        elseif ranktype=='uu'
            measurement=triplong./(originlong+destlong);
            data0=measurement;
            data1=measurement.*xlong;
            size(find(data0>30))
            for t=1:trials
                data2((t-1)*m+1:t*m,:)=testyhatlong((t-1)*m+1:t*m,:).*repmat(measurement(:,(t-1)*n+1:t*n),1,testsamps); 
                data3((t-1)*m+1:t*m,:)=testvlong((t-1)*m+1:t*m,:).*repmat(measurement(:,(t-1)*n+1:t*n),1,testsamps);                  
            end 
            xlabel('Paid/Unpaid')
             title('Paid/Unpaid')
             hold on
             
         elseif ranktype=='nu'
            measurement=OjDjgrid./newpathlong;
            data0=measurement;
            data1=measurement.*xlong;
            for t=1:trials
                data2((t-1)*m+1:t*m,:)=testyhatlong((t-1)*m+1:t*m,:).*repmat(measurement(:,(t-1)*n+1:t*n),1,testsamps); 
                data3((t-1)*m+1:t*m,:)=testvlong((t-1)*m+1:t*m,:).*repmat(measurement(:,(t-1)*n+1:t*n),1,testsamps);                  
            end
             xlabel('Old Path/Newpath')
             title('Old Path/Newpath')
             hold on
                         
            
        end
         if ranktype(1,2)=='u'
%              colors=[0.85 0.85 0.85;
%                  0 0 0;
%                 0.4 0.4 0.4;
%                 0.6 0.6 0.6]; % 0.8, 0, 0.4, 0.6
             colors=vertcat(yellow,orange,green,blue);   
            %symbols=['- ';'- ';'--';': '];
            symbols=['-.d';':o ';'-^ ';'--+'];  
            data0long=data0(:);
            %data0long=data0long(find(data0long>0));
            data1long=data1(:);
            data1pos=data1long(find(data1long>0));
            data2long=data2(:);
            weights2=testsampweights(:);
            data2pos=data2long(find(data2long>0));
            weights2pos=weights2(find(data2long>0));           
            data3long=data3(:);
            weights3=testsampweights(:);
            data3pos=data3long(find(data3long>0));
            weights3pos=weights3(find(data3long>0));
            
%             if ranktype=='uu'
%                 percent=size(find(data0long<=20),1)/size(data0long,1)
%                 olddatamax=max(data0long)
%                 data0long=data0long(find(data0long<=20));
%                 data1pos=data1pos(find(data1pos<=20));
%                 data2pos=data2pos(find(data2pos<=20));
%                 data3pos=data3pos(find(data3pos<=20));
            if ranktype=='nu'
                cutoff=25;
                percent0=size(find(data0long>cutoff),1)/size(data0long,1)*100
                percent1=size(find(data1pos>cutoff),1)/size(data1pos,1)*100
                percent2=size(find(data2pos>cutoff),1)/size(data2pos,1)*100
                percent3=size(find(data3pos>cutoff),1)/size(data3pos,1)*100
                olddatamax=max(data0long)
                data0long=data0long(find(data0long<=cutoff));
                data1pos=data1pos(find(data1pos<=cutoff));
                data2pos=data2pos(find(data2pos<=cutoff));
                weights2pos=weights2pos(find(data2pos<=cutoff));
                data3pos=data3pos(find(data3pos<=cutoff));
                weights3pos=weights3pos(find(data3pos<=cutoff));
            end
            datamin=min(vertcat(data0long,data1pos,data2pos,data3pos));
            datamax=max(vertcat(data0long,data1pos,data2pos,data3pos));
            x=[datamin:((datamax-datamin)/10):datamax];
            
            
            [bins,inds]=histc(-0.5:0.1:11,0:10);
            result=horzcat([-0.5:0.1:11]',inds');
            bincounts0 = histc(data0long,x);
            bincounts0=bincounts0/sum(bincounts0);
            plot(x,bincounts0,symbols(1,:),'color',colors(1,:),'LineWidth',2);
            hold on
            bincounts1 = histc(data1pos,x);
            bincounts1=bincounts1/sum(bincounts1);
            plot(x,bincounts1,symbols(2,:),'color',colors(2,:),'LineWidth',2);
            hold on
            [bincounts2,ind2] = histc(data2pos,x);
            accumweights2=accumarray(ind2,weights2pos);
            scaledaccum2=accumweights2/sum(accumweights2);
            if size(scaledaccum2,1)<11
               fullaccum2=zeros(11,1);
               counter=1;
               for i=1:11
                   if bincounts2(i,1)>0
                       fullaccum2(i)=scaledaccum2(counter);
                       counter=counter+1;
                   end
               end
              scaledaccum2=fullaccum2;
            end
            plot(x,scaledaccum2,symbols(3,:),'color',colors(3,:),'LineWidth',2);
            hold on
            [bincounts3,ind3] = histc(data3pos,x);
            accumweights3=accumarray(ind3,weights3pos);
            scaledaccum3=accumweights3/sum(accumweights3);
            if size(scaledaccum3,1)<11
               fullaccum3=zeros(11,1);
               counter=1;
               for i=1:11
                   if bincounts3(i,1)>0
                       fullaccum3(i)=scaledaccum3(counter);
                       counter=counter+1;
                   end
               end
              scaledaccum3=fullaccum3;
            end
            plot(x,scaledaccum3,symbols(4,:),'color',colors(4,:),'LineWidth',2);
            ylabel("Probability")
            lg=legend('Original','Offered','Accepted','Assigned');
        end
        
        
    end
    
    
end