function plotta_frf_id(H1,f,groups,labels)
% [~,n]=size(H1);
N=size(groups,2);
figure
for j=1:N
    
       Hgroup=H1(:,groups{j});
       Hp=mean(Hgroup,2);
       semilogy(f,abs(Hp))
       hold all
    
end
xlabel('Frequency [Hz]')
ylabel('FRF modulus')
legend(labels)

end