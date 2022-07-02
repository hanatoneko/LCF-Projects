function[objave,objsd,dupave,dupsd,rejave,rejsd]=exhaustive_cases_performance(C,D,r,x,method,notes,csv)
[m,n]=size(x);
for i=1:m
    for j=1:n
        if abs(x(i,j))<0.1
            x(i,j)=0;
        end
    end
end
% theta=nnz(x(:,1));
% menu=zeros(theta,n); %this is a matrix of the row indices of the nonzeros in x
% for j=1:n
%     menu(:,j)=find(x(:,j));
% end
stop=[];
menu = cell(1,n);
for j=1:n
    if nnz(x(:,j))>0
        menu{j} = vertcat(0,find(x(:,j)));
        dim=size(menu{j});
        stop=vertcat(stop, dim(1));
    else
        menu{j} = 0;
        stop=vertcat(stop,1);
    end
end

% if csv==1
%     %we'll record the data in a csv file
%      directory = 'C:\Users\hanna\Google Drive\RPI\Research\toy code';
%      filename  = [method num2str(m) 'x' num2str(n) 'menu' num2str(theta) notes '.csv'];
%      fileDest  = fullfile(directory,filename);
%      fid = fopen(fileDest, 'w') ;
%      fprintf(fid, 'obj,duplicates,rejects\n') ;
% end

%%%initialize vals

totscen=1;
for j=1:n
    totscen=totscen*(nnz(x(:,j))+1);
end

objvals = zeros(totscen,1);
dupvals = zeros(totscen,1);
rejvals = zeros(totscen,1);
col=ones(n,1);
check=1;
curr=1;


%%%%%%%%%%%%%%%%% big loop over each scenario
p=1;
while true
    y = zeros(m,n);
    %%% set y values based on current column choices
    for j=1:n
        temp=menu{j};
        temp(col(j,1));
        if temp(col(j,1)) ~= 0
            y(temp(col(j,1)),j)=1;
        end
    end
    %%% performance analysis
    [obj,dup,rej,v,y,w,z]=menu_performance(C,D,r,y);
%     if csv==1
%     fprintf(fid, '%f,%d,%d\n', obj,dup,rej) ;
%     end
    objvals(p,1)=obj;
    dupvals(p,1)=dup;
    rejvals(p,1)=rej;
    %%% advance col choices to the next combination of choices
     if col==stop
        break
    end
    while true
        if col(check)<stop(check)
            col(check)=col(check)+1;
            check=1;
            break
        end
        col(check)=1;
        check=check+1;
        if (check-1)==curr
            curr=curr+1;
            if stop(curr)==1
                curr=curr+1;
            end
            check=1;
            col(curr,1)=col(curr,1)+1;
            break
        end
        
    end 
    
    p=p+1;
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%the old version of the loop
% for p=0:(theta+1)^n-1
%    y = zeros(m,n);
%    choice = dec2base(p, theta+1); 
%    for j=1:n
%        if strlength(choice)>=j
%            if str2double(choice(j)) ~= 0 %if the value is 0 for that column we 
%                %assume driver picks no-choice
%                y(menu(str2double(choice(j)),j),j)=1;
%            end
%        end
%    end
%    [obj,dup,rej,v,y,w,z]=menu_performance(C,D,r,y);
%    if csv==1
%     fprintf(fid, '%f,%d,%d\n', obj,dup,rej) ;
%    end
%    objvals(p+1,1)=obj;
%    dupvals(p+1,1)=dup;
%    rejvals(p+1,1)=rej;
%     
% end

objave = mean(objvals);
objsd = std(objvals);
dupave = mean(dupvals);
dupsd = std(dupvals);
rejave = mean(rejvals);
rejsd = std(rejvals);