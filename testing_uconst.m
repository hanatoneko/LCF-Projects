%this code was originally made to test the create_uconst code to make sure
%the fairness constraints were being created correctly, then this file also
%ended up being used to run all of the commands that do all of the SOL-FR
%experiments

% needload = 0;
% if needload == 1
%     
%     [arcdata,dem]=loadchicago_regional_proper();
%     [miles,mins]=loadtripinfo();
%     tripinfo=cat(3,miles,mins);
%     load('C:\Users\horneh\Documents\LCF_Paper_experiments\parameter_values\paramandslsf.mat');
%     load('C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Paper_experiments\concat_vals.mat')
% end
% 
% 
% % x = [1,0,1,1;
% %     0,1,1,0;
% %     1,1,1,1];
% m = 20;
% n = 20;
% trials = 100;
% % alphavals = [1 2 3 4;
% %             5 6 7 8;
% %             5 6 7 8];
% 
% eqtype = 'dp';
% drivprox_thresh = 5;
% reqprox_thres = 10; %(not using)
% reqdist_buffer = 3;
% 
% % [arcdata,dem]=loadchicago_regional_proper();
% % 
% % %[arcdata,dem]=loadchicagocenter(); 
% % 
% % %%% draw OD pairs
% % [rtripindex] = randsample(size(dem,1),m,true,dem(:,3));
% % Oi=arcdata(dem(rtripindex,1));
% % Di=arcdata(dem(rtripindex,2));
% % [dtripindex] = randsample(size(dem,1),n,true,dem(:,3));
% % Oj=arcdata(dem(dtripindex,1));
% % Dj=arcdata(dem(dtripindex,2));
% % 
% % 
% % 
% % 
% % %distance drivers are from each other first entry is miles, second is minutes
% % OjOk=permute(tripinfo(Oj,Oj,:),[2 1 3]);
% % %time it takes to travel from origin of col a to row b
% % OjOkmins=OjOk(:,:,2);
% % OkOjmins=OjOkmins';
% % (OjOkmins+OkOjmins)/2;
% % 
% % %distance drivers are from each other first entry is miles, second is minutes
% % OjOi=permute(tripinfo(Oj,Oi,:),[2 1 3]);
% % %time it takes to travel from origin of col a to row b
% % OjOimins=OjOi(:,:,2);
% 
% driverparams = 0;
% DensityAve = zeros(1,4);
% 
% for t = 1:trials
%     %[uconst,rhsconst] = create_uconst(x,eqtype,drivprox_thresh,reqprox_thres,reqdist_buffer,Oj,Dj,Oi,Di,alphavals,mins,driverparams)
%     [uconst,rhsconst] = create_uconst(xbest_lcf_it_bestperf(:,(t-1)*n+1:t*n),eqtype,drivprox_thresh,reqprox_thres,reqdist_buffer,Ojlong(:,t),Djlong(:,t),Oilong(:,t),Dilong(:,t),alphavalslong(:,(t-1)*n+1:t*n),mins,driverparams);
%     % OjOimins
%     % horzcat(uconst,rhsconst)
% 
%     [DensityNums] = calculate_density(xbest_lcf_it_bestperf(:,(t-1)*n+1:t*n),eqtype,uconst)
%   
%     DensityAve = DensityAve + DensityNums;
% end
% 
% DensityAve/trials

% lcf_exp_eq_noperf(1,0.875*ones(20,20),'87',5,5,'eq',0,'')
% lcf_exp_eq_noperf(2,0.875*ones(20,20),'87',5,5,'eq',0,'')
% lcf_exp_eq_noperf(3,0.875*ones(20,20),'87',5,5,'eq',0,'')
% lcf_exp_eq_noperf(4,0.875*ones(20,20),'87',5,5,'eq',0,'')
% lcf_exp_eq_noperf(5,0.875*ones(20,20),'87',5,5,'eq',0,'')
% lcf_exp_eq_noperf(6,0.875*ones(20,20),'87',5,5,'eq',0,'')
% lcf_exp_eq_noperf(7,0.875*ones(20,20),'87',5,5,'eq',0,'')
% lcf_exp_eq_noperf(8,0.875*ones(20,20),'87',5,5,'eq',0,'')
% lcf_exp_eq_noperf(9,0.875*ones(20,20),'87',5,5,'eq',0,'')
% lcf_exp_eq_noperf(10,0.875*ones(20,20),'87',5,5,'eq',0,'')
% lcf_exp_eq_bestperf(10,0.875*ones(20,20),'87',5,5,'eq',0,'')
% 
lcf_exp_eq_bestperf(10,ones(20,20),'10',5,5,'dp',20,'')

lcf_exp_eq_noperf(1,0.875*ones(20,20),'87',5,5,'ch',10,'')
lcf_exp_eq_noperf(2,0.875*ones(20,20),'87',5,5,'ch',10,'')
lcf_exp_eq_noperf(3,0.875*ones(20,20),'87',5,5,'ch',10,'')
lcf_exp_eq_noperf(4,0.875*ones(20,20),'87',5,5,'ch',10,'')
lcf_exp_eq_noperf(5,0.875*ones(20,20),'87',5,5,'ch',10,'')
lcf_exp_eq_noperf(6,0.875*ones(20,20),'87',5,5,'ch',10,'')
lcf_exp_eq_noperf(7,0.875*ones(20,20),'87',5,5,'ch',10,'')
lcf_exp_eq_noperf(8,0.875*ones(20,20),'87',5,5,'ch',10,'')
lcf_exp_eq_noperf(9,0.875*ones(20,20),'87',5,5,'ch',10,'')
lcf_exp_eq_noperf(10,0.875*ones(20,20),'87',5,5,'ch',10,'')
lcf_exp_eq_bestperf(10,0.875*ones(20,20),'87',5,5,'ch',10,'')

lcf_exp_eq_noperf(1,0.875*ones(20,20),'87',5,5,'dp',20,'')
lcf_exp_eq_noperf(2,0.875*ones(20,20),'87',5,5,'dp',20,'')
lcf_exp_eq_noperf(3,0.875*ones(20,20),'87',5,5,'dp',20,'')
lcf_exp_eq_noperf(4,0.875*ones(20,20),'87',5,5,'dp',20,'')
lcf_exp_eq_noperf(5,0.875*ones(20,20),'87',5,5,'dp',20,'')
lcf_exp_eq_noperf(6,0.875*ones(20,20),'87',5,5,'dp',20,'')
lcf_exp_eq_noperf(7,0.875*ones(20,20),'87',5,5,'dp',20,'')
lcf_exp_eq_noperf(8,0.875*ones(20,20),'87',5,5,'dp',20,'')
lcf_exp_eq_noperf(9,0.875*ones(20,20),'87',5,5,'dp',20,'')
lcf_exp_eq_noperf(10,0.875*ones(20,20),'87',5,5,'dp',20,'')
lcf_exp_eq_bestperf(10,0.875*ones(20,20),'87',5,5,'dp',20,'')

% lcf_exp_eq_noperf(1,ones(20,20),'10',5,5,'ch',10,'')
% lcf_exp_eq_noperf(2,ones(20,20),'10',5,5,'ch',10,'')
% lcf_exp_eq_noperf(3,ones(20,20),'10',5,5,'ch',10,'')
% lcf_exp_eq_noperf(4,ones(20,20),'10',5,5,'ch',10,'')
% lcf_exp_eq_noperf(5,ones(20,20),'10',5,5,'ch',10,'')
% lcf_exp_eq_noperf(6,ones(20,20),'10',5,5,'ch',10,'')
% lcf_exp_eq_noperf(7,ones(20,20),'10',5,5,'ch',10,'')
% lcf_exp_eq_noperf(8,ones(20,20),'10',5,5,'ch',10,'')
% lcf_exp_eq_noperf(9,ones(20,20),'10',5,5,'ch',10,'')
% lcf_exp_eq_noperf(10,ones(20,20),'10',5,5,'ch',10,'')
% lcf_exp_eq_bestperf(10,ones(20,20),'10',5,5,'ch',10,'')
% 
% lcf_exp_eq_noperf(1,ones(20,20),'10',5,5,'dp',20,'')
% lcf_exp_eq_noperf(2,ones(20,20),'10',5,5,'dp',20,'')
% lcf_exp_eq_noperf(3,ones(20,20),'10',5,5,'dp',20,'')
% lcf_exp_eq_noperf(4,ones(20,20),'10',5,5,'dp',20,'')
% lcf_exp_eq_noperf(5,ones(20,20),'10',5,5,'dp',20,'')
% lcf_exp_eq_noperf(6,ones(20,20),'10',5,5,'dp',20,'')
% lcf_exp_eq_noperf(7,ones(20,20),'10',5,5,'dp',20,'')
% lcf_exp_eq_noperf(8,ones(20,20),'10',5,5,'dp',20,'')
% lcf_exp_eq_noperf(9,ones(20,20),'10',5,5,'dp',20,'')
% lcf_exp_eq_noperf(10,ones(20,20),'10',5,5,'dp',20,'')
% lcf_exp_eq_bestperf(10,ones(20,20),'10',5,5,'dp',20,'')

% lcf_exp_eq_noperf(1,ones(20,20),'10',5,5,'eq',0,'')
% lcf_exp_eq_noperf(2,ones(20,20),'10',5,5,'eq',0,'')
% lcf_exp_eq_noperf(3,ones(20,20),'10',5,5,'eq',0,'')
% lcf_exp_eq_noperf(4,ones(20,20),'10',5,5,'eq',0,'')
% lcf_exp_eq_noperf(5,ones(20,20),'10',5,5,'eq',0,'')
% lcf_exp_eq_noperf(6,ones(20,20),'10',5,5,'eq',0,'')
% lcf_exp_eq_noperf(7,ones(20,20),'10',5,5,'eq',0,'')
% lcf_exp_eq_noperf(8,ones(20,20),'10',5,5,'eq',0,'')
% lcf_exp_eq_noperf(9,ones(20,20),'10',5,5,'eq',0,'')
% lcf_exp_eq_noperf(10,ones(20,20),'10',5,5,'eq',0,'')
% lcf_exp_eq_bestperf(10,ones(20,20),'10',5,5,'eq',0,'')

% stem = sprintf('lcf_eq_bestperfmaxI%dP%sFS%dVS%dEq%sT%d%s.mat',2,'75',5,5,'eq',0,'');
%     filename = [ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Eq_experiments\bestperf\' stem];
% 
%  load(filename);
%compinmenu = xbest_lcf_it_bestperf.*(ubest_lcf_it_bestperf+alphavalslong)
