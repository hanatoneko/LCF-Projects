function[miles,mins]=loadtripinfo()
%%% this code loads the travel information for all origins and destinations in chicago proper, that is,
%%% the trip distance (miles) and duration (minutes) of the shortest path from any supply node in chicago 
%%% proper to any demand node in chicago. The shortest path is calculated
%%% to minimize travel time, not shortest path in terms of distance
miles=importdata('C:\Users\horneh\Google Drive\RPI\Research\code\miles.csv');
mins=importdata('C:\Users\horneh\Google Drive\RPI\Research\code\mins.csv');




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%Below is the code that was used to calculate the miles and mins data for all trips and save them to a csv file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% load arc data and determine the exhaustive list of chicago proper
%%% supply (origin) nodes, which is also the set of possible demand nodes 
% [arcdata,dem]=loadchicago_regional_proper();
% origset=unique(vertcat(dem(:,1),dem(:,2)),'rows');
% nodenum=12982;
% miles=sparse(1778,1778);
% mins=sparse(1778,1778);
% 
% 
% %for each origin, run the shortest path code, which gets the node predecesor in the shortest path for every node. Then, for each destination,
% use the predecessors to retrace the node path backwards until you arrive back at the origin. Each time you go back one node, that gives you an arc 
%of the shortest path so you add the miles and minutes of that arc to the total miles and minutes of that path and return the final result.
% for iindex=1:size(origset,1)
%     % depending on what origin set(s) i is in, add all destinations that
%     % have that origin
%     i=origset(iindex,1)    
%     %%% shortest path = the SP(4) code provided
%     preds=shortest(arcdata(:,[1 2 4]),i,origset',nodenum);
%     for jindex=1:size(origset,1) 
%             j=origset(jindex,1);
%             head=origset(jindex,1);
%             tail=0;
%             while tail~=i
%                 tail=preds(1,head);
%                 %the arc (tail,head) is an arc on shortest path so add
%                 %miles and minutes to it
%                 linkrow=find(arcdata(:,1)==tail & arcdata(:,2)==head);
%                 miles(i,j)=miles(i,j)+arcdata(linkrow,3);
%                 mins(i,j)=mins(i,j)+arcdata(linkrow,4);
% 
%                 head=tail;
%             end
%     end
% end
% writematrix(miles,'C:\Users\horneh\Google Drive\RPI\Research\toy code\miles.csv');
% writematrix(mins,'C:\Users\horneh\Google Drive\RPI\Research\toy code\mins.csv');
