notes='_with200';
stem= sprintf('paramandslsf%s.mat',notes);

filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Paper_experiments\parameter_values\' stem];
load(filename);

trials=100;
testsamps=5000;
notes = '';
m=20;
n=20;
theta=5;
slsfperc=0.8;

%variables from generating parameters
Chatlong=Chatlong(:,1:n*trials);
Clong=Clong(:,1:n*trials);
Dlong=Dlong(:,1:n*trials);
rlong=rlong(:,1:trials);
farelong=farelong(:,1:n*trials);
yprobslong=yprobslong(:,1:n*trials);
slsfcomplong=slsfcomplong(:,1:n*trials);
alphavalslong=alphavalslong(:,1:n*trials);
betavalslong=betavalslong(:,1:n*trials);
Oilong=Oilong(:,1:trials);
Dilong=Dilong(:,1:trials);
Ojlong=Ojlong(:,1:trials);
Djlong=Djlong(:,1:trials);
OjOiminslong=OjOiminslong(:,1:n*trials);
extradrivingtimelong=extradrivingtimelong(:,1:n*trials);
drandlong=drandlong(:,1:n*trials);

%save values from slsf scen generation and slsf soln
yhat_slsf=yhat_slsf(1:m*trials,:);
scenprobs_slsf=scenprobs_slsf(1:trials,:);
scenbase_slsf=scenbase_slsf(1:trials,:);
scenexp_slsf=scenexp_slsf(1:trials,:);
simobjs_slsf=simobjs_slsf(1,1:trials);
x_slsf=x_slsf(:,1:n*trials);
v_slsf=v_slsf(1:m*trials,:);
z_slsf=z_slsf(1:m*trials,:);
w_slsf=w_slsf(1:m*trials,:);
runtimes_slsf=runtimes_slsf(1,1:trials);
gaps_slsf=gaps_slsf(1,1:trials);




%performance analysis values slsf
testyhat_slsf=testyhat_slsf(1:m*trials,:);
testscenprobs_slsf=testscenprobs_slsf(1:trials,:);
testscenbase_slsf=testscenbase_slsf(1:trials,:);
testscenexp_slsf=testscenexp_slsf(1:trials,:);

testobjs_slsf=testobjs_slsf(1:trials,:);
testobjave_slsf=testobjave_slsf(1,1:trials);
testdupave_slsf=testdupave_slsf(1,1:trials);
testrejave_slsf=testrejave_slsf(1,1:trials);
testv_slsf=testv_slsf(1:m*trials,:);
testz_slsf=testz_slsf(1:m*trials,:);
testw_slsf=testw_slsf(1:m*trials,:);
aveassign_slsf=aveassign_slsf(:,1:n*trials);
runtimes_perf_slsf=runtimes_perf_slsf(1,1:trials);


%quality metrics for slsf
avecomp_slsf = avecomp_slsf(1,1:trials);
aveperccomp_slsf = aveperccomp_slsf(1,1:trials);
avetotprofit_slsf= avetotprofit_slsf(1,1:trials);
percposprofit_slsf= percposprofit_slsf(1,1:trials);
aveextratime_slsf=aveextratime_slsf(1,1:trials);
averejfare_slsf=averejfare_slsf(1,1:trials);


%LCF fixed scenarios
yhat_lcfinput=yhat_lcfinput(1:m*trials,:);
scenprobs_lcfinput=scenprobs_lcfinput(1:trials,:);
scenbase_lcfinput=scenbase_lcfinput(1:trials,:);
scenexp_lcfinput=scenexp_lcfinput(1:trials,:);
runtimes_scens_lcfinput=runtimes_scens_lcfinput(1,1:trials);


stem= sprintf('paramandslsf%s.mat',notes);

filename =[ 'C:\Users\horneh\Google Drive\RPI\Research\toy code\LCF_Paper_experiments\parameter_values\' stem];
save(filename,'-v7.3');