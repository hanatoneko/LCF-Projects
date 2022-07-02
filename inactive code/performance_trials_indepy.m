function[objave,objsd,dupave,dupsd,rejave,rejsd,avemenuave,menuave,simobj,simdup,simrej]=performance_trials_indepy(C,D,r,q,yprobs,alpha1,alpha2,theta,equal,lwr,notes,samples,testsamples,trials,method,csv)

[m,n]=size(C);

%%%we'll record the data in a csv file
if csv==1
    directory = 'C:\Users\hanna\Google Drive\RPI\Research\toy code';
    %directory = 'C:\Users\ISE5107\Google Drive\RPI\Research\toy code';
    if equal==1
        filename  = ['saa' num2str(m) 'x' num2str(n) 'eqmenu' num2str(theta)  notes 'samples' num2str(samples) '.csv'];
    else
        if lwr==1
            filename  = ['saa' num2str(m) 'x' num2str(n) 'menu' num2str(theta)  notes 'samples' num2str(samples) '.csv'];
        else
            filename  = ['saa' num2str(m) 'x' num2str(n) 'freemenu' num2str(theta)  notes 'samples' num2str(samples) '.csv'];
        end
    end

    %%%makes string ',ave,0,1,2...,theta' or ',ave,1,2,...theta' , or '' if equal==1
    str = '';
    if equal~=1
        str = ',ave';
        if lwr == 0
            str = [str ',0'];
        end
        for i=1:theta
            temp =sprintf(',%d',i);
            str = [str temp];
        end
    end
    fileDest  = fullfile(directory,filename);
    fid = fopen(fileDest, 'w') ;
    fprintf(fid, ['objave,objsd,dupave,dupsd,rejave,rejsd' str ',simobj,simdup,simrej,\n']) ;

end
objavevals = zeros(trials,1);
objsdvals = zeros(trials,1);
dupavevals = zeros(trials,1);
dupsdvals = zeros(trials,1);
rejavevals = zeros(trials,1);
rejsdvals = zeros(trials,1);
avemenuvals = zeros(trials,1); %for each trial, this is the average menu size across the drivers
menuvals = zeros(trials,(theta+1)); %for each trial, this is the count for each menu size 
%(ex. how many drivers were given one option, how many were given two, etc)
simobjvals = zeros(trials,1);
simdupvals = zeros(trials,1);
simrejvals = zeros(trials,1);


for t=1:trials
    if method=='saa'
        [yhat,scenprobs]=indepy_generate_scens(yprobs,samples,0);
        [obj,x,v,z,w]=fixed_y_prob(C,D,r,theta,q,yhat,scenprobs,equal,lwr);
        %%% calculate simobj,simdup,simrej
        simobj=obj;
        for k=1:samples
            simdup=nnz(z(:,(k-1)*n+1:k*n))*scenprobs(1,k);
            simrej=nnz(w(:,k))*scenprobs(1,k);
        end
        simdup=simdup/sum(scenprobs);
        simrej=simrej/sum(scenprobs);
    else
        [Gamma,pen]=arc_lengths(C,D,r,yprobs,alpha1,alpha2)
        [obj,x]=network_fixed_y_prob(Gamma,pen,theta,yprobs);
        simobj=0;
        simdup=0;
        simrej=0;
    end

    x
    nnz(z)
    %%% calculate menu sizes
    if equal ~=1
        for j=1:n
            menuvals(t,nnz(x(:,j))+1) = menuvals(t,nnz(x(:,j))+1)+1;
        end
    end
    
    [objave,objsd,dupave,dupsd,rejave,rejsd]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,testsamples);
    %[objave,objsd,dupave,dupsd,rejave,rejsd]=exhaustive_cases_performance_indepy(C,D,r,q,x,yprobs);
   objave
    
   if csv==1 
       %%%build string that contains the counts for the menu sizes
        str = '';
        if equal~=1
            if lwr == 0
                str = sprintf(',%d',menuvals(t,1));
            end
            for i=1:theta
                temp =sprintf(',%d',menuvals(t,i+1));
                str = [str temp];
            end
        end
   end
    %%%calculate menusize ave
    if equal~=1
        mult=[0:1:theta];
        ave=(mult*menuvals(t,:)')/n;
        %str = [',' num2str(ave) str ];   
        avemenuvals(t,1) = ave;
    else
        ave=theta;
    end
    
    
    if csv==1
        fprintf(fid,['%f,%f,%f,%f,%f,%f,%f' str ',%f,%f,%f\n'], objave,objsd,dupave,dupsd,rejave,rejsd,ave,simobj,simdup,simrej);
    end
    
    objavevals(t) = objave;
    objsdvals(t) = objsd;
    dupavevals(t) = dupave;
    dupsdvals(t) = dupsd;
    rejavevals(t) = rejave;
    rejsdvals(t) = rejsd;
    simobjvals(t) = simobj;
    simdupvals(t) = simdup;
    simrejvals(t) = simrej;
    
    
    
end

objave = mean(objavevals);
objsd = mean(objsdvals);
dupave = mean(dupavevals);
dupsd = mean(dupsdvals);
rejave = mean(rejavevals);
rejsd = mean(rejsdvals);
simobj = mean(simobjvals);
simdup = mean(simdupvals);
simrej = mean(simrejvals);
avemenuave = mean(avemenuvals);
menuave = mean(menuvals,1);

    