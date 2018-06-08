function plotta_cruci(coords,link)
figure
plot3(coords(:,1),coords(:,2),coords(:,3),'bo','LineWidth',1.5)
hold on

for i=1:7
   text(coords(i,1),coords(i,2),coords(i,3),num2str(i),'FontSize',12) 
end

[m,n]=size(link);
for i=1:m
    plot3([coords(link(i,1),1) coords(link(i,2),1)],[coords(link(i,1),2) coords(link(i,2),2)],[coords(link(i,1),3) coords(link(i,2),3)],'k')
    drawnow
%     system pause
end
axis equal
end