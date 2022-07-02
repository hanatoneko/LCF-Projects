function[newtestobjs,newtimes,newperctimesaved,newabserror,newpercerror,newmenunzs]=phase1_extra_trials(mnsizes,saasizes,exh,notes)
%this code will, for each size given, use the corresponding theta values to
%make one parameter instance. For this instance, a menu will be made using
%saa three times for each sample size. Then we'll calculate either exhaustive
%performance or just compare with the best found solution out of the saa sizes. We'll calculate the percent difference from opt 
%(which will be either calculated or taken as the maximum obj found for the largest
%sample size, as well as

%%% the sizes input for each row is m,n,theta

trials=40;
%column labels are m,n,nontrivial,exh,3 trials for each samp size: 500,1000,5000,10000 
numcols=trials*size(saasizes,1)+1+3;
newtestobjs=zeros(size(mnsizes,1),numcols);
newtimes=zeros(size(mnsizes,1),numcols);
newperctimesaved=zeros(size(mnsizes,1),numcols-1);
newabserror=zeros(size(mnsizes,1),numcols-1);
newpercerror=zeros(size(mnsizes,1),numcols-1);
newmenunzs=zeros(size(mnsizes,1),numcols);

newtestobjs(:,1:2)=mnsizes(:,1:2);
newtimes(:,1:2)=mnsizes(:,1:2);
newperctimesaved(:,1:2)=mnsizes(:,1:2);
newabserror(:,1:2)=mnsizes(:,1:2);
newpercerror(:,1:2)=mnsizes(:,1:2);
newmenunzs(:,1:2)=mnsizes(:,1:2);

for snew=1:size(mnsizes,1)
    m=mnsizes(snew,1);
    n=mnsizes(snew,2);
    theta=mnsizes(snew,3);
   
   stem= sprintf('phase1%dx%d%s.mat',m,n,notes);
   filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_1\' stem];

   load(filename);
   ttimes=times(:,:);
    saasizes=[10;50;100;500;1000];
    newtestobjs(snew,3)=testobjs(snew,3);
    newtimes(snew,3)=testobjs(snew,3);
    newperctimesaved(snew,3)=testobjs(snew,3);
    newabserror(snew,3)=testobjs(snew,3);
    newpercerror(snew,3)=testobjs(snew,3);
    newmenunzs(snew,3)=testobjs(snew,3);
    

        %%% generate the menus and the x-union for performance analysis
 
         newbigx=zeros(m,n*trials*size(saasizes,1));
    
    toobig=0;
    recentobj=0;
   for knew=1:size(saasizes,1)
       for ellnew=1:3
           newbigx(:,n*((knew-1)*trials+ellnew-1)+1:n*(trials*(knew-1)+ellnew))=bigx(:,n*((knew-1)*3+ellnew-1)+1:n*(3*(knew-1)+ellnew));
            newtimes(snew,4+trials*(knew-1)+ellnew)=ttimes(snew,4+3*(knew-1)+ellnew);
            newmenunzs(snew,4+trials*(knew-1)+ellnew)=menunzs(snew,4+3*(knew-1)+ellnew);
           
       end
       
       for ellnew=4:trials
            if 2^pijnontrivial>saasizes(knew,1)
                if toobig==0
                   [yhat,scenprobs,newretention,scenbase,scenexp]=filter_scens(m,n,yprobs,0,0,0,1000000,'t',saasizes(knew,1));
                   tic
                   [obj,gap,x,v,z,w]=fixed_y_prob_cplex_dot(C,D,r,theta,q,yprobs,yhat,scenprobs,0,0,500,.01,0);
                    toc

                   yprobs;
                   x;
                   xunion=max(xunion,x);
                   newbigx(:,n*((knew-1)*trials+ellnew-1)+1:n*(trials*(knew-1)+ellnew))=x;
                    newtimes(snew,4+trials*(knew-1)+ellnew)=toc
                    newmenunzs(snew,4+trials*(knew-1)+ellnew)=nnz(x)
                    
%                     %if a menu is all zeros, skip to next problem size
%                     if obj< 0.5*recentobj
%                         toobig=1;
%                     end
                    recentobj=obj;
                end
            end
       end
   end



%%%performance analysis
    %%%generate 5000 (or exh) scens based on xunion and test on 
    xnontriv=nnz(xunion)-(m*n-nnz(xunion.*yprobs-ones(m,n)));

   %[bigyhat,bigscenprobs,newretention,scenbase,scenexp]=filter_scens(m,n,yprobs,0,0,0,1000000,'t',100000);
   if 5000<2^xnontriv
   [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(yprobs.*xunion,5000,0);
   else
       [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(yprobs.*xunion,'all',0);
   end

   if exh==1
      % [opt,objsdexh,dupaveexh,dupsdexh,rejaveexh,rejsdexh,aveassignexh,objvalsexh]=sample_cases_performance_indepy(C,D,r,q,xopt,yprobs,min(5000,2^xnontriv),testyhat,testscenprobs);

       newtestobjs(snew,4)=testobjs(snew,4);

   end

   %%% now do three trials for each perf size
   for knew=1:size(saasizes,1)
       for ellnew=1:3
           
           newtestobjs(snew,4+trials*(knew-1)+ellnew)=testobjs(snew,4+3*(knew-1)+ellnew)
       end
       
       for ellnew=4:trials
           if nnz(newbigx(:,n*((knew-1)*trials+ellnew-1)+1:n*(trials*(knew-1)+ellnew)))>0

           [objave,objsd,dupave,dupsd,rejave,rejsd,aveassign,objval]=sample_cases_performance_indepy(C,D,r,q,newbigx(:,n*((knew-1)*trials+ellnew-1)+1:n*(trials*(knew-1)+ellnew)),yprobs,min(5000,2^xnontriv),testyhat,testscenprobs);
 
           newtestobjs(snew,4+trials*(knew-1)+ellnew)=objave
              

           end
       end
   end
   
    if exh==0
        [opt,col]=max(newtestobjs(snew,5:4+trials*size(saasizes,1))); %%% the issue might be if there are multiple columns with opt
        newtestobjs(snew,4)=opt
        newmenunzs(snew,4)=newmenunzs(snew,col(1,1)+4)
        newtimes(snew,4)=newtimes(snew,4+col(1,1))
        
    else
        newtestobjs(snew,4)=testobjs(snew,4)
        newmenunzs(snew,4)=menunzs(snew,4)
        newtimes(snew,4)=ttimes(snew,4)
    end
    newperctimesaved(snew,4:3+trials*size(saasizes,1))=(newtimes(snew,4)*ones(1,trials*size(saasizes,1))- newtimes(snew,5:4+trials*size(saasizes,1)))/newtimes(snew,4)
    newabserror(snew,4:3+trials*size(saasizes,1))=newtestobjs(snew,4)*ones(1,trials*size(saasizes,1))- newtestobjs(snew,5:4+trials*size(saasizes,1))
    newpercerror(snew,4:3+trials*size(saasizes,1))=(newtestobjs(snew,4)*ones(1,trials*size(saasizes,1))- newtestobjs(snew,5:4+trials*size(saasizes,1)))/newtestobjs(snew,4)
       
       
    stem= sprintf('phase1%dx%d%sextra.mat',m,n,notes);
   filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_1\' stem];
   save(filename);  
   
end




if exh==1
    stem= sprintf('phase1newtotwexh%s.mat',notes);
else
   stem= sprintf('phase1newtotnoexh%s.mat',notes);
end
filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_1\' stem];
save(filename);     
      
      


