README

Here's a breakdown of the folders of code:

**note the directory addresses for experiment data, cplex location, etc will need to be updated for any files you want to use**

main code: the files in this folder  (i.e. not in a subfolder). They should function, and all files were used in the official paper experiments. 

early code: mostly experiments or directions I was looking into before finding the paths we end up going with. Most of this code is pretty old and I don't really know what it does, much of it might not work or have errors. Would have deleted but left just in case anyone found the material to have any value.

inactive code: most of these files are alternate versions of the code used in the official experiments, and are more recent than the early code. Many should work but not all.

old (non code) files: includes experiment note word docs and a few misc files

network model files: anything to do with the network assignment heuristic

Overview for using the main code files: to rerun the phase _ experiments for the SLSF paper, just run the file in question. For SOL-IT experiments, I left some examples of calling some of the experiments in main.m, and the SOL-FR experiments were called in testing_uconst.m so reference those files for examples. Each experiment file either loads or generates problem instance parameter input info, calls the relevent solver, solves, does performance analysis, and save the info into a matlab data file 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


MAIN FILES DESCRIPTIONS (listed alphabetically in each category): 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FILES USED FOR ALL EXPERIMENTS (or at least are not specific to a single experiment):

dec2binarray---converts integer into its binary equivalent and the user specifies how many digits they want the result to be

filter_scens---generates a set of mutated scenarios of the desired size, though was also desinged to
be able to make other types of scenarios if desired

fixed_y_prob_cplex_dot---used to solve SLSF

generate_comp_iter---finds the new fixed compensation and corresponding yprobs (pij) and C values (to use in the next iteration to get a new menu) after solving LCF-FMS or LCF-FR, where the solution includes a compensation recommendation (since the recommendation only applies to driver-request pairs in that iteration's menu).

generate_params_compmodel--- generates the input parameter arrays (not including scenarios) used for LCF/ LCF-FM/ LCF-FMS/ SLSF/ LCF-FR

indepy_generate_scens--- generates random scenarios of driver selections (e.g. for test scenarios)

lcf_exp_params_slsf---this code generates driver data and other input data etc for each problem instance, solves SLSF for that input data and runs performance analysis on the SLSF menu (the data from the outputted file is also used for fairness paper 3)

loadchicago---not technically used since it concerns the smaller version of the chicago network i.e. the one we don't use, but loads the demand and arcdata as variables so they can be used to generate problem instances

loadchicago_regional---not technically used since it concerns the entire chicago regional network and what we use is a rectangular subset, but loads the demand and arcdata as variables so they can be used to generate problem instances

loadchicago_regional_proper---loads the demand and arcdata as variables so they can be used to generate problem instances

loadtripinfo---loads the travel information for all origins and destinations in chicago proper, that is, the trip distance (miles) and duration (minutes) of the shortest path from any supply node in chicago proper to any demand node in chicago. The shortest path is calculated to minimize travel time, not shortest path in terms of distance

main---this was used to do little experiments and to call the SOL-IT experiments, I deleted most of it to try to leave some references for how to call the SOL-IT experiments

make_chicago_graphics---makes the graphics of the chicago network (really the chicago proper subgraph), including graphing just the network and also graphing the network with a set of 4 driver trips and 4 request trips, where you can plot the shortest path of a trip for one of the drivers before and after being matched etc. 

max_weight_menu---makes menu to maximize the weight of the menu, each driver must be recommended theta
requests and each request must be offered to theta drivers and (code would need to adjust this number if the number of requests is different from the number of drivers).  This is how all four heuristic methods are solve (CLOS-1, CLOS-5, LIK-1, LIK-5), where the weights are (the negative of the) travel time or are the pij, respectively

menu_performance_indepy---calculates a solution's performance metrics for a single test scenario. This is done by finding the optimal feasible assignment for the platform utilities etc in the objective function given the single scenario of driver selections


plot_trip_regional---plots the chicago network, and then on top of the network it is optional to plot the driver/request origins/destinations and also optional to plot a specified driver's trip before and after being matched to a specified reqeust

quality_metrics---this code calculates some quality metrics of the test scenarios from a solution's performance analysis. The averages are calculated as the average across the test scenarios, and the test scenarios are weighted equally

quality_metrics_with_scenprobs---this code calculates some quality metrics of the test scenarios from a solution's performance analysis. The averages are calculated as the average across the test scenarios, and the test scenarios are weighted relatively based on their liklihood of occuring

sample_cases_performance_indepy---this code does the performance analysis of a solution for each of a set of inptutted test scenario and reports back the performance averages as well as the assignments information etc for each scenario.

shortest--used Dijkstra's algorithm to find the shortest node path from an origin node to any number of destination nodes on a transportation network

trip_info---given the origins and destinations of the drivers and requests, the shortest path is calculated for the original drivers' paths and each leg of the path if they were to fulfill request i. Miles and minutes of these pathes are outputted.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FILES USED FOR SLSF PAPER (paper 1, menus only)

benchmark_sizes_test.m---does the phase 0 analysis of SLSF, that is, testing different test sample sizes. All variables are recorded and output as a .mat file. Also recorded are metrics like error and percent error for each size/trial/etc tested. 


fixed_y_prob_cplex_dot_no_z--- used to solve SLSFnoZ

generate_params---generates the input parameter arrays (not including scenarios) used for SLSF

generate_params_adj_wage---code used for trying the different wage levels in the SLSF paper (last results section)

generate_params_slsf_heur---code used to generate input parameters for SLSF, also saves the wages so they can be used for the heuristic methods inputs

phase2---this code runs the experiments used for the 'phase 2' analysis, which became phase 3 becase we added heuristic comparison as the new phase 2. Basicaly this code runs ten problem instances of SLSF, does the performance analysis, and outputs a matlab data file of the variables

plot_phase0---This code makes the plots used in the paper for the phase 0 analysis, that is, the average and maximum error of the experiments with and without exhaustive performance analysis (for a total of 4 graphs)

plot_phase1---This code makes the plots used in the paper for the phase 1 analysis, that is, the average and maximum error of the experiments with and without exhaustive performance analysis, including the zoomed in version for the without exhaustive graphs (for a total of 6 graphs)

plot_phase2_with_weights---this code is used to make all graphs, data analysis etc of the problem instances run for phase 2 (which became phase 3 after adding heuristic comparisons as phase 2)


plot_phase3---this code is used to make all graphs, data analysis etc of the problem instances run for phase 3 (which became phase 4 after adding heuristic comparisons as phase 2), that is the menu size experiment, wages experiment, and unhappy drivers experiment

plot_slsf_heur---this code doesn't actually make any plots, it just calculates the average performance of each metric for the alternative methods (CLOS-1, DET-1, CLOS-5, DET-5) and SLSF 

saa_samp_size_test--- this code does the phase 1 analysis of SLSF this code will, for each size given, make one parameter instance. For this instance, three menus will be made using SLSF for each sample size. We then do performance analysis on each menu, using the same set of test scenarios to test each menu in the instance. We compare performance of each menu with either the optimal menu or the menu in the instance with the highest objective value.

slsf_exp_heur---runs and the experiments of alternative methods (CLOS-5, CLOS-1, DET-5, DET-1, and DET-5le, where DET-5le wasn't used in the paper but it's 
 DET-5 except instead of requiring the menu size to be theta, we require it's just less  than or equal to theta), i.e. for each problem instance solve each of the alternative methods and conduct performance analysis, then a matlab data file is created saving all matlab variables

slsf_exp_params_and_slsf---is basically the same as lcf_exp_params_and_slsf except it is used for the SLSF paper's phase 2 (alternate method comparison), this code generates driver data and other input data etc for each problem instance, solves SLSF for that input data and runs performance analysis on the SLSF menu

theta_effect_onesize---does the theta (menu size) effect experiment (phase 4)

wage_effect---this code does the wages experiment used in Phase 4 of the SLSF paper, that is, for each problem instance, for each specified wage level SLSF is solved and performance analysis is conducted.

z_effect_onesize---does the unhappy driver (z) effect experiment (phase 4) that is used in the SLSF paper. For each problem instance, SLSF and SLSF-noZ are solved, and performance analysis is conducted on each solution

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FILES USED FOR INCENTIVES PAPER (paper 2, menus and incentives)

comp_model.m---solves lcf (base model w/o solution methods)

comp_model_fixed_menu.m---solves lcf-fm 

comp_modelw_scens_fixed_menu.m---solves lcf-fms 

lcf_exp_base_model--- completes the experiment for the LCF base model (SOL-DIR), using the input data from the parameters and initial slsf experiment

lcf_exp_fm---completes the experiment for the LCF-FM (SOL-FM), using the input data from the parameters and initial slsf experiment. For each problem instance/trial, LCF-FM is run and performance analysis is conducted, then a matlab data file is created saving all matlab variables

lcf_exp_fms---completes the experiment for the LCF-FMS (SOL-FMS), using the input data from the parameters and initial slsf experiment. For each problem instance/trial, LCF-FMS is run and performance analysis is conducted, then a matlab data file is created saving all matlab variables

lcf_exp_heur---for each problem instance solves each of the heuristic methods (clos1, clos5, lik1, lik5) and does performance analysis on each of those solution

lcf_exp_it_bestperf---does the performance analysis of the recorded best solution from SOL-IT (from noperf), then a matlab data file is created saving all matlab variables

lcf_exp_it_bestperf_diffbeta---this is the same code as lcf_exp_it_bestperf except the beta values are slightly different in that they restrict the compensation so that it can't exceed the fare+booking fee (except when beta is changed for feasibility) i.e. the platform has to at least break even for every match

lcf_exp_it_iterperf---this code completes the full performance analysis (not the minitest) on one SOL-IT iteration's solution (used if you want to look at the performance of all iteration's not just the best-found solution)

lcf_exp_it_noperf--- completes one iteration of the experiment for SOL-IT, using the input data from the parameters and initial slsf experiment (and info from previous iterations). For each problem instance/trial, LCF-FMS (i.e. LCF-IT) is run and the small performance analysis is conducted (but not large performance analysis as it is time consuming)

lcf_exp_it_noperf_diffbeta---this is the same code as lcf_exp_it_noperf except the beta values are slightly different in that they restrict the compensation so that it can't exceed the fare+booking fee (except when beta is changed for feasibility) i.e. the platform has to at least break even for every match


load_iter_insights--- this code was made to facilitate analysis comparing different iterations of SOL-IT solutions for the main SOL-IT experiment (SOL-IT_10(5,5)).  When the SOL-IT experiments are conducted, each iteration is run individually and has its own data file produced. This code produces a single matlab
data file that contains performance information from every iteration as a set of
larger variables that are concatenated variables from the iterations

load_param_tuning---this code was made to facilitate analysis comparing the 5 performance metrics (obj, match rate, unhappy driver requests, profit, runtime) of using a variety of settings for SOL-IT (i.e. all of the parameter/setting tuning section), including different numbers of variable and fixed scenarios with 10 iterations of SOL-IT,  terminating SOL-IT after different numbers of iterations (e.g. the performance benefits of solving SOL-IT with 5 iterations vs only 2 iterations)(and using a few different numbers of variable and fixed scenarios), and using alternative methods like SLSF, LCF-DIR, LCF-FM, LCF-FMS, and the four heuristics CLOS-1, CLOS-5, LIK-1, and LIK-5

plot_insights---used to make all graphs, data analysis etc used to gain insights about the SOL-IT_10(5,5) solutions, including insights between the different solutions made each iteration

plot_lcf_param_tuning---this code is used to make all graphs, data analysis etc used to decide SOL-IT settings (includes tuning number of variable/fixed scenarios, number of iterations, and comparison with heuristics/alternative methods)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FILES USED FOR FAIRNESS PAPER (paper 3, menus, incentives, and fairness)

calculate_density.m---calculates the density of a given u-constraint (i.e. set of compensation fairness constraints) for the given equality type and menu.

create_uconst.m---creates the fairness constraint uconst as well as the corresponding rhs

lcf_exp_eq_bestperf---this code is very similar to lcf_exp_it_bestperf except it evaluates SOL-FR solutions instead of SOL-IT (which is really the same process)

lcf_exp_eq_noperf---this code is very similar to lcf_exp_it_noperf except it runs SOL-FR instead of SOL-IT

LCF_with_equity---solves lcf-fr

load_eq_all---When we conduct the SOL-FR experiments, each experiment/setting (premium, fairness type and threshold) is run individually and has its own data file produced. To make it easier to directly compare
the performance of different experiments, this code produces a single matlab data file that contains performance information from every experiment/setting that was run for SOL-FR (plus SLSF and SOL-IT), concatenated into as set of larger variables

load_eq_insights---the same idea as load_eq_all except we only load the experiments that are used for SOL-FR insights, that is SLSF, SOL-IT, dp(10,0.875),dp(20,1), ch(3,0.875),ch(10,1),eq(-,1)

plot_eq_insights---used to make all graphs, data analysis etc used to gain insights about the SOL-FR solutions

testing_uconst---was originally made to test the create_uconst code to verify that the fairness constraints were being created correctly, then this file also ended up being used to run all of the commands that do all of the SOL-FR experiments





 
