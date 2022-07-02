function[]=plot_perf_scen_sifting_effect(barsizes,testobjs,error,perckeep,type)
%%% three different graphs you can make: type 'o' is observed error vs
%%% percent of scens kept, type 't' is theoretical error bound vs perckeep,
%%% else, type 'c', compares theoretical error vs the actual error.

trials=size(testobjs,1);
numsizes=size(barsizes,1);
bigbar=repmat(barsizes',trials,1);


error=abs(error)
if type=='o'
    
    plot(error(1,:),perckeep(1,:))
    title('Observed Effect of Filtering Test Scenarios')
    xlabel('Observed Absolute Error')
    ylabel('Portion of Samples Retained')
    for i=2:trials
        hold on        
        plot(error(i,:),perckeep(i,:))
    end
elseif type=='t'
    plot(bigbar(1,:),perckeep(1,:))
    title('Filtering Test Scenarios with Theoretical Bounds')
    xlabel('Error Bound')
    ylabel('Portion of Samples Retained')
    for i=2:trials
        hold on        
        plot(bigbar(i,:),perckeep(i,:))
    end
    
else
    plot(bigbar(1,:),error(1,:))
    title('Theoretical Error vs Observed Error')
    xlabel('Error Bound')
    ylabel('Observed Error')
    for i=2:trials
        hold on        
        plot(bigbar(i,:),error(i,:))
    end
    
    
end

