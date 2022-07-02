function[newtestobjs,newtimes,newabserror,newpercerror]=phase0_extra_trials(sizes,testsizes,exh,notes)
%this code is to follow up on the phase 0 (benchmark sizes test) for when
%we don't have exhaustive, doing the same experiment with the same
%instances but with more trials because we did not observe monotonic error



%column labels are m,n,nontrivial,exh,10 trials for each samp size: 500,1000,5000,10000 
numcols=40*size(testsizes,1)+1+3;
newtestobjs=zeros(size(sizes,1),numcols);
newtimes=zeros(size(sizes,1),numcols);
newabserror=zeros(size(sizes,1),numcols-1);
newpercerror=zeros(size(sizes,1),numcols-1);

newtestobjs(:,1:2)=sizes(:,1:2);
newtimes(:,1:2)=sizes(:,1:2);
newabserror(:,1:2)=sizes(:,1:2);
newpercerror(:,1:2)=sizes(:,1:2);



for snew=1:size(sizes,1)
    %%% load menu and testobjs, errors, etc from the 3 trials, incl the exh
    %%% or 100k measurements
    m=sizes(snew,1)
    n=sizes(snew,2)
       stem= sprintf('phase0%dx%dt3%s.mat',m,n,notes);
       filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_0\' stem];
       
       load(filename);
       ttimes=times(:,:);
       newtestobjs(snew,3)=testobjs(snew,3);
       newtimes(snew,3)=ttimes(snew,3);
       newabserror(snew,3)=abserror(snew,3);
       newpercerror(snew,3)=percerror(snew,3);
       newtestobjs(snew,4)=testobjs(snew,4);
       newtimes(snew,4)=ttimes(snew,4);
       
       %%% recover data from first three trials
       for knew=1:size(testsizes,1)
           for ellnew=1:3
               newtestobjs(snew,4+40*(knew-1)+ellnew)=testobjs(snew,4+3*(knew-1)+ellnew);
               newtimes(snew,4+40*(knew-1)+ellnew)= ttimes(snew,4+3*(knew-1)+ellnew);
               newabserror(snew,3+40*(knew-1)+ellnew)=abserror(snew,3+3*(knew-1)+ellnew);
               newpercerror(snew,3+40*(knew-1)+ellnew)=percerror(snew,3+3*(knew-1)+ellnew);
           end
       end
       
 %%% new performance analysis
  
   %%% now do seven more trials for each perf size
   for knew=1:size(testsizes,1)
       for ellnew=4:40
           testsizes(knew,1)
           tic
           [objave,objsd,dupave,dupsd,rejave,rejsd,aveassign,objval]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,testsizes(knew,1),0,0);
           toc
           newtestobjs(snew,4+40*(knew-1)+ellnew)=objave
           newtimes(snew,4+40*(knew-1)+ellnew)=toc
           newabserror(snew,3+40*(knew-1)+ellnew)=opt-objave
           newpercerror(snew,3+40*(knew-1)+ellnew)=(opt-objave)/opt
              
           stem= sprintf('phase0%dx%dt%d%s.mat',m,n,ellnew,notes);
           filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_0\' stem];
           save(filename);
           
       end
   end
   

   
       if exh==1
            stem= sprintf('phase0newtotwexh%s.mat',notes);
       else
           stem= sprintf('phase0newtotnoexh%s.mat',notes);
       end
       filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_0\' stem];
       save(filename);
    end
end
               
       
      
      


