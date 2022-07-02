function[objvals,runtimes]=test_sample_size(C,D,r,q,x,yprobs,Oi,Di,Oj,Dj,drand,sizes,trials,notes,exh,heur,graph,csv)

[m,n]=size(C);

runtimes=zeros(size(sizes,1)+1,1);
 
 if csv==1
    %directory = 'C:\Users\hanna\Google Drive\RPI\Research\toy code';
    directory = 'C:\Users\horneh\Google Drive\RPI\Research\toy code';
    if heur==1
        filename  = ['test_sample_sizes' num2str(m) 'x' num2str(n)  notes 'withheur.csv'];
    else
        filename  = ['test_sample_sizes' num2str(m) 'x' num2str(n)  notes  '.csv'];

    end

    %%%makes string 'exhaustive, obj[sample size]...[for each size],
    %%%heurobj[sample size]... [for each size]
    str = 'exhobj';
    for k=1:size(sizes,1)
        str= [str ',obj' num2str(sizes(k,1))];
    end
    if heur==1
        for k=1:size(sizes,1)
            str= [str ',heurobj' num2str(sizes(k,1))];
        end
    end
    fileDest  = fullfile(directory,filename);
    fid = fopen(fileDest, 'wt') ;
    if fid==-1
         error('Cannot open file for writing: %s', fileDest);
    end
    fprintf(fid, [str '\n']) ;

 end

 %empty obj val matrix
 if heur==1
     objvals=zeros(trials,1+2*size(sizes,1));
 else
     objvals=zeros(trials,1+size(sizes,1));
 end
 
 if exh==1
      tic
      [objave,objsd,dupave,dupsd,rejave,rejsd]=exhaustive_cases_performance_indepy(C,D,r,q,x,yprobs);
      toc
      runtimes(1,1)=toc;
      objvals(1,1)=objave
        stem= sprintf('perfsize%dx%dexh%s.mat',m,n,notes);
        filename2 =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\variable_data\' stem];
        save(filename2);
 end
  
%%% doing all the performance analysis
for k=1:size(sizes,1)

    if heur==1
        tic
        [success,heurerror,true_sorted,heur_sorted]=compare_assmts_same_scens(C,D,r,q,x,yprobs,sizes(k,1),trials);
        toc
        runtimes(k+1,1)=toc;
        runtimes(k+1,1)=runtimes(k+1,1)/trials;
        objvals(:,1+k)=true_sorted;
        objvals(:,1+size(sizes,1)+k)=heur_sorted;
        objvals
        stem= sprintf('perfsize%dx%dswheur%d%s.mat',m,n,sizes(k,1),notes);
        filename2 =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\variable_data\' stem];
        save(filename2);
    else
        tic
        for t=1:trials
           [objave,objsd,dupave,dupsd,rejave,rejsd]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,sizes(k,1));
           objvals(t,1+k)=objave;
        end
        toc
        runtimes(k+1,1)=toc;
        runtimes(k+1,1)=runtimes(k+1,1)/trials;
        objvals
        stem= sprintf('perfsize%dx%ds%d%s.mat',m,n,sizes(k,1),notes);
        filename2 =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\variable_data\' stem];
        save(filename2);            
    end
end

%write to csv if needed
if csv==1
    for t=1:trials        
        for j=1:size(objvals,2)-1
            fprintf(fid,['%f,'],objvals(t,j));
        end
        fprintf(fid,['%f\n'],objvals(t,size(objvals,2)));
    end
end

%make graphs if needed

if graph==1
    if heur==1
        opt=objvals(:,2:1+size(sizes,1));
        heur=objvals(:,2+size(sizes,1):1+2*size(sizes,1));
        samps=repmat(sizes,1,trials)';
        figure
        %plot(x,y1,x,x,x,y2
        scatter(samps(:),opt(:),'o')
        hold on
        scatter(samps(:),heur(:),'*')
        hold on
        hline = refline([0 objvals(1,1)]);
        hline.Color = 'r';
        xlabel('test sample size')
        ylabel('average objective value')
        %xticks([0 1 2 3 4 5 6 7 8 9 10])

        legend('Optimal','Heuristic', 'True Performance','Location','Best')
    else
        opt=objvals(:,2:1+size(sizes,1));
        samps=repmat(sizes,1,trials)';
        figure
        %plot(x,y1,x,x,x,y2
        scatter(samps(:),opt(:),'o')
        hold on
        hline = refline([0 objvals(1,1)]);
        hline.Color = 'r';
        xlabel('test sample size')
        ylabel('average objective value')
        %xticks([0 1 2 3 4 5 6 7 8 9 10])

        legend('Sample', 'True Performance','Location','Best')
    end
end

 