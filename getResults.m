clear
% stem = 'lcf_it_bestperfwithnoisemaxI10P75FS5VS5linearNfull4'
stem = 'lcf_it_bestperfwithnoisemaxI10P75FS5VS5N4'

filename = [ 'C:\Users\horneh\Documents\LCF_Paper_experiments\LCF_it_bestperf_withnoise\' stem];
load(filename)


objave = mean(testobjave_best_lcf_it_bestperf)
rejave = mean(testrejave_best_lcf_it_bestperf)
dupave = mean(testdupave_best_lcf_it_bestperf)
aveprof = mean(avetotprofit_best_lcf_it_bestperf)

aveOrigPij = min(p_best_lcf_it_bestperf,ones(m,trials*n));
aveOrigPij = mean(mean(aveOrigPij(aveOrigPij.*xbest_lcf_it_bestperf>0)))
aveNoisePij = min(p_best_withnoise_lcf_it_bestperf,ones(m,trials*n));
aveNoisePij = mean(mean(aveNoisePij(aveNoisePij.*xbest_lcf_it_bestperf>0)))

% aveNoise = mean( mean( abs( noise_lcf_it_bestperf ) ) )
aveDiffmatrix = abs(p_best_withnoise_lcf_it_bestperf - p_best_lcf_it_bestperf).*xbest_lcf_it_bestperf; 
aveDiff = mean( mean( aveDiffmatrix( aveDiffmatrix > 0 ) ) )
% xvals = min( ( ubest_lcf_it_bestperf + alphavalslong ).*xbest_lcf_it_bestperf, 15*ones( m, n * trials ) );
% xvals = xvals(:);
% pnoise = p_best_withnoise_lcf_it_bestperf(:);
% 
% scatter( xvals(xvals > 0),pnoise(xvals > 0) );
% hold on
% scatter( xvals(xvals > 0), p_best_lcf_it_bestperf(:) )