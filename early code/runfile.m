name=sprintf('branchandcutrun100.txt');
file=fopen(name,'w');
for i=1:1
fprintf(file,'LPCC -m b -f 3 lpccinput1x1menu2num%d.txt\n',i);
end

type 'branchandcutrun100.txt'