function z_new=extract_motion(coord,poSel,direction)
Nf=size(coord,3);
x0=coord(poSel,:,1);
z_new=zeros(Nf,1);
for i=2:Nf
    x1=coord(poSel,:,i);
    disp=x0-x1;
    z_new(i)=disp(direction);
end

end