%function[]=plot_phase1(exh,metric)

%%% This code makes the plots used in the paper for the phase 1 analysis,
%%% that is, the average and maximum error of the experiments with and
%%% without exhaustive performance analysis, including the zoomed in version for 
%%% the without exhaustive graphs (for a total of 6 graphs)

%the error data includes the error for each of three menus made for the same saa sample
% size/problem instance, and we plot either the maximum or average of the
% error of these three trials (for each saa sample size/problem instance)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%To make the plots, simply adjust the values for exhaust, metric, and zoom as
%desired and then run the code. The data is pasted in so would need to
%update several things to plot new data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


exh=0;  %is 1 if error is found by comparing to optimal menu, is 0 if is compared to best-found
metric='m'; %is 'a' for average error, is 'm' for maximum error, there is code for metric='t' that is some runtime 
%plots but I didn't use that code to make plots for the paper and that
%portion of the code doesn't currently work 
zoom=1; %is only used when exh=0, if zoom=1 the plot will only include the saa sample sizes 10, 50, and 100, 
%i.e. 'zooming in' so the relative detail can be seen for the small sample
%sizes. If zoom=0 then the plot includes all saa sample sizes


sampsizes=[10;50;100;500;1000]; % saa sample sizes
extra=0; %include extra trials from phase0_extra_trials (I put that file 
%in inactive code since we don't end up using the extra trials but that code probably works)
    
    
%%% decides the size and location in which the graph is made on the screen, first two digits are the (pixel?) coordinates of
%%% the top left corner, then 3rd and 4th numbers are the (pixel?) width and hieght respectively
 figure('Renderer', 'painters', 'Position', [300 300 400 250])
%figure('Renderer', 'painters', 'Position', [300 300 600 350])

%%% rgb of some rainbow colors
red=[0.6350 0.0780 0.1840];
orange=[0.8500 0.3250 0.0980];
yellow=[0.9290 0.6940 0.1250];
green=[0.4660 0.6740 0.1880];
blue=[0 0.4470 0.7410];
purple=[0.4940 0.1840 0.5560];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load in error data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if metric~='t'   
        numsizes=4;
    if exh==1
        numprobs=3;
        trials=3;
        probsizes=[4;5;6];
        if extra==0
            numtrials=3;
            
%             error=[   0.0748    0.1238    0.1550    0.2228         0    0.2137    0.2228    0.0748    0.0748    0.0748  0.0748    0.0748    0.0748    0.0748    0.0748    1.0000    1.0000    1.0000;
%            0.1030    0.0806    0.0806    0.0500    0.0500    0.0423    0.0500    0.0500    0.0500    0.0423 0.0423    0.0423    0.0423    0.0423    0.0423    1.0000    1.0000    1.0000;
%             0.1388    0.1043    0.2776    0.0343    0.0429    0.1184    0.0404    0.0404    0.0839    0.0058 0.0058    0.0058    0.0058    0.0058    0.0058    1.0000    1.0000    1.0000;
%          0.1899    0.2604    0.2864    0.2887    0.1672    0.1866    0.1874    0.1866    0.1866    0.1866 0.1866    0.1866    0.1866    0.1866    0.1866    1.0000    1.0000    1.0000;
%        0.0751    0.0146    0.0100    0.0100    0.0456    0.0100    0.0100    0.0100    0.1066    0.0100 0.0100    0.0100    0.0100    0.0100    0.0100    1.0000    1.0000    1.0000;
%           0.0396    0.0461    0.0535    0.0201    0.0262    0.0288    0.0288    0.0288    0.0288    0.0288 0.0288    0.0288    0.0288    0.0288    0.0288    0.0006    0.0006    0.0006;
%        0.2906    0.1661    0.2469    0.2469    0.1661    0.1661    0.1661    0.1661    0.1661    0.1661    0.1661    0.1661    0.1661    0.1661 0.1661    1.0000    1.0000    1.0000;
%        0.1303    0.1604    0.1470    0.1159    0.1528    0.1276    0.0353    0.1528    0.1276    0.1276    0.1159    0.0977    0.0977    0.0977 0.0977    0.0977    0.1276    0.1276;
%         0.0678    0.0547    0.0810    0.0678    0.0831    0.0678    0.0052    0.0678    0.0678    0.0052    0.0052    0.0052    0.0052    0.0052 0.0052    1.0000    1.0000    1.0000];
       

%the error is % error (really portion error, (opt-obj)/opt), and the row order groups by
        %trial so for example 4x4 is row 1, 4, and 7 not 1,2,3.
  error=[0.0357	0.1375	0.3991	0.1375	0.1375	0.1375	0.0799	0.1375	0.1375	0.1375	0.1375	0.1375	0.1375	0.1375	0.1375  -1 -1 -1;
    0.0699	0.1682	0.1682	0	0.0241	0	0.0241	0.0767	0	0	0	0	0	0  0 -1 -1 -1;
    0.1505	0.0734	0.0711	0.1593	0.0648	0.0877	0.053	0.0648	0.0871	0.0667	0.053	0.053	0.053	0.053	0.053  -1 -1 -1;
       0.1899    0.2604    0.2864    0.2887    0.1672    0.1866    0.1874    0.1866    0.1866    0.1866 0.1866    0.1866    0.1866    0.1866    0.1866    1.0000    1.0000    1.0000;
       0.0751    0.0146    0.0100    0.0100    0.0456    0.0100    0.0100    0.0100    0.1066    0.0100 0.0100    0.0100    0.0100    0.0100    0.0100    1.0000    1.0000    1.0000;
          0.0396    0.0461    0.0535    0.0201    0.0262    0.0288    0.0288    0.0288    0.0288    0.0288 0.0288    0.0288    0.0288    0.0288    0.0288    0.0006    0.0006    0.0006;
       0.2906    0.1661    0.2469    0.2469    0.1661    0.1661    0.1661    0.1661    0.1661    0.1661    0.1661    0.1661    0.1661    0.1661 0.1661    1.0000    1.0000    1.0000;
       0.1303    0.1604    0.1470    0.1159    0.1528    0.1276    0.0353    0.1528    0.1276    0.1276    0.1159    0.0977    0.0977    0.0977 0.0977    0.0977    0.1276    0.1276;
        0.0678    0.0547    0.0810    0.0678    0.0831    0.0678    0.0052    0.0678    0.0678    0.0052    0.0052    0.0052    0.0052    0.0052 0.0052    1.0000    1.0000    1.0000];
        else
            numtrials=40;

            load('C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_1\phase16x6inst1extra')
            error=newpercerror(:,4:end);
            load('C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_1\phase16x6inst1extra')
            error=vertcat(error,newpercerror(:,4:end));
            load('C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_1\phase16x6inst1extra')
            error=vertcat(error,newpercerror(:,4:end));
        end

    else
        numprobs=4;
        numtrials=3;
        trials=3;
        %this first error set would have problems terminate early to save
                %time
        %         error=[    0.0086    0.0929    0.0089    0.0001    0.0002    0.0003    0.0518    0 0.0430    0.0036    0.0613    0.1780    0.2482    0.2928    0.1091    1.0000    1.0000    1.0000;
        %      0.0901    0.1345    0.1331    0.1471    0.0459    0.0267    0.0215    0.0241 0    0.8369    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000;
        %    0.0476    0.0627    0.0323    0.0012    0.0050    0.0070    0.0016    0.0137 0.0067    0.0030    0.0000    0.0020    0.0637    0.0128         0    1.0000    1.0000    1.0000;
        %      0.0129    0.0059    0.0050    0.0002    0.0121    0.0035    0.0515    0.0071 0    0.9596    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000;
        %   0.0573    0.1020    0.0672    0.0180    0.0102    0.0097    0.0107         0 0.0071    0.0140    0.0181    0.0251    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000;
        %   0.1086    0.0625    0.1211    0.0022    0.0361    0.0040    0.0146    0.0117 0    0.0520    0.8893    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000;
        %   0.0125    0.0964    0.1798    0.0068    0.0253    0.0041    0.0273    0.0038 0.0312    0.0029    0.0013    0.0019    0.0005    0.0019         0    1.0000    1.0000    1.0000;
        %    0.0969    0.1535    0.0336    0.0866    0.0809         0    0.0595    0.0086    0.0008    0.2610    0.0080    0.9914    1.0000    1.0000 1.0000    1.0000    1.0000    1.0000;
        %  0.0217    0.0095    0.0297         0    0.0006    0.0016    0.0001    0.0007  0.0016    0.0015    0.0180    0.0002    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000;
        %   0.0642    0.0189    0.0330    0.0151         0    0.0243    0.0017    0.0030 0.0106    0.9637    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000;
        %   0.0164    0.0759    0.0628         0    0.0383    0.0039    0.0093    0.0056  0.0327    0.0033    0.0308    0.0070    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000;
        %   0.0226    0.0314    0.0083    0.0012    0.0010    0.0002    0.0050    0.0017  0.0001    0.0001    0.0014    0.0022         0    0.9501    1.0000    1.0000    1.0000    1.0000];

        %errorfull  includes the first three columns of info which are m, n, and number of nontrivial pij entries (<1 and >0).
        errorfull=[20	20	206	0.1437	0.0934	0.1318	0.0062	0.1074	0	0.0322	0.0049	0.012	0.0688	0.1314	0.0859	0.3016	0.2056	0.3101;
        20	40	484	0.067	0.0625	0.0398	0.0139	0.0139	0.021	0.0155	0.0022	0.0211	0.0246	0	0.0066	0.9903	0.9999	0.985;
        40	20	430	0.0216	0.0221	0.0133	0.0132	0.0107	0.0101	0.007	0.0026	0.007	0.0051	0.0009	0.002	0.0016	0	0.0045;
        40	40	907	0.0513	0.1104	0.0146	0.0147	0.0245	0.0218	0.0122	0.0355	0	0.9389	0.2802	0.9186	0.9694	0.2868	0.4515;
        20	20	268	0.0107	0.1245	0.0387	0.0056	0	0.0163	0.0156	0.0084	0.0131	0.0387	0.0317	0.0442	0.2287	1	0.1599;
        20	40	560	0.0684	0.142	0.1416	0	0.0755	0.1064	0.0273	0.0333	0.0148	0.0099	0.9034	0.8963	1	0.995	1;
        40	20	393	0.0673	0.0304	0.0163	0.0411	0.007	0.0211	0.0124	0.0112	0.0121	0.0036	0	0.0072	0.9546	0.9999	0.9999;
        40	40	811	0.031	0.1094	0.0949	0.0583	0.0675	0.0552	0.0435	0.053	0	0.0321	0.0521	0.0541	0.99	0.9617	0.4268;
        20	20	259	0.0046	0.0008	0.0016	0.0131	0.0035	0.0006	0.0037	0.0005	0.0017	0.0002	0.0003	0.0027	0.0005	0	0.0004;
        20	40	419	0.056	0.0753	0.0368	0.0098	0	0.0033	0.0175	0.0129	0.0053	0.0144	0.0005	0.0004	0.9999	0.9999	1;
        40	20	493	0.0136	0.0205	0.046	0.0049	0.0121	0.008	0.0049	0.0035	0.0034	0.0023	0.0036	0	0.9745	0.972	0.9993;
        40	40	951	0.0093	0.0118	0.0687	0.0938	0.0449	0.0244	0.0441	0.0929	0.0231	0.0435	0.0307	0	0.0401	0.0633	0.1682];

        error=errorfull(:,4:18);


    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Some setup
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %set the plot line colors and line/marker style      
    if numprobs==3
        colors=vertcat(red,purple,yellow);
        symbols=['-.s';'-p ';':< '];  
    else
        colors=vertcat(green,purple,orange,blue);
        symbols=[':o ';'-^ ';'--+';'-.d'];  
    end

    %the error data includes the error for each of three menus made for the same saa sample
    % size/problem instance, and  here we calculate the maximum and average of the
    % error of these three trials (for each saa sample size/problem instance)

    abserror=100*abs(error)
    errormax=zeros(3*numprobs,5);
    errorave=zeros(3*numprobs,5);
    mean(mean(errorave))
    mean(mean(errormax))
    for i=1:5
        errormax(:,i)=max(abserror(:,(i-1)*trials+1:trials*i),[],2);
        errorave(:,i)=mean(abserror(:,(i-1)*trials+1:trials*i),2);
    end 

    %%% some bonus calculations of average error across sizes etc
     mean(mean(errorave))
    mean(mean(errormax))
    errormax
    errorave
    erroraveave=zeros(numprobs,5);
    for i=1:numprobs
        erroraveave(i,:)=(errorave(i,:)+errorave(numprobs+i,:)+errorave(2*numprobs+i,:))/3;
    end
    erroraveave

    %%% adjust for zoom if needed
    if zoom ==1
        errormax=errormax(:,1:3);
        errorave=errorave(:,1:3);
        sampsizes=[10;50;100];
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % make the plots
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if metric=='m'
        if exh==0
            if zoom==1


                title('SAA Scen Sample Size (when \leq 100) Max Err w/o Exh')
            else
                title('SAA Scenario Sample Size Max Error w/o Exhaustive')
            end
        ylabel('Max Abs % Err from Best-Fnd Soln')
        else
       title('SAA Scenario Sample Size Max Error w/ Exhaustive')
       ylabel('Max Abs % Error from Optimal Soln')
        end
        xlabel('Sample Size')

        for s=1:numprobs
            for t=1:3
            hold on
            h=plot(sampsizes,errormax((t-1)*numprobs+s,:)',symbols(s,:),'color',colors(s,:),'LineWidth',2);
            if t>1
                h.Annotation.LegendInformation.IconDisplayStyle = 'off';
            end
            end
        end
    else
        if exh==0
            if zoom==1
                 title('SAA Scen Sample Size (when \leq 100) Ave Err w/o Exh')
             else
                    title('SAA Scenario Sample Size Ave Error w/o Exhaustive')
                end
        ylabel('Ave Abs % Err from Best-Fnd Soln')
        else
        title('SAA Scenario Sample Size Ave Error w/ Exhaustive')
        ylabel('Ave Abs % Error from Opt Soln')
        end
        xlabel('Sample Size')

        for s=1:numprobs
            for t=1:3
            hold on
            h=plot(sampsizes,errorave((t-1)*numprobs+s,:)',symbols(s,:),'color',colors(s,:),'LineWidth',2);
            if t>1
                h.Annotation.LegendInformation.IconDisplayStyle = 'off';
            end
            end
        end
    end
    if exh==1
         lg=legend('4\times4','5\times5','6\times6');
         %lg.Location='best'
    else
        lg=legend('20\times20','20\times40','40\times20','40\times40');
        if zoom==0
            lg.Location='northwest';
        end
    end 

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %end of useful code
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif metric=='t'
    load('C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_1\phase1totwexhinst1rerun')
    timeswexhfull1=times;
    load('C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_1\phase1totwexhinst2')
    timeswexhfull2=times;
    load('C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_1\phase1totwexhinst3')
    timeswexhfull3=times;
   
    load('C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_1\phase1totnoexhinst1nostop')
    timesnoexhfull1=times;
    load('C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_1\phase1totnoexhinst2nostop')
    timesnoexhfull2=times;
    load('C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_1\phase1totnoexhinst3nostop')
    timesnoexhfull3=times;
   
    timesfull=vertcat(timeswexhfull1(:,1:19),timeswexhfull2(:,1:19),timeswexhfull3(:,1:19), timesnoexhfull1(:,1:19), timesnoexhfull2(:,1:19), timesnoexhfull3(:,1:19));
    
    timesperm=zeros(size(timesfull));
    %%% rearrange/permute rows so that they're grouped by sizes
    %%% for the small problems
    numprobs=3;
    for i=1:3
        for sizes=1:numprobs
            timesperm((sizes-1)*3+i,:)=timesfull((i-1)*numprobs+sizes,:);
        end
    end
    
    %%% for the large problems
    numprobs=4;
    for i=1:3
        for sizes=1:numprobs
            timesperm(size(timeswexhfull1,1)*3+(sizes-1)*3+i,:)=timesfull(size(timeswexhfull1,1)*3+(i-1)*numprobs+sizes,:);
        end
    end
    
    numtrials=3;
    numsizes=5;
    timeaves=zeros(3*7,numsizes+3);
    timeaves(:,2:3)=timesperm(:,3:4);
    
    for s=1:numsizes
        timeaves(:,3+s)=mean(timesperm(:,(s-1)*numtrials+5:numtrials*s+4),2);
    end
  
    timeaves(:,1)=repmat([1;2;3],7,1);
    timeaves
timemin=[];
    timemax=[];
    
end

  
   

  
   
  
