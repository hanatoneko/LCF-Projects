function[objave,objsd,dupave,dupsd,rejave,rejsd,avemenuave,menuave,simobj,simdup,simrej]=performance_multiple_trials(C,D,r,theta,equal,lwr,kpercentage,samples,trials)

[m,n]=size(C);

%%%we'll record the data in a csv file
directory = 'C:\Users\hanna\Google Drive\RPI\Research\toy code';
if equal==1
    filename  = ['saa' num2str(m) 'x' num2str(n) 'eqmenu' num2str(theta)  'samples' num2str(samples) '.csv'];
else
    if lwr==1
        filename  = ['saa' num2str(m) 'x' num2str(n) 'menu' num2str(theta) 'samples' num2str(samples) '.csv'];
    else
        filename  = ['saa' num2str(m) 'x' num2str(n) 'freemenu' num2str(theta) 'samples' num2str(samples) '.csv'];
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
fprintf(fid, ['objave,objsd,dupave,dupsd,rejave,rejsd' str ',simobj,simdup,simrej\n']) ;

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


for k=1:trials
    U=zeros(m,n*samples);
    for j=1:n*samples
        rank=randperm(m+1);
        U(:,j)=rank(1,1:m)'-rank(1,m+1)*ones(m,1);
    end
    [obj,v,x,y,w,z]=saa(C,D,r,U,theta,equal,lwr);
    x
    %%% calculate simobj,simdup,simrej, assuming all scenarios equally likely
    simobj=obj;
    simdup=nnz(z)/samples;
    simrej=nnz(w)/samples;
    
    for i=1:m
        for j=1:n
            if abs(x(i,j))<0.1
                x(i,j)=0;
            end
            if abs(x(i,j)-1)<0.1
                x(i,j)=1;
            end
        end
    end
    x
    %%% calculate menu sizes
    if equal ~=1
        for j=1:n
            menuvals(k,nnz(x(:,j))+1) = menuvals(k,nnz(x(:,j))+1)+1;
        end
    end
    [objave,objsd,dupave,dupsd,rejave,rejsd]=exhaustive_cases_performance(C,D,r,x,'method','notes',1);
    
    %%%build string that contains the counts for the menu sizes
    str = '';
    if equal~=1
        if lwr == 0
            str = sprintf(',%d',menuvals(k,1));
        end
        for i=1:theta
            temp =sprintf(',%d',menuvals(k,i+1));
            str = [str temp];
        end
    end
    
    %%%calculate menusize ave
    if equal~=1
        mult=[0:1:theta];
        ave=(mult*menuvals(k,:)')/n;
        %str = [',' num2str(ave) str ];   
        avemenuvals(k,1) = ave;
    else
        ave=theta;
    end
    
    
    
    fprintf(fid,['%f,%f,%f,%f,%f,%f,%f' str ',%f,%f,%f\n'], objave,objsd,dupave,dupsd,rejave,rejsd,ave,simobj,simdup,simrej);
    objavevals(k) = objave;
    objsdvals(k) = objsd;
    dupavevals(k) = dupave;
    dupsdvals(k) = dupsd;
    rejavevals(k) = rejave;
    rejsdvals(k) = rejsd;
    simobjvals(k) = simobj;
    simdupvals(k) = simdup;
    simrejvals(k) = simrej;
    
    
    
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

    