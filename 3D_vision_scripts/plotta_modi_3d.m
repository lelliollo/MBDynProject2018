function plotta_modi_3d(coords,link,ODSs,nmode,Dof_exc,Dof_nodes,input_node,mag)
plot3(coords(:,1),coords(:,2),coords(:,3),'bo','LineWidth',1.5)
hold on

for i=1:7
   text(coords(i,1),coords(i,2),coords(i,3),num2str(i),'FontSize',12) 
end

[m,n]=size(link);
for i=1:m
    plot3([coords(link(i,1),1) coords(link(i,2),1)],[coords(link(i,1),2) coords(link(i,2),2)],[coords(link(i,1),3) coords(link(i,2),3)],'k--')
    drawnow
%     system pause
end
axis equal

%Monta Ods
[Npo,dofs]=size(coords);
deflections=zeros(Npo-1,dofs);

modesel=ODSs(:,nmode);
deflections_x=modesel(Dof_nodes{1});
deflections_y=modesel(Dof_nodes{2});
deflections_z=modesel(Dof_nodes{3});
deflections(:,1)=real(deflections_x);
deflections(:,2)=real(deflections_y);
deflections(:,3)=real(deflections_z);
forzante=Dof_exc;
def_shape=[deflections(1:input_node-1,:); forzante; deflections(input_node:end,:)];
shape=coords+mag*def_shape;

plot3(shape(:,1),shape(:,2),shape(:,3),'ro','LineWidth',1.5)
for i=1:m
    plot3([shape(link(i,1),1) shape(link(i,2),1)],[shape(link(i,1),2) shape(link(i,2),2)],[shape(link(i,1),3) shape(link(i,2),3)],'r')
    drawnow
%     system pause
end
end