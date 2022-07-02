function[x,paths]=aon(cost,dem,savepaths)
%%% assigns demand to shortest path for fixed costs. The cost matrix is the
%%% same format as the one for shortest path code, savepaths indicates
%%% whether or not the delta values for the shortest paths are calculated
%%% and outputted (savepaths=1 means they're saved)

nodenum=size(dem,1);
x=zeros(size(cost,1),1);
if savepaths==1
    paths=zeros(nodenum,nodenum,1,size(cost,1)); %first element is i, second is j, fourth is the 
    % vector of delta_r^ij
end
%find all shortest paths from each i to any j, add q_ij to each link in the
%path to make a valid solution
for i=1:nodenum
    %%% shortest path = the SP(4) code provided
    preds=shortest(cost,i,[1:1:nodenum],nodenum);
    for j=1:nodenum
        if dem(i,j)>0 %can skip step when demand is zero, plus eliminates 
        %the potential complication of there not being an i-j path        
            head=j;
            tail=0;
            if savepaths==1
                k=2; %index counter
            end
            while tail~=i
                tail=preds(1,head);
                %the arc (tail,head) is an arc on shortest path so add
                %demand to it
                linkrow=find(cost(:,1)==tail & cost(:,2)==head);
                x(linkrow,1)=x(linkrow,1)+dem(i,j);
                if savepaths==1
                    paths(i,j,1,linkrow)=1;
                    k=k+1;
                end
                head=tail;
            end
        end
    end
end