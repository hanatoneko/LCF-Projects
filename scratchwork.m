true_sorted =[ 1.1787    0.8739   -0.2460
    1.2787    1.8703    0.3908
    0.4806    0.7243    0.5947
    0.3637   -0.0503    0.6628
    0.5765    1.2779    0.7256
    0.7916    0.8085    0.7713
    1.7732    0.6715    0.8021
    1.7201    1.3569    0.8469
    1.7638    1.1257    1.6208
    0.9447    1.0885    1.6224];


heur_sorted =[    0.5785
    0.8889
    0.5324
    0.4782
    0.9364
    1.1076
    0.6559
    0.7800
    1.1011
    0.9950];

ave=[0.6022
1.179933333
0.599866667
0.3254
0.86
0.790466667
1.082266667
1.307966667
1.503433333
1.218533333];

normheur=norm(heur_sorted-ave);
norm1=norm(true_sorted(:,1)-ave);
norm2=norm(true_sorted(:,2)-ave);
norm3=norm(true_sorted(:,3)-ave);

blah=[1;1;1;.5;.5;0;0;0;-1];
quantile(blah,1)

results=[2.2366	2.55	2.2641	1.957	2.350233333;
2.8357	2.7797	2.3036	2.3519	2.639666667;
2.656	2.6286	2.3806	2.5321	2.555066667;
2.802	2.4482	2.4436	2.4667	2.5646;
2.6716	2.684	2.506	2.4389	2.620533333;
2.6774	3.0545	2.5811	2.4623	2.771;
2.9217	3.117	2.5878	2.8059	2.8755;
2.7481	2.8896	2.6495	2.8372	2.7624;
2.3811	2.3889	2.754	2.6792	2.508;
2.4068	2.921	2.9823	2.4933	2.770033333];

heur_error=norm(results(:,4)-results(:,5))
error1=norm(results(:,1)-results(:,5))
error2=norm(results(:,2)-results(:,5))
error3=norm(results(:,3)-results(:,5))

% lwr=0;
% theta=3
% equal=0;
% trials=1;
% k=1;
% x=[1,1,0,1;
%     1,1,0,0;
%     1,0,0,1]
% [m,n]=size(x);
% 
% menu = cell(1,n);
% for j=1:n
%     if nnz(x(:,j))>0
%         menu{j} = find(x(:,j));
%     else
%         menu{j} = 0;
%     end
% end
% menu{3}
% size(menu{3})
% % menu{4}
% % menu{1,2}
% % menu{3}==0
% % for i=1:size(menu{1})
% %     i
% % end
% trials=1;
% k=1;
% 
% 
% stop=[];
% menu = cell(1,n);
% for j=1:n
%     if nnz(x(:,j))>0
%         menu{j} = vertcat(0,find(x(:,j)));
%         dim=size(menu{j});
%         stop=vertcat(stop, dim(1));
%     else
%         menu{j} = 0;
%         stop=vertcat(stop,1);
%     end
% end
% stop
% col=ones(n,1);
% check=1;
% curr=1;
% 
% %%% calculate total number of scenarios
% % totscen=1;
% % for j=1:n
% %     if menu{j}~0
% %         totscen=totscen*(size(menu{j})+1);
% %     end
% % end
% 
% 
% %%%%%%%%%%%%%%%%% big loop over each scenario
% while true
%     y = zeros(m,n);
%     %%% set y values based on current column choices
%     for j=1:n
%         temp=menu{j};
%         temp(col(j,1));
%         if temp(col(j,1)) ~= 0
%             y(temp(col(j,1)),j)=1;
%         end
%     end
%     y
%     %%% performance analysis
%    % [obj,dup,rej,v,y,w,z]=menu_performance(C,D,r,y);
% 
%     %%% advance col choices to the next combination of choices
%     if col==stop
%         break
%     end
%     while true
%         if col(check)<stop(check)
%             col(check)=col(check)+1;
%             check=1;
%             break
%         end
%         col(check)=1;
%         check=check+1;
%         if (check-1)==curr
%             curr=curr+1;
%             if stop(curr)==1
%                 curr=curr+1;
%             end
%             check=1;
%             col(curr,1)=col(curr,1)+1;
%             break
%         end
%         
%     end 
%     
%     
% end
% m=10;
% u=zeros(m,1);
%  mu=rand(m,1)-0.5*ones(m,1)
%  sigma=0.5*rand(m,1)
%  for i=1:m
%      u(i)=normrnd(mu(i),sigma(i));
%  end
%  u
% U=perms(u)';
% totprob=0;
% for j=1:size(U,2)
%     [prob]=rankprob(U(:,j),mu,sigma);
%     totprob=totprob+prob;
% end
% totprob

% range=[1:1:20];
% picks=zeros(3,2)
% picks(:,1)=randsample(range,3)'
% picks(:,2)=randsample(range,3)'
% picks=sort(picks)
% if ~ismember(3,picks(:,1))
%     b=20
% end
% j=1;
% menu = cell(1,3);
% menu{j}=[1;3;6];
% temp=menu{j}
% size(temp,1)
%            dim=size(menu{j})
%            accepted=de2bi(3,dim(1)) 
%            
% mean([1;2],[.2;.8])

x=[0:1:10];
y1=-10*(x/10).^0.5;
y2=-10*(x/10).^2;

figure
%plot(x,y1,x,x,x,y2
scatter(x,y2)
hold on
scatter(x,-x)
hold on
scatter(x,y1)
xlabel('arc')
ylabel('arc length (penalty)')
xticks([0 1 2 3 4 5 6 7 8 9 10])

legend('Unpopular','Average', 'Popular','Location','Best')

% hold on
% scatter(x,x)
% 
% hold on 
% scatter(x,y2)
  