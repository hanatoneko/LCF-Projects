%function[]=plot_phase0(exh,metric,extra)

%%% This code makes the plots used in the paper for the phase 0 analysis,
%%% that is, the average and maximum error of the experiments with and
%%% without exhaustive performance analysis (for a total of 4 graphs)

%the error data includes the error for each of three trials for the same test sample
% size/problem instance, and we plot either the maximum or average of the
% error of these three trials (for each test sample size/problem instance)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%To make the plots, simply adjust the values for exhaust and metric as
%desired and then run the code. The data is pasted in so would need to
%update several things to plot new data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

exhaust=1; %is 1 if exhaustive perf analysis is done, 0 if only 100,000 test scenarios are used
metric='m' %is 'a' for average error, is 'm' for maximum error, there is code for metric='t' that is some runtime 
%plots but I didn't use that code to make plots for the paper and that
%portion of the code doesn't currently work





sampsizes=[500;1000;5000;10000]; %numbers of test scenarios used
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

numsizes=size(sampsizes,1); %number of test scenario samp sizes
if metric ~= 't'
    if exhaust==1
        numprobs=3;
        numtrials=3;
        probsizes=[6;8;10];
        %the error is % error (really portion error, (opt-obj)/opt), and the row order groups by
        %trial so for example 6x6 is row 1, 4, and 7 not 1,2,3.
        error=[ 0.0239   -0.0151    0.0033   -0.0090    0.0110   -0.0088   -0.0104   -0.0082  -0.0096   -0.0080   -0.0082   -0.0086;
          -0.0191   -0.0121   -0.0202   -0.0137   -0.0201   -0.0126   -0.0187   -0.0184 -0.0172   -0.0178   -0.0189   -0.0177;
           -0.1046   -0.0955   -0.1189   -0.0981   -0.0902   -0.0831   -0.0552   -0.0555 -0.0544   -0.0298   -0.0303   -0.0297;
     -0.0253   -0.0241   -0.0346   -0.0223   -0.0174   -0.0204   -0.0067   -0.0063  -0.0063   -0.0023   -0.0024   -0.0024;
       -0.0383   -0.0256   -0.0238   -0.0235   -0.0231   -0.0252   -0.0113   -0.0082  -0.0090   -0.0039   -0.0034   -0.0036;
      0.0343    0.0421    0.0426    0.0259    0.0291    0.0264    0.0063    0.0064  0.0062    0.0018    0.0017    0.0018;
      -0.0340   -0.0255   -0.0066   -0.0169   -0.0220   -0.0196   -0.0100   -0.0088 -0.0093   -0.0017   -0.0024   -0.0022;
      -0.0025    0.0005   -0.0107   -0.0007   -0.0046   -0.0034   -0.0009   -0.0009 -0.0013   -0.0003   -0.0002   -0.0003;
       -0.0125   -0.0118   -0.0139   -0.0115   -0.0095   -0.0103   -0.0058   -0.0056 -0.0059   -0.0029   -0.0029   -0.0030];



    else
        numprobs=4;

    %         error=[   -0.0026    0.0004   -0.0000   -0.0011   -0.0002   -0.0004   -0.0001   -0.0016   -0.0007   -0.0005   -0.0012   -0.0004;
    %       -0.0020   -0.0009   -0.0008    0.0032    0.0013   -0.0022    0.0003    0.0013    0.0009   -0.0005   -0.0005   -0.0000;
    %       -0.0018   -0.0010   -0.0018    0.0009   -0.0028    0.0015   -0.0007   -0.0004    0.0009   -0.0007    0.0004   -0.0004;
    %       -0.0265   -0.0322    0.0449   -0.0277    0.0123   -0.0155   -0.0014    0.0121   -0.0026    0.0172    0.0209   -0.0157;
    %            -0.0138    0.0034   -0.0087    0.0028   -0.0040   -0.0138   -0.0002   -0.0013 0.0027   -0.0002   -0.0014   -0.0016;
    %      -0.0177   -0.0059   -0.0139   -0.0146   -0.0101   -0.0048   -0.0097   -0.0113   -0.0119   -0.0102   -0.0102   -0.0080;
    %        0.0008   -0.0032    0.0002    0.0065   -0.0005   -0.0007   -0.0001   -0.0009 0.0003    0.0001   -0.0004    0.0006;
    %       -0.0059   -0.0043    0.0032   -0.0007   -0.0038    0.0029    0.0016    0.0132  0.0070   -0.0007   -0.0003   -0.0021;
    %           -0.0056   -0.0002   -0.0025   -0.0140   -0.0012   -0.0011   -0.0009    0.0010    0.0002   -0.0012    0.0016   -0.0022;
    %      -0.0294    0.0022    0.0055   -0.0014    0.0070    0.0004    0.0013   -0.0067    0.0028    0.0065   -0.0028    0.0047;
    %      0.0138    0.0051    0.0032   -0.0025    0.0025    0.0057   -0.0010    0.0015    0.0008    0.0021    0.0003    0.0009;
    %      0.0146    0.0079    0.0165    0.0078   -0.0005   -0.0120    0.0036    0.0094    0.0000   -0.0016    0.0053    0.0043];
    if extra==0
        numtrials=3; 

        %errorfull  includes the first three columns of info which are m,
        %n, and number of nontrivial menu entries. 
       errorfull=[   20.0000   20.0000   68.0000   -0.0094   -0.0120   -0.0134    0.0304   -0.0291   -0.0081    0.0102   -0.0005    0.0236   -0.0024    0.0005    0.0097;
       20.0000   40.0000   46.0000    0.0181   -0.0025    0.0064    0.0096    0.0112    0.0024   -0.0035   -0.0071   -0.0041   -0.0015    0.0028   -0.0062;
       40.0000   20.0000   61.0000    0.0026    0.0052   -0.0021    0.0011    0.0007    0.0016    0.0000    0.0008   -0.0003   -0.0013   -0.0006    0.0003;
       40.0000   40.0000  122.0000   -0.0008    0.0100    0.0087    0.0034    0.0050   -0.0023    0.0034    0.0152   -0.0044    0.0037    0.0033    0.0016;
     20.0000   20.0000   55.0000   -0.0142    0.0490   -0.0152   -0.0037   -0.0044   -0.0086   -0.0001    0.0100    0.0061    0.0027   -0.0021    0.0060;
       20.0000   40.0000   29.0000    0.0065    0.0045   -0.0034    0.0040    0.0038   -0.0008   -0.0012   -0.0012    0.0010    0.0007   -0.0007   -0.0000;
       40.0000   20.0000   54.0000   -0.0063    0.0131    0.0095   -0.0049   -0.0048    0.0021    0.0025   -0.0018   -0.0029    0.0023    0.0020    0.0011;
       40.0000   40.0000  121.0000   -0.0014    0.0223   -0.0026   -0.0002    0.0104    0.0075   -0.0023    0.0029    0.0014   -0.0011   -0.0004   -0.0017;
    20.0000   20.0000   61.0000   -0.0081    0.0307    0.0452    0.0118   -0.0043   -0.0137   -0.0007   -0.0072   -0.0022   -0.0050  -0.0013   -0.0010;
       20.0000   40.0000   28.0000    0.0028    0.0010   -0.0061   -0.0013   -0.0012    0.0030   -0.0042   -0.0033   -0.0001   -0.0012  -0.0010   -0.0014;
       40.0000   20.0000   71.0000   -0.0025   -0.0099   -0.0014   -0.0033   -0.0029   -0.0012   -0.0018   -0.0006   -0.0038   -0.0025  -0.0034   -0.0020;
       40.0000   40.0000  108.0000   -0.0052   -0.0081   -0.0060    0.0268    0.0018   -0.0042   -0.0024   -0.0044   -0.0018    0.0020 -0.0018    0.0035];

      error=errorfull(:,4:15);
    else
        numtrials=40;
        load('C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_0\phase040x40t40inst1randnewgen')
        error=newpercerror(:,4:163);
        load('C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_0\phase040x40t40inst2randnewgen')
        error=vertcat(error,newpercerror(:,4:163));
        load('C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_0\phase040x40t40inst3randnewgen')
        error=vertcat(error,newpercerror(:,4:163));
    end
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Some setup
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %set the plot line colors and line/marker style
    if numprobs==3

         colors=vertcat(yellow,red,blue);
        symbols=[':< ';'-* ';'--x'];
    else
         colors=vertcat(green,purple,orange,blue);
        symbols=[':o ';'-^ ';'--+';'-.d'];            
    end

    %%% the error data includes the error for each of three trials for the same test sample
    % size/problem instance, and here we calculate either the maximum or average of
    % these three trials to plot (for each test sample size/problem instance)
    abserror=100*abs(error)
    errormax=zeros(3*numprobs,4);
    errorave=zeros(3*numprobs,4);

    for i=1:4
        errormax(:,i)=max(abserror(:,(i-1)*numtrials+1:numtrials*i),[],2);
        errorave(:,i)=mean(abserror(:,(i-1)*numtrials+1:numtrials*i),2);
    end 
    errormax


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % make the plots
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if metric=='m'
        if exhaust==0
            title('Test Scenario Sample Size Max Error w/o Exhaustive')
            ylabel('Max Abs % Error from Perf Est')
        else
            title('Test Scenario Sample Size Max Error w/ Exhaustive')
            ylabel('Max Abs % Error from True Perf')
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
       if exhaust==0
            title('Test Scenario Sample Size Ave Error w/o Exhaustive')
            ylabel('Ave Abs % Error from Perf Est')
        else
            title('Test Scenario Sample Size Ave Error w/ Exhaustive')
            ylabel('Ave Abs % Error from True Perf')
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
    if exhaust==1
         legend('6\times6','8\times8','10\times10')
    else
        legend('20\times20','20\times40','40\times20','40\times40')
    end        

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %end of useful code
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif metric=='t'
    load('C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_0\phase0totwexhinst1rand')
    timeswexhfull1=times;
    load('C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_0\phase0totwexhinst2rand')
    timeswexhfull2=times;
    load('C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_0\phase0totwexhinst3rand')
    timeswexhfull3=times;

    load('C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_0\phase0totnoexhinst1randnewgen')
    timesnoexhfull1=times;
    load('C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_0\phase0totnoexhinst2randnewgen')
    timesnoexhfull2=times;
    load('C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_0\phase0totnoexhinst3randnewgen')
    timesnoexhfull3=times;

    timesfull=vertcat(timeswexhfull1,timeswexhfull2,timeswexhfull3, timesnoexhfull1, timesnoexhfull2, timesnoexhfull3);

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
    numsizes=4;
    timeaves=zeros(3*7,numsizes+3);
    timeaves(:,2:3)=timesperm(:,3:4);

    for s=1:numsizes
        timeaves(:,3+s)=mean(timesperm(:,(s-1)*numtrials+5:numtrials*s+4),2);
    end

    timeaves(:,1)=repmat([1;2;3],7,1);
    timeaves

    wexttimes=[0.015	0.9378	0.0149	0.015	0.0148	0.0282	0.0283	0.0286	0.1448	0.1399	0.1464	0.295	0.2901	0.2827;
    0.018	9.3305	0.0189	0.0187	0.0178	0.0365	0.0394	0.0376	0.186	0.1873	0.1853	0.3609	0.3585	0.3586;
    0.015	0.9902	0.0181	0.0177	0.018	0.0354	0.037	0.0351	0.172	0.1695	0.1709	0.3424	0.3357	0.3406;
    0.015	0.955	0.0175	0.018	0.0171	0.0349	0.0333	0.0346	0.1579	0.1592	0.1625	0.313	0.3129	0.3099;
    0.016	1.5964	0.0116	0.012	0.0121	0.0232	0.0238	0.0235	0.1218	0.1249	0.1231	0.2448	0.2442	0.2409;
    0.015	0.8458	0.0096	0.0104	0.0098	0.0203	0.0226	0.0214	0.1066	0.1087	0.1072	0.2261	0.2251	0.223;
    0.014	0.6999	0.0232	0.0242	0.0234	0.0475	0.0455	0.048	0.2252	0.2254	0.2218	0.4307	0.4477	0.4656;
    0.014	0.7103	0.0202	0.0214	0.0223	0.0425	0.0415	0.0436	0.2141	0.219	0.2149	0.4491	0.45	0.4582;
    0.017	3.6456	0.0173	0.0171	0.02	0.0347	0.0339	0.0333	0.1778	0.1873	0.1839	0.35	0.3605	0.3573];

end

  
   

  
   
  
