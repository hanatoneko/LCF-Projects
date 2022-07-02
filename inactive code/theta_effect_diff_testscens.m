 function[]=theta_effect_diff_testscens(notes)
 %this code is similar to theta_effect_onesize except each solution is
 %tested with a new set of generated test scenarios (instead of using the
 %same test scenario set for the same problem instance)
 
%the input is the different problem sizes to test, one entry is
%'m,n.' Time limit is 500s and optimality gap is 0.01.
%The solutions are calculated with four different theta sizes  and four
%different sample sizes.
%menuave is the average menu size, menuposave is the average menu size
%among drivers who were offered a nonempty menu
% samp=size(samples,1);
% simobjs=zeros(size(probsizes,1)*4,samp);
% testobjs=zeros(size(probsizes,1)*4,samp);
% times=zeros(size(probsizes,1)*4,samp);
% xdiffs=zeros(size(probsizes,1)*4,samp-1);
% menuave=zeros(size(probsizes,1)*4,samp);
% menuposave=zeros(size(probsizes,1)*4,samp);

notes='difftestscens'

m=20;
n=20;
thetasizes=[1;3;5;10;20];
numthetas=5;
trials=10;
testsamps=5000;

%%% parameter values
Clong=zeros(m,n*trials);
Dlong=zeros(m,n*trials);
rlong=zeros(m,trials);
drandlong=zeros(m,n*trials);
Oilong=zeros(m,trials);
Dilong=zeros(m,trials);
Ojlong=zeros(n,trials);
Djlong=zeros(n,trials);
yprobslong=zeros(m,n*trials);
saayhatlong=zeros(m*trials,n*100);
saascenprobslong=zeros(trials,100);
saascenbaselong=zeros(trials,100);
saascenexplong=zeros(trials,100);

%%%% after solving
objlong=zeros(numthetas,trials);
xlong=zeros(m*numthetas,n*trials);
vlong=zeros(m*trials*numthetas,n*100);
zlong=zeros(m*trials*numthetas,n*100);
wlong=zeros(m*trials*numthetas,100);
timeslong=zeros(numthetas,trials);

%perf analysis

testyhatlong=zeros(m*trials*numthetas,n*testsamps);
testscenprobslong=zeros(trials*numthetas,testsamps);
testscenbaselong=zeros(trials*numthetas,testsamps);
testscenexplong=zeros(trials*numthetas,testsamps);

testobjavelong=zeros(numthetas,trials);
testobjlong=zeros(trials*numthetas,testsamps);
testvlong=zeros(m*trials*numthetas,n*testsamps);
testzlong=zeros(m*trials*numthetas,n*testsamps);
testwlong=zeros(m*trials*numthetas,testsamps);
aveassignlong=zeros(m*numthetas,n*trials);


for t=1:trials

    [C,D,r,q,yprobs,Oi,Di,Oj,Dj,drand]=generate_params(m,n,1);
    Clong(:,(t-1)*n+1:t*n)=C;
    Dlong(:,(t-1)*n+1:t*n)=D;
    rlong(:,t)=r;
    drandlong(:,t)=drand;
    Oilong(:,t)=Oi;
    Dilong(:,t)=Di;
    Ojlong(:,t)=Oj;
    Djlong(:,t)=Dj;
    yprobslong(:,(t-1)*n+1:t*n)=yprobs;  
    %x stores all menus from a given m and n, since we want the same
    %scens across theta sizes and we want to compare menu differences
    %between menus with different sample sizes
    xunion=zeros(m,n);
         
   [yhat,scenprobs,newretention,scenbase,scenexp]=filter_scens(m,n,yprobs,0,0,0,1000000,'t',100);
    saayhatlong((t-1)*m+1:t*m,:)=yhat;
    saascenprobslong(t,:)=scenprobs;
    saascenbaselong(t,:)=scenbase;
    saascenexplong(t,:)=scenexp;  
       
    for s=1:numthetas
        theta=thetasizes(s,1);
       %solve with the current and theta
        tic
       [obj,gap,x,v,z,w]=fixed_y_prob_cplex_dot(C,D,r,theta,q,yprobs,yhat,scenprobs,0,0,500,0.01,0);
        toc
        
        xunion=min(ones(m,n),x+xunion);
        timeslong(s,t)=toc;
        objlong(1,t)=obj;
        xlong((s-1)*m+1:s*m,(t-1)*n+1:t*n)=x;
        vlong((s-1)*m*trials+(t-1)*m+1:(s-1)*m*trials+t*m,:)=v;
        vlong((s-1)*m*trials+(t-1)*m+1:(s-1)*m*trials+t*m,:)=z;
        wlong((s-1)*m*trials+(t-1)*m+1:(s-1)*m*trials+t*m,:)=w;
 

    
    
    %%%now for a performance analysis on all menus for current instance
    nontrivial=nnz(x.*yprobs)-size(find(x.*yprobs==1),1);
         [testyhat,testscenprobs,testscenbase,testscenexp]=indepy_generate_scens(x.*yprobs,min(5000,2^nontrivial),0);
        testyhatlong((s-1)*trials*m+(t-1)*m+1:(s-1)*trials*m+t*m,1:min(5000,2^nontrivial)*n)=testyhat;
        testscenprobslong((s-1)*trials+t,1:min(5000,2^nontrivial))=testscenprobs;
        testscenbaselong((s-1)*trials+t,1:min(5000,2^nontrivial))=testscenbase;
        testscenexplong((s-1)*trials+t,1:min(5000,2^nontrivial))=testscenexp;
    
            [objave1,objsd,dupave1,dupsd,rejave,rejsd,aveassign1,objvals1,vfull1,zfull1,wfull1]=sample_cases_performance_indepy(C,D,r,q,xlong((s-1)*m+1:s*m,(t-1)*n+1:t*n),yprobs,min(5000,2^nontrivial),testyhat,testscenprobs);
            testobjavelong(s,t)=objave1;
            testobjlong((s-1)*trials+t,1:min(5000,2^nontrivial))=objvals1;
            testvlong((s-1)*m*trials+(t-1)*m+1:(s-1)*m*trials+t*m,1:min(5000,2^nontrivial)*n)=vfull1;
            testzlong((s-1)*m*trials+(t-1)*m+1:(s-1)*m*trials+t*m,1:min(5000,2^nontrivial)*n)=zfull1;
            testwlong((s-1)*m*trials+(t-1)*m+1:(s-1)*m*trials+t*m,1:min(5000,2^nontrivial)*n)=wfull1;
            aveassignlong((s-1)*m+1:s*m,(t-1)*n+1:t*n)=aveassign1;

        end
end
stem= sprintf('phase3thetaeffect%s.mat',notes);

filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\phase_3\' stem];
save(filename);

