% SP4.m        - This procedure of finding one-to-many shortest path, 
%                Dijkstra's Algorithm
%
% Syntax:      - OnePath=SP3(Cost,O,D,Nodenum)
%
% Input parameters:
%    Cost      - A matrix saving the node-link index and the link travel
%                time computed by BPR function.
%    Ori       - Origin node number
%    Des       - Destination nodes vector
%    Nodenum   - Total nodes number of network
%
% Output parameters:
%    OnePath   - A node-path vector, saving predecessor node in the path
%
% Author:      - Xiaozheng He
% History      - 2005-1-3 file created

function OnePath=shortest(Cost,Ori,Des,Nodenum)

A=sparse(Cost(:,1),Cost(:,2),Cost(:,3),Nodenum,Nodenum);
% Sparse matrix saving the adjacent node

OnePath=ones(1,Nodenum)*Ori;
OnePath(Ori)=0;

Omega=(1:Nodenum);

SetS=Ori;
SetO=setdiff(Omega,SetS);
for i1=1:Nodenum-1
    idxS=find(A(Ori,SetO)); % Non-zero weight node number, tentative visit
    [y,j]=min(A(Ori,SetO(idxS)));
    nextNode=SetO(idxS(j));
    Des=setdiff(Des,nextNode);
    if length(Des)==0
        break;
    end

    idxN=find(A(nextNode,:)); % Adjacent node number vector current node
    for i2=1:length(idxN)
        if A(Ori,idxN(i2))==0 | A(Ori,idxN(i2))>y+A(nextNode,idxN(i2))
            A(Ori,idxN(i2))=y+A(nextNode,idxN(i2));
            OnePath(idxN(i2))=nextNode;
        end
    end
    SetS=union(SetS,nextNode);
    SetO=setdiff(SetO,nextNode);
end
