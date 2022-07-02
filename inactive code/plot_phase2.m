%[]function=plot_phase2(stage,metric,percent)


stage=[1 0 0];
metric='o'; %%% p=pij distribution, r=graphs that use ranktype and OD data, there are a handfull of others for stages 1 and 3
ranktype='nu'; %%% conssists of two letters, first is what data we extract from the OD data. 
%%%d=request trip duration, o=distance to req orig, e=extra driving time, 
%%% u=unpaid time/paid time, n= new path/old path, p=pij value
percent=1;
%load('C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_2\phase2inst.mat');
load('C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_2\phase2instw5000testsamps.mat');
m=size(Clong,1);
[n,trials]=size(Ojlong);
testsamps=size(testobjlong,2);


%%%%%%%%%%%% for menu graphs %%%%%%%%%%%%%
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
          sum(tblperc(:,1).*tblperc(:,2))
          tblperc
          plot(tblperc(:,1),tblperc(:,2),'k','LineWidth',1.5) 
          hold on
          ylabel('Probability')
          xlabel('Number of Menus Containing Request')
            
        end
        
        title('Number of Driver Menus Containing a Given Request')
    
    %%%% ave pij vs #times offered
    elseif metric=='a'
        offeredlong=zeros(m*trials,1);
        avepijlong=zeros(m*trials,1);
        for t=1:trials
            offeredlong((t-1)*m+1:t*m,1)=sum(xlong(:,(t-1)*n+1:t*n),2);
            avepijlong((t-1)*m+1:t*m,1)=sum(yprobslong(:,(t-1)*n+1:t*n),2)/n;
        end
        r = corrcoef(avepijlong,offeredlong);
        scatter(avepijlong,offeredlong,30,'k')
        title('Average \sl p_{ij}\rm\bf vs Times Offered')
        xlabel('Average \sl p_{ij}\rm of request \sli')
        ylabel('Number of menus containing i')
        str=['     r= ',num2str(round(r(1,2),3))]
        T = text(min(get(gca, 'xlim')), max(get(gca, 'ylim')), str); 
        set(T, 'fontsize', 14, 'verticalalignment', 'top', 'horizontalalignment', 'left');
    
    %%%% menu size
    elseif metric=='s'
       
        
        
        if percent==0
            hist(sum(xlong,1),theta)
        else
            menusize=sum(xlong,1);
            tbl=tabulate(menusize(:));
          tblperc=tbl
          tblperc(:,2)=tblperc(:,2)/sum(tbl(:,2))
          plot(tblperc(:,1),tblperc(:,2),'k','LineWidth',1.5) 
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
              rankpercp1=tblperc;
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
                    title('Origin Time Rank of Offered Requests')
               else
                  tbl=tabulate(offeredranklong(:));
                  tblperc=tbl;
                  tblperc(:,2)=tblperc(:,2)/sum(tbl(2:21,2));%trials/n;
                  rankpercp1=tblperc;
                  if nnz(stage)==1
                      plot(tblperc(2:21,1),tblperc(2:21,2))
                      xlabel('Origin Time Rank')
                      ylabel('Percent of Scenarios Request is Offered') 
                      title('Origin Time Rank Distribution of Offered Requests')
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
                  rankpercp1=tblperc;
                  if nnz(stage)==1
                      plot(tblperc(2:21,1),tblperc(2:21,2))
                      xlabel('Request Trip Duration Rank')
                      ylabel('Percent of Scenarios Request is Offered') 
                      title('Request Trip Duration Rank Distribution of Offered Requests')
                  end
               end
               
                %%% if the rank is unpaid/paid
         elseif ranktype=='ur'
                [B,I]=sort((originlong+destlong)./triplong);
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
                  rankpercp1=tblperc;
                  if nnz(stage)==1
                      plot(tblperc(2:21,1),tblperc(2:21,2))
                      xlabel('Unpaid/Paid Rank')
                      ylabel('Percent of Scenarios Request is Offered') 
                      title('Unpaid/Paid Rank Distribution of Offered Requests')
                  end
               end
               
                %%% if the rank is new path/old path
         elseif ranktype=='nr'
                [B,I]=sort(newpathlong./OjDjgrid);
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
                  rankpercp1=tblperc;
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
                  rankpercp1=tblperc;
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
%%%%%%%%%%%%% for accepted graphs    
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
                  tbl=tabulate(acceptedranklong(:));
                  tblperc=tbl;
                  tblperc(:,2)=tblperc(:,2)/sum(tbl(2:21,2));%trials/testsamps/n;
                  rankpercp2=tblperc;
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
                    title('Origin Time Rank of Accepted Requests')
               else
                  tbl=tabulate(acceptedranklong(:));
                  tblperc=tbl;
                  tblperc(:,2)=tblperc(:,2)/sum(tbl(2:21,2));%trials/testsamps/n;
                  rankpercp2=tblperc;
                  if nnz(stage)==1
                      plot(tblperc(2:21,1),tblperc(2:21,2))
                      xlabel('Origin Time Rank of Accepted Requests')
                      ylabel('Percent of Scenarios Request is Accepted') 
                      title('Origin Time Rank Distribution of Accepted Requests')
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
                  tbl=tabulate(acceptedranklong(:));
                  tblperc=tbl;
                  tblperc(:,2)=tblperc(:,2)/sum(tbl(2:21,2));%trials/testsamps/n;
                  rankpercp2=tblperc;
                  if nnz(stage)==1
                      plot(tblperc(2:21,1),tblperc(2:21,2))
                      xlabel('Request Trip Duration Rank of Accepted Requests')
                      ylabel('Percent of Scenarios Request is Accepted') 
                      title('Request Trip Duration Rank Distribution of Accepted Requests')
                  end
               end
               
               %%% if the rank is the unpaid/paid
             elseif ranktype=='ur'
                [B,I]=sort((originlong+destlong)./triplong);
               [C,ranklong]=sort(I);
               for t=1:trials
                  acceptedranklong((t-1)*m+1:t*m,:)=testyhatlong((t-1)*m+1:t*m,:).*repmat(ranklong(:,(t-1)*n+1:t*n),1,testsamps); 
               end
               if percent==0
                    accepted=acceptedranklong(:);
                    hist(accepted(find(accepted>0)),m);
                    title('Unpaid/Paid Rank of Accepted Requests')
               else
                  tbl=tabulate(acceptedranklong(:));
                  tblperc=tbl;
                  tblperc(:,2)=tblperc(:,2)/sum(tbl(2:21,2));%trials/testsamps/n;
                  rankpercp2=tblperc;
                  if nnz(stage)==1
                      plot(tblperc(2:21,1),tblperc(2:21,2))
                      xlabel('Unpaid/Paid Rank of Accepted Requests')
                      ylabel('Percent of Scenarios Request is Accepted') 
                      title('Unpaid/Paid Rank Distribution of Accepted Requests')
                  end
               end
               
               %%% if the rank is new path/old path
             elseif ranktype=='nr'
                [B,I]=sort(newpathlong./OjDjgrid);
               [C,ranklong]=sort(I);
               for t=1:trials
                  acceptedranklong((t-1)*m+1:t*m,:)=testyhatlong((t-1)*m+1:t*m,:).*repmat(ranklong(:,(t-1)*n+1:t*n),1,testsamps); 
               end
               if percent==0
                    accepted=acceptedranklong(:);
                    hist(accepted(find(accepted>0)),m);
                    title('New Path/Old Path Rank of Accepted Requests')
               else
                  tbl=tabulate(acceptedranklong(:));
                  tblperc=tbl;
                  tblperc(:,2)=tblperc(:,2)/sum(tbl(2:21,2));%trials/testsamps/n;
                  rankpercp2=tblperc;
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
                  tbl=tabulate(acceptedranklong(:));
                  tblperc=tbl;
                  tblperc(:,2)=tblperc(:,2)/sum(tbl(2:21,2));%trials/testsamps/n;
                  rankpercp2=tblperc;
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
    
    
    
%%%%%%%%%%%% for assigned graphs    
if stage(1,3)==1
        %%% number of positive z per scenario
        if metric=='z'
            ztotal=zeros(testsamps*trials,1);
            for t=1:trials
                for k=1:testsamps
                    ztotal((t-1)*testsamps+k,1)=sum(sum(testzlong((t-1)*m+1:t*m,(k-1)*n+1:k*n)));
                end
            end
            
            unhappy=zeros(testsamps*trials,1);
            for t=1:trials
                for k=1:testsamps
                    for j=1:n
                        if sum(testzlong((t-1)*m+1:t*m,(k-1)*n+j))>0
                        unhappy((t-1)*testsamps+k,1)=unhappy((t-1)*testsamps+k,1)+1;
                        end
                    end
                end
            end

            
        if percent==0
            hist(ztotal,10)
            title('Number of Positive Zij')
        else
           tbl=tabulate(ztotal(:));
          tblperc=tbl
          tblperc(:,2)=tblperc(:,2)/sum(tbl(:,2));
          tbl2=tabulate(unhappy(:));
          max(unhappy(:))
          tblperc2=tbl2
          tblperc2(:,2)=tblperc2(:,2)/sum(tbl2(:,2));
          
          rgb=[0.8 0.8 0.8];
          plot(tblperc(:,1),tblperc(:,2),'color',rgb,'LineWidth',6) 
          hold on
          plot(tblperc2(:,1),tblperc2(:,2),'-.k','LineWidth',1.5) 
          hold on
          ylabel('Probability')
          xlabel('Count per Test Scenario')
          title('Positive \sl z_{ij}\rm\bf and Unhappy Driver Count')
          legend('Positive \sl z_{ij}','Unhappy Drivers')
          
            
        end
        
            
        %%% number of penalties per unhappy driver (when there is at least one)
        elseif metric=='u'
           
           penalties=zeros(n*testsamps*trials,1);
            for t=1:trials
                for k=1:testsamps
                    for j=1:n
                        penalties((t-1)*testsamps*n+(k-1)*n+j,1)=sum(testzlong((t-1)*m+1:t*m,(k-1)*n+j));
                    end
                end
            end
             penaltypos=penalties(find(penalties>0));
             tbl=tabulate(penaltypos);
          tblperc=tbl
          tblperc(:,2)=tblperc(:,2)/sum(tbl(:,2));
          plot(tblperc(:,1),tblperc(:,2),'k','LineWidth',1.5) 
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
               tbl=tabulate(wtotal(:));
              tblperc=tbl
              tblperc(:,2)=tblperc(:,2)/sum(tbl(:,2));
              plot(tblperc(:,1),tblperc(:,2),'k','LineWidth',1.5) 
              hold on
              ylabel('Probability')
              xlabel('Unfulfilled Requests Per Test Scenario')

            end
            
            title('Unfulfilled Requests Per Test Scenario')
        
    
        
         %%% percent of the time an item is assigned (when >0)
        elseif metric=='a'
            aveassign=aveassignlong(:);
            max(aveassign)
            aveassign=aveassign(find(xlong(:)>0));
            if percent==0
                hist(aveassign)
                
            else
                bincounts0 = histc(aveassign,0:0.1:1)
                bincounts0=bincounts0/sum(bincounts0);
                ylabel('Probability')
                xlabel('Portion of Test Scens Assigning Request \sli\rm to Driver \slj\rm (If Offered)')
                hold on
                plot(0:0.1:1,bincounts0,'k','LineWidth',1.5);
                
            end
        title('Portion of Test Scens Assigning Request \sli\rm\bf to Driver \slj\rm\bf (If Offered)')
            
            
        
        %%%% distance ranking of assigned Items (for a few different rank metrics)    
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
                  tbl=tabulate(assignedranklong(:));
                  tblperc=tbl;
                  tblperc(:,2)=tblperc(:,2)/sum(tbl(2:21,2));%trials/testsamps/n;
                  rankpercp3=tblperc;
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
                        title('Origin Time Distance Rank of Assigned Items')
                   else
                      tbl=tabulate(assignedranklong(:));
                      tblperc=tbl;
                      tblperc(:,2)=tblperc(:,2)/sum(tbl(2:21,2));%trials/testsamps/n;
                      rankpercp3=tblperc;
                      if nnz(stage)==1
                          plot(tblperc(2:21,1),tblperc(2:21,2))
                          xlabel('Origin Time Rank')
                          ylabel('Percent of Scenarios Request is Assigned') 
                          title('Origin Time Rank Distribution of Assignments')
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
                      tbl=tabulate(assignedranklong(:));
                      tblperc=tbl;
                      tblperc(:,2)=tblperc(:,2)/sum(tbl(2:21,2));%trials/testsamps/n;
                      rankpercp3=tblperc;
                      if nnz(stage)==1
                          plot(tblperc(2:21,1),tblperc(2:21,2))
                          xlabel('Request Trip Duration Rank')
                          ylabel('Percent of Scenarios Request is Assigned') 
                          title('Request Trip Duration Rank Distribution of Assignments')
                      end
                   end
                   
                   
                    %%% if the rank is unpaid/paid
             elseif ranktype=='ur'
                    [B,I]=sort((originlong+destlong)./triplong);
                   [C,ranklong]=sort(I);
                   for t=1:trials
                      assignedranklong((t-1)*m+1:t*m,:)=testvlong((t-1)*m+1:t*m,:).*repmat(ranklong(:,(t-1)*n+1:t*n),1,testsamps); 
                   end
                   if percent==0
                   assigned=assignedranklong(:);
                    hist(assigned(find(assigned>0)),m);
                    title('Paid/Unpaid Rank of Assigned Items')
                   else
                      tbl=tabulate(assignedranklong(:));
                      tblperc=tbl;
                      tblperc(:,2)=tblperc(:,2)/sum(tbl(2:21,2));%trials/testsamps/n;
                      rankpercp3=tblperc;
                      if nnz(stage)==1
                          plot(tblperc(2:21,1),tblperc(2:21,2))
                          xlabel('Unpaid/Paid Rank')
                          ylabel('Percent of Scenarios Request is Assigned') 
                          title('Unpaid/Paid Rank Distribution of Assignments')
                      end
                   end
                   
                   
            %%% if the rank is the length of the request trip
             elseif ranktype=='nr'
                    [B,I]=sort(newpathlong./OjDjgrid);
                   [C,ranklong]=sort(I);
                   for t=1:trials
                      assignedranklong((t-1)*m+1:t*m,:)=testvlong((t-1)*m+1:t*m,:).*repmat(ranklong(:,(t-1)*n+1:t*n),1,testsamps); 
                   end
                   if percent==0
                   assigned=assignedranklong(:);
                    hist(assigned(find(assigned>0)),m);
                    title('New Path/Old Path Rank of Assigned Items')
                   else
                      tbl=tabulate(assignedranklong(:));
                      tblperc=tbl;
                      tblperc(:,2)=tblperc(:,2)/sum(tbl(2:21,2));%trials/testsamps/n;
                      rankpercp3=tblperc;
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
                      tbl=tabulate(assignedranklong(:));
                      tblperc=tbl;
                      tblperc(:,2)=tblperc(:,2)/sum(tbl(2:21,2));%trials/testsamps/n;
                      rankpercp3=tblperc;
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

if nnz(stage)==3
    colors=[0 0 0;
                0.5 0.5 0.5;
                0.7 0.7 0.7];
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
            
            measurement2=Clong;
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
            
            r1 = corrcoef(yprobslong(:),Clong(:));
            r2=corrcoef(data1,data12);
            rgb=[0.7 0.7 0.7];
             scatter(data0,data02,30,rgb,'filled')
             hold on
             
             scatter(data1,data12,30,'k')
            xlabel('\sl p_{ij}')
            ylabel('\sl c_{ij}')
             title('\sl p_{ij} vs c_{ij}')
             legend('Original','Offered','Location','southeast')
             str=['r_{original}= ',num2str(round(r1(1,2),3))];
        T = text(min(get(gca, 'xlim'))+0.05, max(get(gca, 'ylim')), str); 
        set(T, 'fontsize', 14, 'verticalalignment', 'top', 'horizontalalignment', 'left');
        str2=['r_{offered}=' num2str(round(r2(1,2),3))];
        T2 = text(min(get(gca, 'xlim'))+0.05, max(get(gca, 'ylim'))-1, str2); 
        set(T2, 'fontsize', 14, 'verticalalignment', 'top', 'horizontalalignment', 'left');
        
    elseif metric=='r'
        if ranktype(1,2)=='r'
            plot(rankpercp1(2:21,1),rankpercp1(2:21,2),symbols(1,:),'color',colors(1,:),'LineWidth',1.5);
            hold on
            plot(rankpercp2(2:21,1),rankpercp2(2:21,2),symbols(2,:),'color',colors(2,:),'LineWidth',1.5);
            hold on
            plot(rankpercp3(2:21,1),rankpercp3(2:21,2),symbols(3,:),'color',colors(3,:),'LineWidth',1.5);
            ylabel("Probability")
            lg=legend('Offered','Accepted','Assigned');
        end
        if ranktype=='er'
            xlabel('Extra Driving Time Rank')
             title('Extra Driving Time Rank')
            
        elseif ranktype=='or'
            
            xlabel('Origin Time Rank')
             title('Origin Time Rank')
            
        elseif ranktype=='dr'
             xlabel('Request Trip Duration Rank')
             title('Request Trip Duration Rank')
            
        elseif ranktype=='ur'
             xlabel('Unpaid/Paid Rank')
             title('Unpaid/Paid Rank')
             
         elseif ranktype=='nr'
             xlabel('New Path/Old Path Rank')
             title('New Path/Old Path Rank')
             
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
            measurement=extralong
            size(find(extralong<0))
            data0=measurement;
            data1=measurement.*xlong;
            for t=1:trials
                data2((t-1)*m+1:t*m,:)=testyhatlong((t-1)*m+1:t*m,:).*repmat(measurement(:,(t-1)*n+1:t*n),1,testsamps); 
                data3((t-1)*m+1:t*m,:)=testvlong((t-1)*m+1:t*m,:).*repmat(measurement(:,(t-1)*n+1:t*n),1,testsamps);                  
            end
            xlabel('Extra Driving Time')
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
            xlabel('Origin Time')
             title('Origin Time')
             hold on
            
        elseif ranktype=='du'
            measurement=triplong;
            data0=measurement;
            data1=measurement.*xlong;
            for t=1:trials
                data2((t-1)*m+1:t*m,:)=testyhatlong((t-1)*m+1:t*m,:).*repmat(measurement(:,(t-1)*n+1:t*n),1,testsamps); 
                data3((t-1)*m+1:t*m,:)=testvlong((t-1)*m+1:t*m,:).*repmat(measurement(:,(t-1)*n+1:t*n),1,testsamps);                  
            end 
            xlabel('Request Trip Duration')
             title('Request Trip Duration')
             hold on
            
        elseif ranktype=='uu'
            measurement=(originlong+destlong)./triplong;
            data0=measurement;
            data1=measurement.*xlong;
            size(find(data0>30))
            for t=1:trials
                data2((t-1)*m+1:t*m,:)=testyhatlong((t-1)*m+1:t*m,:).*repmat(measurement(:,(t-1)*n+1:t*n),1,testsamps); 
                data3((t-1)*m+1:t*m,:)=testvlong((t-1)*m+1:t*m,:).*repmat(measurement(:,(t-1)*n+1:t*n),1,testsamps);                  
            end 
            xlabel('Unpaid/Paid')
             title('Unpaid/Paid')
             hold on
             
         elseif ranktype=='nu'
            measurement=newpathlong./OjDjgrid;
            size(find(measurement<1))
            data0=measurement;
            data1=measurement.*xlong;
            for t=1:trials
                data2((t-1)*m+1:t*m,:)=testyhatlong((t-1)*m+1:t*m,:).*repmat(measurement(:,(t-1)*n+1:t*n),1,testsamps); 
                data3((t-1)*m+1:t*m,:)=testvlong((t-1)*m+1:t*m,:).*repmat(measurement(:,(t-1)*n+1:t*n),1,testsamps);                  
            end
             xlabel('New Path/Old Path')
             title('New Path/Old Path')
             hold on
                         
            
        end
         if ranktype(1,2)=='u'
             colors=[0.8 0.8 0.8;
                 0 0 0;
                0.4 0.4 0.4;
                0.6 0.6 0.6];
            symbols=['-.d';':o ';'-^ ';'--+'];  
            data0long=data0(:);
            %data0long=data0long(find(data0long>0));
            data1long=data1(:);
            data1pos=data1long(find(data1long>0));
            data2long=data2(:);
            data2pos=data2long(find(data2long>0));
            data3long=data3(:);
            data3pos=data3long(find(data3long>0));
            
            if ranktype=='uu'
                percent=size(find(data0long<=20),1)/size(data0long,1)
                olddatamax=max(data0long)
                data0long=data0long(find(data0long<=20));
                data1pos=data1pos(find(data1pos<=20));
                data2pos=data2pos(find(data2pos<=20));
                data3pos=data3pos(find(data3pos<=20));
            elseif ranktype=='nu'
                percent=size(find(data0long>30),1)/size(data0long,1)*100
                olddatamax=max(data0long)
                data0long=data0long(find(data0long<=30));
                data1pos=data1pos(find(data1pos<=30));
                data2pos=data2pos(find(data2pos<=30));
                data3pos=data3pos(find(data3pos<=30));
            end
            datamin=min(vertcat(data0long,data1pos,data2pos,data3pos));
            datamax=max(vertcat(data0long,data1pos,data2pos,data3pos));
            x=[datamin:((datamax-datamin)/10):datamax];
            bincounts0 = histc(data0long,x);
            bincounts0=bincounts0/sum(bincounts0);
            plot(x,bincounts0,symbols(1,:),'color',colors(1,:),'LineWidth',1.5);
            hold on
            bincounts1 = histc(data1pos,x);
            bincounts1=bincounts1/sum(bincounts1);
            plot(x,bincounts1,symbols(2,:),'color',colors(2,:),'LineWidth',1.5);
            hold on
            bincounts2 = histc(data2pos,x);
            bincounts2=bincounts2/sum(bincounts2);
            plot(x,bincounts2,symbols(3,:),'color',colors(3,:),'LineWidth',1.5);
            hold on
            bincounts3 = histc(data3pos,x);
            bincounts3=bincounts3/sum(bincounts3);
            plot(x,bincounts3,symbols(4,:),'color',colors(4,:),'LineWidth',1.5);
            ylabel("Probability")
            lg=legend('Original','Offered','Accepted','Assigned');
        end
        
        
    end
    
    
end