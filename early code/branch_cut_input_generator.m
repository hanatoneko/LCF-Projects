function[theta]=branch_cut_input_generator(m,n,theta,cstr,dstr,Astr,Bstr,bstr,qstr,Nstr,Mstr)

req=m;
sup=n;
[m,n]=size(Nstr);
[k,n]=size(Astr);

p=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Extract the needed vectors from our matrices A*, B*, N*, M*
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% For A* %%%%%%%%%%%%%%%
Acumnzrs=zeros(k,1);
Aindex=zeros(nnz(Astr),1);
Avals=zeros(nnz(Astr),1);
c=1;
for i=1:k
    for j=1:n
        if Astr(i,j)~=0
            if i~=k
                for w=i+1:k
                    Acumnzrs(w,1)=Acumnzrs(w,1)+1;
                end
            end
            Aindex(c,1)=j;
            Avals(c,1)=Astr(i,j);
            c=c+1;
        end
    end
end


%%% For B* %%%%%%%%%%%%%%%
Bcumnzrs=zeros(k,1);
Bindex=zeros(nnz(Bstr),1);
Bvals=zeros(nnz(Bstr),1);
c=1;
for i=1:k
    for j=1:m
        if Bstr(i,j)~=0
            if i~=k
                for w=i+1:k
                    Bcumnzrs(w,1)=Bcumnzrs(w,1)+1;
                end
            end
            Bindex(c,1)=j;
            Bvals(c,1)= Bstr(i,j);
            c=c+1;
        end
    end
end

%%% For N* %%%%%%%%%%%%%%%
Ncumnzrs=zeros(m,1);
Nindex=zeros(nnz(Nstr),1);
Nvals=zeros(nnz(Nstr),1);
c=1;
for i=1:m
    for j=1:n
        if Nstr(i,j)~=0
            if i~=m
                for w=i+1:m
                    Ncumnzrs(w,1)=Ncumnzrs(w,1)+1;
                end
            end
            Nindex(c,1)=j;
            Nvals(c,1)=Nstr(i,j);
            c=c+1;
        end
    end
end

%%% For M* %%%%%%%%%%%%%%%

Mcumnzrs=zeros(m,1);
Mindex=zeros(nnz(Mstr),1);
Mvals=zeros(nnz(Mstr),1);
c=1;
for i=1:m
    for j=1:m
        if Mstr(i,j)~=0
            if i~=m
                for w=i+1:m
                    Mcumnzrs(w,1)=Mcumnzrs(w,1)+1;
                end
            end
            Mindex(c,1)=j;
            Mvals(c,1)=Mstr(i,j);
            c=c+1;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Construct the 29-line lpcc algorithm input
%path='C:\Users\hanna\Google Drive\RPI\Research\toycode\';
name=sprintf('lpccinput%dx%dmenu%dnum%d.txt',req,sup,theta,p);
file=fopen(name,'w');
%row 1
fprintf(file,'[%d,%d,%d]\n',n,m,k);
%row 2 print c
fprintf(file,'[%5f',cstr(1));
for i=2:n
fprintf(file,',%5f',cstr(i));
end
fprintf(file,']\n');
%row 3 print d
fprintf(file,'[%5f',dstr(1));
for i=2:m
fprintf(file,',%5f',dstr(i));
end
fprintf(file,']\n');
%row 4 print b
fprintf(file,'[%5f',bstr(1));
for i=2:k
fprintf(file,',%5f',bstr(i));
end
fprintf(file,']\n');
%row 5 print q
fprintf(file,'[%5f',qstr(1));
for i=2:m
fprintf(file,',%5f',qstr(i));
end
fprintf(file,']\n');


%%% For matrix A %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nnz(Astr)==0
    %row 6
    fprintf(file,'[[%d,%d,%d],\n',k,n,1);
    %row 7
    fprintf(file,'[0');
    for i=1:k-1
        fprintf(file,',0');
    end
    fprintf(file,'],\n');
    %row 8
    fprintf(file,'[0');
    for i=2:k-1
        fprintf(file,',0');
    end
    fprintf(file,',1],\n')
    %row 9
    fprintf(file,'[%d],\n',n-1);
    %row 10
    fprintf(file,'[0]\n');
    %row 11
    fprintf(file,']\n');

else
    %row 6
    fprintf(file,'[[%d,%d,%d],\n',k,n,nnz(Astr));
    %row7
    fprintf(file,'[%d',Acumnzrs(1,1));
    for i=2:k
        fprintf(file,',%d',Acumnzrs(i,1));
    end

    fprintf(file,'],\n');
    %row 8
    fprintf(file,'[%d',nnz(Astr(1,:)));
    for i=2:k
        fprintf(file,',%d',nnz(Astr(i,:)));
    end
    fprintf(file,'],\n');
    %row 9
    fprintf(file,'[%d',Aindex(1));
    for i=2: (nnz(Astr))
        fprintf(file,',%d',Aindex(i));
    end
    fprintf(file,'],\n');
    %row 10
    fprintf(file,'[%5f',Avals(1));
    for i=2:(nnz(Astr))
        fprintf(file,',%5f',Avals(i));
    end
    fprintf(file,']\n');
    %row 11
    fprintf(file,']\n');
end

%%% For matrix B %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nnz(Bstr)==0
    %row 12
    fprintf(file,'[[%d,%d,%d],\n',k,m,1);
    %row 13
    fprintf(file,'[0');
    for i=1:k-1
        fprintf(file,',0');
    end
    fprintf(file,'],\n');
    %row 14
    fprintf(file,'[0');
    for i=2:k-1
        fprintf(file,',0');
    end
    fprintf(file,',1],\n');
    %row 15
    fprintf(file,'[%d],\n',m-1);
    %row 16
    fprintf(file,'[0]\n');
    %row 17
    fprintf(file,']\n');

else
    %row 12
    fprintf(file,'[[%d,%d,%d],\n',k,m,nnz(Bstr));
    %row 13
    fprintf(file,'[%d',Bcumnzrs(1,1));
    for i=2:k
        fprintf(file,',%d',Bcumnzrs(i,1));
    end

    fprintf(file,'],\n');
    %row 14
    fprintf(file,'[%d',nnz(Bstr(1,:)));
    for i=2:k
        fprintf(file,',%d',nnz(Bstr(i,:)));
    end
    fprintf(file,'],\n');
    %row 15
    fprintf(file,'[%d',Bindex(1));
    for i=2: (nnz(Bstr))
        fprintf(file,',%d',Bindex(i));
    end
    fprintf(file,'],\n');
    %row 16
    fprintf(file,'[%5f',Bvals(1));
    for i=2:(nnz(Bstr))
        fprintf(file,',%5f',Bvals(i));
    end
    fprintf(file,']\n');
    %row 17
    fprintf(file,']\n');
end

%%% For matrix N %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nnz(Nstr)==0
    %row 18
    fprintf(file,'[[%d,%d,%d],\n',m,n,1);
    %row 19
    fprintf(file,'[0');
    for i=1:m-1
        fprintf(file,',0');
    end
    fprintf(file,'],\n');
    %row 20
    fprintf(file,'[0');
    for i=2:m-1
        fprintf(file,',0');
    end
    fprintf(file,',1],\n')
    %row 21
    fprintf(file,'[%d],\n',n-1);
    %row 22
    fprintf(file,'[0]\n');
    %row 23
    fprintf(file,']\n');

else
    
    %row 18
    fprintf(file,'[[%d,%d,%d],\n',m,n,nnz(Nstr));
    %row 19
    fprintf(file,'[%d',Ncumnzrs(1,1));
    for i=2:m
        fprintf(file,',%d',Ncumnzrs(i,1));
    end
    fprintf(file,'],\n');
    %row 20
    fprintf(file,'[%d',nnz(Nstr(1,:)));
    for i=2:m
        fprintf(file,',%d',nnz(Nstr(i,:)));
    end
    fprintf(file,'],\n');
    %row 21
    fprintf(file,'[%d',Nindex(1));
    for i=2: (nnz(Nstr))
        fprintf(file,',%d',Nindex(i));
    end
    fprintf(file,'],\n');
    %row 22
    fprintf(file,'[%5f',Nvals(1));
    for i=2:(nnz(Nstr))
        fprintf(file,',%5f',Nvals(i));
    end
    fprintf(file,']\n');
    %row 23
    fprintf(file,']\n');
end

%%% For matrix M %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nnz(Mstr)==0
    %row 24
    fprintf(file,'[[%d,%d,%d],\n',m,m,1);
    %row 25
    fprintf(file,'[0');
    for i=1:m-1
        fprintf(file,',0');
    end
    fprintf(file,'],\n');
    %row 26
    fprintf(file,'[0');
    for i=2:m-1
        fprintf(file,',0');
    end
    fprintf(file,',1],\n')
    %row 27
    fprintf(file,'[%d],\n',m-1);
    %row 28
    fprintf(file,'[0]\n');
    %row 29
    fprintf(file,']\n');

else
    %row 24
    fprintf(file,'[[%d,%d,%d],\n',m,m,nnz(Mstr));
    %row25
    fprintf(file,'[%d',Mcumnzrs(1,1));
    for i=2:m
        fprintf(file,',%d',Mcumnzrs(i,1));
    end
    fprintf(file,'],\n');
    %row 26
    fprintf(file,'[%d',nnz(Mstr(1,:)));
    for i=2:m
        fprintf(file,',%d',nnz(Mstr(i,:)));
    end
    fprintf(file,'],\n');
    %row 27
    fprintf(file,'[%d',Mindex(1));
    for i=2: (nnz(Mstr))
        fprintf(file,',%d',Mindex(i));
    end
    fprintf(file,'],\n');
    %row 28
    fprintf(file,'[%5f',Mvals(1));
    for i=2:(nnz(Mstr))
        fprintf(file,',%5f',Mvals(i));
    end
    fprintf(file,']\n');
    %row 29
    fprintf(file,']\n');
end
fclose(file);
