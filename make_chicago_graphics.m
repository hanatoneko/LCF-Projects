function[]=make_chicago_graphics()
%%% this is the code I used to make the graphics of the chicago network
%%% (really the chicago proper subgraph), including graphing just the
%%% network and also graphing the network with a set of 4 driver trips and 4
%%% request trips, where you can plot the shortest path of a trip for one
%%% of the drivers before and after being matched etc. 

%%% the trip data
yprobs=[0.641112579399688,0.359183096620481,0.217483448576199,1;0.108279450994598,0,0.0187691391792351,0.231112454143157;0.842459973741028,0.418262496029613,0.153491105143678,1;0.745941294726480,0.827526470901550,0.123439407990396,0.719628501574950];
Di=[449;400;137;89];
Dj=[143;78;361;190];
Oi=[150;417;143;50];
Oj=[114;82;369;132];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%uncomment whichever line of code you'd like to plot. The request origins
%are green dots, req destinations are red, driver origins are yellow dots,
%driver destinations are cyan. The original driver's path is blue, matched
%path is black. The graphs made by this code are also in
%Paper_experiments\chicago_net_graphics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% make 'good match' example
plot_trip_regional(Oi,Di,Oj,Dj,1,1,4,1);
%pij= 0.75 with min wage=8

%%% make 'bad match' example
%plot_trip_regional(Oi,Di,Oj,Dj,1,1,4,3);
%pij= 0.12 with min wage=8

%%%make map of with no pairs (just OD pts)
%plot_trip_regional(Oi,Di,Oj,Dj,1,1,0,0);

%%% make a map of just chicago proper
%plot_trip_regional(Oi,Di,Oj,Dj,1,0,0,0);


%%%make map of full chicago
%plot_trip_regional(Oi,Di,Oj,Dj,0,0,0,0);
