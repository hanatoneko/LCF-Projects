function[optmenu,optruntime,optobj,menus,runtimes,objs,samesizediff,samesizetot,optdiff,optdifftot]=exhaustive_saa_analysis(m,n,theta,equal,lwr,notes,sizes,trials,exh)


numsizes=size(sizes,1);


attempts=1;
skip=0;
%generate yprobs that has at least 2^10 scens, else try again
while true
   [C,D,r,q,yprobs,Oi,Di,Oj,Dj,drand]=generate_params(m,n,1);
   [yhat,scenprobs]=indepy_generate_scens(yprobs,50,0);
   nontrivial=nnz(yprobs)-(m*n-nnz(yprobs-ones(m,n)));
   totscens=2^nontrivial;
   if totscens>=2^16
       if totscens<=2^18
           if nnz(sum(yprobs,1))==n
               if nnz(sum(yprobs,2))==m
                   nontrivial
                   attempts
                   yprobs
                   break
               end
           end
       end
   end
   if attempts>=100
       skip=1;
       break
   end
   attempts=attempts+1;
    if skip==1
        break
    end
end

menus=zeros(m*numsizes,n*trials);
runtimes=zeros(numsizes,trials);
objs=zeros(numsizes,trials);
samesizediff=zeros(m*numsizes,n*(trials*(trials-1))/2);
samesizetot=zeros(numsizes,(trials*(trials-1))/2);
optdiff=zeros(m*numsizes,n*trials);
optdifftot=zeros(numsizes,trials);

%%% first find the true optimal menu
if exh==1
    tic
    [yhat,scenprobs]=indepy_generate_scens(yprobs,'all',0);
    [optobj,optmenu,v,z,w]=fixed_y_prob(C,D,r,theta,q,yhat,scenprobs,equal,lwr);
    optmenu

    toc
    optruntime=toc;

    stem= sprintf('saasize%dx%dwexh%s.mat',m,n,notes);
    filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\variable_data\' stem];
    save(filename);
end

for k=1:numsizes
    for ell=1:trials
        tic
        [yhat,scenprobs]=indepy_generate_scens(yprobs,sizes(k,1),0);
        [obj,x,v,z,w]=fixed_y_prob(C,D,r,theta,q,yhat,scenprobs,equal,lwr);

        toc
        runtimes(k,ell)=toc;
        menus((k-1)*m+1 : k*m,(ell-1)*n+1 : ell*n)=x
        menunontrivial=nnz(x)-(m*n-nnz(x.*yprobs-ones(m,n)));
        if menunontrivial>12
            perfsamps=5000;
        else
            perfsamps='all';
        end
        [objave,objsd,dupave,dupsd,rejave,rejsd]=sample_cases_performance_indepy(C,D,r,q,x,yprobs,perfsamps);
        objs(k,ell)=objave;
        if exh==1
            optdiff((k-1)*m+1:k*m ,(ell-1)*n+1 : ell*n)=optmenu-x;
            optdifftot(k,ell)=0.5*nnz(optmenu-x);
        end
        
        if exh==1
            stem= sprintf('saasize%dx%ds%dtrial%dwexh%s.mat',m,n,sizes(k,1),ell,notes);
        else
            stem= sprintf('saasize%dx%ds%dtrial%dnoexh%s.mat',m,n,sizes(k,1),ell,notes);
        end
        filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\variable_data\' stem];
        save(filename);
    end
end

%%% now to calculate the differences between the menus
bit='calculating differences'

for k=1:numsizes
    tally=1;
   for t=1:(trials-1) 
       for u=(t+1):trials
           samesizediff((k-1)*m+ 1: k*m, (tally-1)*n+1:tally*n) = menus((k-1)*m+1 : k*m,(t-1)*n+1 : t*n) - menus((k-1)*m+1 : k*m,(u-1)*n+1 : u*n)
           samesizetot(k,tally)=0.5*nnz(menus((k-1)*m+1 : k*m,(t-1)*n+1 : t*n)-menus((k-1)*m+1 : k*m,(u-1)*n+1 : u*n))
           tally=tally+1;
       end
   end
end

if exh==1
   stem= sprintf('saasize%dx%ddiffswexh%s.mat',m,n,notes);
else
    stem= sprintf('saasize%dx%ddiffsnoexh%s.mat',m,n,notes);
end
filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\Paper_experiments\variable_data\' stem];
save(filename);
