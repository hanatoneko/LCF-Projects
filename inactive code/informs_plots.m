%load('C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Paper_experiments\informs_exp.mat');
%load('C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Paper_experiments\informs_heur.mat');
% 
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
%     

compinmenu=ubestlong+alphavalslong;
 percoffered=(ubestlong+alphavalslong)./farelong;
 
offeredlong=zeros(m,trials);
fareshort=zeros(m,trials);
menusizeslong=zeros(1,n*trials);
menusizeslong_incl=zeros(1,n*trials);

for t=1:trials
    offeredlong(:,t)=sum(xbestlong(:,(t-1)*n+1:t*n),2);
    menusizeslong(1,(t-1)*n+1:n*t)=sum(xbestlong(:,(t-1)*n+1:t*n),1);
    if nnz(xbestlong(:,(t-1)*n+1:t*n))>0
        menusizeslong_incl(1,(t-1)*n+1:n*t)=sum(xbestlong(:,(t-1)*n+1:t*n),1);
    else
        menusizeslong_incl(1,(t-1)*n+1:n*t)=sum(x_slsf(:,(t-1)*n+1:t*n),1);
    end
    fareshort(:,t)=farelong(:,t*n);
end
mean(menusizeslong_incl)
tabulate(menusizeslong_incl)
%hist(fareshort)
%mincomplong=max(ones(m
maxreqcomp=zeros(m,trials);
minreqcomp=-1*ones(m,trials);
meanreqcomp=zeros(m,trials);
maxdriv_perccomp=zeros(1,n*trials);
mindriv_perccomp=zeros(1,n*trials);
testobjave_lcf_incl=testobjave_lcf;
testrejave_lcf_incl=testrejave_lcf;
runtimes_lcf_incl=runtimes(1,:);
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% fare vs percent comp
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     blue=[0 0.4470 0.7410,0.5];
%     plot(farelong(ubestlong>0),compinmenu(ubestlong>0)./farelong(ubestlong>0),'.','MarkerSize',15,'color',blue)
%     hold on
%     %%% fare vs max allowed comp
%     [fareincr,fareind]=sort(farelong(ubestlong>0));
%     max_comp_allowed=alphavalslong(ubestlong>0)+betavalslong(ubestlong>0);
%     max_compperc_allowed=(alphavalslong(ubestlong>0)+betavalslong(ubestlong>0))./farelong(ubestlong>0);
%     
%     orange=[0.8500 0.3250 0.0980,0.6];
%     plot(fareincr,max_compperc_allowed(fareind),'-','LineWidth',4,'color',orange)
%     hold on
%     
%     %%% fare vs min allowed comp
%     yellow=[0.9290 0.6940 0.1250,0.8];
%     green=[0.4660 0.6740 0.1880,1];
%     mincurvey=horzcat(4*ones(1,201)./[3:0.01:5],0.8*ones(1,4000));
%     plot([3:0.01:45],mincurvey,'-','LineWidth',4,'color',yellow)
%     hold on
%        xlabel('Fare (dollars)')
%       ylabel('Portion of Fare Offered')
%     title('Portion of Fare Offered to a Driver')
%     legend('Offered','Maximum','Minimum')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% fare vs comp
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     blue=[0 0.4470 0.7410,0.5];
%     plot(farelong(ubestlong>0),compinmenu(ubestlong>0),'.','MarkerSize',15,'color',blue)
%     hold on
%     %%% fare vs max allowed comp
%     [fareincr,fareind]=sort(farelong(ubestlong>0));
%     max_comp_allowed=alphavalslong(ubestlong>0)+betavalslong(ubestlong>0);
%     max_compperc_allowed=(alphavalslong(ubestlong>0)+betavalslong(ubestlong>0))./farelong(ubestlong>0);
%     
%     orange=[0.8500 0.3250 0.0980,0.6];
%     plot(fareincr,max_comp_allowed(fareind),'-','LineWidth',4,'color',orange)
%     hold on
%     
%     %%% fare vs min allowed comp
%     yellow=[0.9290 0.6940 0.1250,0.8];
%     green=[0.4660 0.6740 0.1880,1];
%     mincurvey=horzcat(4*ones(1,201),0.8*[5.01:0.01:45]);
%     plot([3:0.01:45],mincurvey,'-','LineWidth',4,'color',yellow)
%     hold on
%        xlabel('Fare (dollars)')
%       ylabel('Offer (dollars)')
%     title('Compensation Offer to a Driver')
%     legend('Offered','Maximum','Minimum')

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% fare (incl booking fee) vs comp
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     blue=[0 0.4470 0.7410,0.5];
%     farelong_incl=farelong+1.85*ones(m,n*trials);
%     plot(farelong_incl(ubestlong>0),compinmenu(ubestlong>0),'.','MarkerSize',15,'color',blue)
%     hold on
%     %%% fare vs max allowed comp
%     [fareincr,fareind]=sort(farelong_incl(ubestlong>0));
%     max_comp_allowed=alphavalslong(ubestlong>0)+betavalslong(ubestlong>0);
%     max_compperc_allowed=(alphavalslong(ubestlong>0)+betavalslong(ubestlong>0))./farelong(ubestlong>0);
%     
%     orange=[0.8500 0.3250 0.0980,0.6];
%     plot(fareincr,max_comp_allowed(fareind),'-','LineWidth',4,'color',orange)
%     hold on
%     
%     %%% fare vs min allowed comp
%     yellow=[0.9290 0.6940 0.1250,0.8];
%     green=[0.4660 0.6740 0.1880,1];
%     mincurvey=horzcat(4*ones(1,201),0.8*[5.01:0.01:45]);
%     plot([4.85:0.01:46.85],mincurvey,'-','LineWidth',4,'color',yellow)
%     hold on
%     
%     plot([4.85:0.01:46.85],[4.85:0.01:46.85],'-','LineWidth',2,'color',green)
%     hold on
%        xlabel('Fare (dollars)')
%       ylabel('Offer (dollars)')
%     title('Compensation Offers to Drivers')
%     legend('Offered','Maximum','Minimum','Fare=Comp')

%%%%%%%%%%%%%%%%%%
%%%% expected driver income
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% exp_income_clos5=zeros(1,n*trials);
% exp_income_lik5=zeros(1,n*trials);
% exp_income_slsf=zeros(1,n*trials);
% exp_income_lcf=zeros(1,n*trials);
% for t=1:trials
%    for j=1:m
%       for k=1:5000
%           exp_income_clos5(1,(t-1)*n+j)=exp_income_clos5(1,(t-1)*n+j)+sum(testscenprobs_clos5(t,k)*testv_clos5((t-1)*m+1:t*m,(k-1)*n+j).*slsfcomplong(:,(t-1)*n+j));
%            exp_income_lik5(1,(t-1)*n+j)=exp_income_lik5(1,(t-1)*n+j)+sum(testscenprobs_lik5(t,k)*testv_slsf((t-1)*m+1:t*m,(k-1)*n+j).*slsfcomplong(:,(t-1)*n+j));
%             exp_income_slsf(1,(t-1)*n+j)=exp_income_slsf(1,(t-1)*n+j)+sum(testscenprobs_slsf(t,k)*testv_slsf((t-1)*m+1:t*m,(k-1)*n+j).*slsfcomplong(:,(t-1)*n+j));
%           if testobjave_lcf(1,t)>0
%               exp_income_lcf(1,(t-1)*n+j)=exp_income_lcf(1,(t-1)*n+j)+sum(testscenprobs_lcf(t,k)*testv_lcf((t-1)*m+1:t*m,(k-1)*n+j).*compinmenu(:,(t-1)*n+j));
%           else
%               %exp_income_lcf(1,(t-1)*n+j)=-1;
%               exp_income_lcf(1,(t-1)*n+j)=exp_income_slsf(1,(t-1)*n+j);
%           end
%           
%       end
%    end
% end
% histogram(exp_income_slsf,10)
% hold on
% histogram(exp_income_lcf,10)
% xlabel("A Driver's Expected Income")
% ylabel("Count")
% title("Frequency of a Driver's Expected Income")
% legend('SLSF (fixed comp)','LCF-IT (vari comp)')
% 
% mean(exp_income_clos5)
% mean(exp_income_lik5)
% mean(exp_income_slsf)
% mean(exp_income_lcf)



%%%%%% cdf's of the different methods
mean(testobjave_clos5)
mean(testobjave_lik5)
mean(testobjave_slsf)
mean(testobjave_lcf_incl)

mean(testrejave_clos5)
mean(testrejave_lik5)
mean(testrejave_slsf)
mean(testrejave_lcf_incl)

mean(avetotprofit_clos5)
mean(avetotprofit_lik5)


mean(runtimes_clos5)
mean(runtimes_lik5)
mean(runtimes_slsf)
mean(runtimes_lcf_incl)
%cdf_slsf=evcdf(testobjave_slsf,[minobj:0.1:maxobj]);
%cdf_lcf=evcdf(testobjave_lcf,[minobj:0.1:maxobj]);
%cdf_clos5=evcdf(testobjave_clos5,[minobj:0.1:maxobj]);
%cdf_lik5=evcdf(testobjave_lik5,[minobj:0.1:maxobj]);


cdfplot(testobjave_clos5)
hold on
cdfplot(testobjave_lik5)
hold on
cdfplot(testobjave_slsf)
hold on
cdfplot(testobjave_lcf_incl)
hold on
legend('Clos5','Lik5','SLSF','LCF-IT')
xlabel('Objective Estimate')
ylabel('Probability')
title('CDF of Objective Estimates')
