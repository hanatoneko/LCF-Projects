function[C,yprobs,newcomp]=generate_comp_iter(comp,oldcomp,alpha,fare,OjOimins,extradrivingtime,drand,method)
%%% this code finds the new fixed compensation and corresponding
%%% yprobs (pij) and C values after solving LCF-FMS or LCF-FR, where the
%%% solution includes a compensation recommendation. The compensation
%%% recommendation only applies to driver-request pairs in the current
%%% iteration's menu, so the compensations used
%%% to get the current iteration's SLSF menu should be used for
%%% driver-request pairs not in that SLSF menu. 

%%%inputs: comp is the compensations found by the current solution, i.e. is
%%% u + alpha, oldcomp is the fixed compensation used to get the SLSF menu
%%% that iteration, alpha is the alpha values, fare is the fare, OjOimins
%%% is m x n where entry ij is time needed for driver j to go from their
%%% origin to the request origin (i.e. wait time), extradrivingtime is an m x n array of the time in hours 
%%% of driver j's trip time if matched with request i minus the driving
%%% time of driver j's original trip, drand is the column vecor random component
%%% of D (one value per driver)(this value isn't actually used), method is an option designed to allow
%%% coding for different types of fixed compensation updates, but we only
%%% code for one so let method = 'c' for 'cumulative prices from all iterations

%%%outputs: newcomp is the new set of fixed compensations that would be
%%%used to find the SLSF menu in the next iteration, yprobs is the pij
%%%willingness m x n matrix of values resulting from the new compensations,
%%%and C is the resulting platform utilities from the compensations, i.e.
%%%the booking fee plus the fare minus the compensation minus the request
%%%wait time penalty


[m,n]=size(alpha);
wagemin=10;
wagemax=25;

if method=='c' %(cumulative prices from all iterations)
    newcomp=oldcomp;
    newcomp(comp>alpha)=comp(comp>alpha);
    yprobs=(newcomp./extradrivingtime -wagemin*ones(m,n))/(wagemax-wagemin);
    %edit values that were above 1 or below 0
    yprobs=min(yprobs,ones(m,n));
    yprobs=max(yprobs,zeros(m,n));
    C=1.85*ones(m,n)+fare-newcomp-0.28*0.2*OjOimins;
    
end