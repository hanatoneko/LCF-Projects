function[]=plot_scen_sifting_effect(sizes,ratios,testobjs,times,perckeep,type)
%%% three different graphs you can make: type 'o' is observed error vs
%%% percent of scens kept, type 't' is theoretical error bound vs perckeep,
%%% else, type 'c', compares theoretical error vs the actual error.
trials=size(testobjs,1);
trials
size(perckeep,1)
perckeepfull=horzcat(ones(trials,1),perckeep);
numsizes=size(ratios,1);
bigratio=repmat(ratios',trials,1);
error=zeros(trials,numsizes);
for i=1:numsizes
    error(:,i)=testobjs(:,i+1)-testobjs(:,1);
end

error=abs(error);
if type=='o'
    
    plot(error(1,:),perckeep(1,:))
    title('Observed Effect of Filtering Test Scenarios')
    xlabel('Observed Absolute Error')
    ylabel('Portion of Samples Retained')
    for i=2:trials
        hold on        
        plot(error(i,:),perckeep(i,:))
    end
elseif type=='t' %%% for time
    plot(perckeepfull(1,:),times(1,:))
    title('Checking if percent kept scales time')
    xlabel('Percent retained')
    ylabel('Time')
    for i=2:trials
        hold on        
        plot(perckeepfull(i,:),times(i,:))
    end
    
elseif type=='p' %%% for percent keep (ratio vs %keep)
    colors=zeros(trials,3);
    colors(find(sizes(:,4)==50),:)=repmat([0,0,0],size(find(sizes(:,4)==50),1),1);
    colors(find(sizes(:,4)==100),:)=repmat([0,1,0],size(find(sizes(:,4)==100),1),1);
    colors(find(sizes(:,4)==500),:)=repmat([0,0,1],size(find(sizes(:,4)==500),1),1);
    semilogx(ones(1,numsizes)./bigratio(1,:),perckeep(1,:),'color',colors(1,:))
    title('Keep Threshold vs Percent Retained ')
    xlabel('Retention Level')
    ylabel('Percent Retained')
    for i=2:trials
        hold on        
        semilogx(ones(1,numsizes)./bigratio(i,:),perckeep(i,:),'color',colors(i,:))
    end
    
    
end

