function [new_coord]=gira_coords(coords,T,R)
Nf=size(coords,3);
new_coord=coords;
for i=1:Nf
   for j=1:7
      p0=coords(j,:,i)';
      p1=p0-T';
      p2=R*p1;
      new_coord(j,:,i)=p2';
   end
    
end

end