%%%%%%%%% first four rows for heuristics
 stem= 'lcf_exp_heur.mat';
    filename =[ 'C:\Users\horneh\documents\LCF_Paper_experiments\' stem];
    load(filename)
    
    
     exp_income_clos5 = zeros(1,n*trials);
        exp_income_lik5 = zeros(1,n*trials);
        %exp_totalrev_lcf = zeros(1,trials);
        for t=1:trials
        
           for j=1:n
              for k=1:5000
                     exp_income_clos5(1,(t-1)*n+j) = exp_income_clos5(1,(t-1)*n+j)+sum(testscenprobs_clos5(t,k)*testv_clos5((t-1)*m+1:t*m,(k-1)*n+j).*slsfcomplong(:,(t-1)*n+j));
                      exp_income_lik5(1,(t-1)*n+j) = exp_income_lik5(1,(t-1)*n+j)+sum(testscenprobs_lik5(t,k)*testv_lik5((t-1)*m+1:t*m,(k-1)*n+j).*slsfcomplong(:,(t-1)*n+j));
                 
               
              end
           end
        end
% 
mean(exp_income_clos5)
mean(exp_income_lik5)
%     testobjave_lcf_mthds(1,:)=testobjave_clos1(:,1:100);
%     testrejave_lcf_mthds(1,:)=testrejave_clos1(:,1:100);
%     testdupave_lcf_mthds(1,:)=testdupave_clos1(:,1:100);
%     avetotprofit_lcf_mthds(1,:)=avetotprofit_clos1(:,1:100);
%     runtimes_lcf_mthds(1,:)=runtimes_clos1(:,1:100);
%     
%     testobjave_lcf_mthds(2,:)=testobjave_lik1(:,1:100);
%     testrejave_lcf_mthds(2,:)=testrejave_lik1(:,1:100);
%     testdupave_lcf_mthds(2,:)=testdupave_lik1(:,1:100);
%     avetotprofit_lcf_mthds(2,:)=avetotprofit_lik1(:,1:100);
%     runtimes_lcf_mthds(2,:)=runtimes_lik1(:,1:100);
%     
%     testobjave_lcf_mthds(3,:)=testobjave_clos5(:,1:100);
%     testrejave_lcf_mthds(3,:)=testrejave_clos5(:,1:100);
%     testdupave_lcf_mthds(3,:)=testdupave_clos5(:,1:100);
%     avetotprofit_lcf_mthds(3,:)=avetotprofit_clos5(:,1:100);
%     runtimes_lcf_mthds(3,:)=runtimes_clos5(:,1:100);
%     
%     testobjave_lcf_mthds(4,:)=testobjave_lik5(:,1:100);
%     testrejave_lcf_mthds(4,:)=testrejave_lik5(:,1:100);
%     testdupave_lcf_mthds(4,:)=testdupave_lik5(:,1:100);
%     avetotprofit_lcf_mthds(4,:)=avetotprofit_lik5(:,1:100);
%     runtimes_lcf_mthds(4,:)=runtimes_lik5(:,1:100);
% 
% 
% 
% %%%%%%%% fifth row for lcf base model
%  stem= 'lcf_base_modelP10S10.mat';
%     filename =[ 'C:\Users\horneh\documents\\LCF_Paper_experiments\LCF_base_model\' stem];
%     load(filename)
% 
%     testobjave_lcf_mthds(5,:)=testobjave_lcf_base(:,1:100);
%     testrejave_lcf_mthds(5,:)=testrejave_lcf_base(:,1:100);
%     testdupave_lcf_mthds(5,:)=testdupave_lcf_base(:,1:100);
%     avetotprofit_lcf_mthds(5,:)=avetotprofit_lcf_base(:,1:100);
%     runtimes_lcf_mthds(5,:)=runtimes_lcf_base(:,1:100);
% %%%%%%%  lcf-fm
%     stem= 'lcf_fmP10S10.mat';
%     filename =[ 'C:\Users\horneh\documents\\LCF_Paper_experiments\LCF_fm\' stem];
%     load(filename)
% 
%     testobjave_lcf_mthds(6,:)=testobjave_lcf_fm(:,1:100);
%     testrejave_lcf_mthds(6,:)=testrejave_lcf_fm(:,1:100);
%     testdupave_lcf_mthds(6,:)=testdupave_lcf_fm(:,1:100);
%     avetotprofit_lcf_mthds(6,:)=avetotprofit_lcf_fm(:,1:100);
%     runtimes_lcf_mthds(6,:)=runtimes_lcf_fm(:,1:100);
%    
% %%%%%%%%%%%%%%%%  lcf-fms
%    stem= 'lcf_fmsP10FS10VS10.mat';
%     filename =[ 'C:\Users\horneh\documents\\LCF_Paper_experiments\LCF_fms\' stem];
%     load(filename)
% 
%     testobjave_lcf_mthds(7,:)=testobjave_lcf_fms(:,1:100);
%     testrejave_lcf_mthds(7,:)=testrejave_lcf_fms(:,1:100);
%     testdupave_lcf_mthds(7,:)=testdupave_lcf_fms(:,1:100);
%     avetotprofit_lcf_mthds(7,:)=avetotprofit_lcf_fms(:,1:100);
%     runtimes_lcf_mthds(7,:)=runtimes_lcf_fms(:,1:100);
% 
% 
