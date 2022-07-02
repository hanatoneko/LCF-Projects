function[difference,objs,simobjs]=menu_convergence(m,n,theta,kpercentage,equal,lwr,samples,trials)

[C,D,r,a,q]=data_generation(m,n);
C
D
r
[topkpicks,yprobs]=indepy_generate_yprobs(m,n,kpercentage);

fullx=zeros(m,n,trials);
objs=zeros(1,trials);
simobjs=zeros(1,trials);
samps=[5000 10000 10000 50000 50000];
for k=1:trials
    %[yhat,scenprobs]=indepy_generate_scens(m,n,topkpicks,yprobs,samps(1,k));
    [yhat,scenprobs]=indepy_generate_scens(m,n,topkpicks,yprobs,samples);

    [obj,x,v,z,w]=fixed_y_prob(C,D,r,a,theta,q,yhat,scenprobs,topkpicks,equal,lwr);
    fullx(:,:,k)=x;
    simobjs(1,k)=obj;
    [objave,objsd,dupave,dupsd,rejave,rejsd]=sample_cases_performance_indepy(C,D,r,a,x,yprobs,10000);
    objs(1,k)=objave;

end

difference=zeros(trials,trials);
for i=1:trials-1
    for j=i+1:trials
        difference(i,j)=sum(sum(abs(fullx(:,:,i)-fullx(:,:,j))))/2;
    end
end