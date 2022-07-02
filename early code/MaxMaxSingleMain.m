m=3;
n=3;
N=1;
theta=2;
samples=20;
directory = 'C:\Users\hanna\Google Drive\RPI\Research\toy code';
filename  = ['intderdict' num2str(m) 'x' num2str(n) 'trial' num2str(trial) '.csv'];
fileDest  = fullfile(directory,filename);
fid = fopen(fileDest, 'w') ;
fprintf(fid, 'obj,rejects,duplicates\n') ;

for trial=1:10
    for iter=1:samples
        [C,D,r,a,U1,U2,Sorted]=data_generation(m,n,N);


        %we'll record the data in a csv file


        %build an empty utility matrix and fill each entry with either the
        %corresponding U1 entry or the U2 entry--go through every possible
        %combination
   

        [obj2,v2,x2,xno2,y2,w2,z2]=MaxMaxSingle(C,D,r,a,U1,Sorted,theta);
        fprintf(fid, '%f,%d,%d\n', obj2,nnz(w2),nnz(z2)) ; 



    end
end

  
