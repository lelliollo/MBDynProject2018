function [cdof]=combina_dofs(coord1,coord2,Rot_mat)
N=length(coord1);
cdof=zeros(N,1);
for i=1:N
   V=Rot_mat*[coord1(i);coord2(i)];
    cdof(i)=V(1);
end

end