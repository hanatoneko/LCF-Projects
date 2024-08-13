function[binform]=dec2binarray(decform,cols)
%converts a base-10 integer decform into a binary number that has cols
%digis (so the first digits are  0 if it's smaller)
binform=zeros(1,cols);
digit=cols-1;
while true
    if decform>=2^digit
        binform(cols-digit)=1;
        decform=decform-2^digit;
    end
    if decform==0
        break
    end
    digit=digit-1;
end