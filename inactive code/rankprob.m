function[prob]=rankprob(u,mu,sigma)
%%%this function takes a one driver's utility vector and utility
%%%distributions and calculates the probability that the given ranking
%%%occurs
%%% however I realized this method is not accurate...

[m,n]=size(u);
[sorted,index]=sort(u,'descend');
prob=1;
prob2=1;

for i=1:m-1
       newmu=mu(index(i))-mu(index(i+1));
       newsigma=sqrt((sigma(index(i)))^2+(sigma(index(i+1)))^2);
       prob=prob*(1-normcdf(newmu/newsigma));
%        for k=i+1:m
%           newmu=mu(index(i))-mu(index(k));
%           newsigma=sqrt((sigma(index(i)))^2+(sigma(index(k)))^2);
%           prob2=prob2*(1-normcdf(newmu/newsigma));
%        end
           
end
%prob=(prob+prob2)/2;