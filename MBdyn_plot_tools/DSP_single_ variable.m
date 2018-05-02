clear all
close all
clc

%=============================================================
%% Carica file

disp('Seleziona un file output MBDyn')
[ncfile,path]=uigetfile('*.nc');
fnam=strcat(path,ncfile);

%=============================================================
%% Acquisisci info
tag=ncinfo(fnam);
nvars=size(tag.Variables,2); %numero di variabili contenute nel file
varnames={};
for i=1:nvars
  varnames{i}=tag.Variables(i).Name;
end
disp('Nomi variabili caricati')

Nnodes=1;
stcr=true;
chk_tok=1;

disp('============================================')
nodeIds=ncread(fnam,'node.struct');
Nnodes=size(nodeIds,1);
disp(['Il modello MBDyn ha generato output per ', num2str(Nnodes), ' nodi'])
disp('============================================')

%=============================================================
%% Dati temporali
dt_vec=ncread(fnam,'run.timestep');
t_vec=ncread(fnam,'time');
disp('Base di tempi caricata')

%=============================================================
%% Seleziona il nodo che ti interessa
disp('============================================')
disp('Nodi caricati:')
disp(nodeIds)
node_sel=input('Seleziona nodo... ');
%=============================================================
%% carica dati
disp('============================================')
disp('Caricamento dati nodo')
Pos=ncread(fnam,strcat('node.struct.',num2str(node_sel),'.X'));
Vel=ncread(fnam,strcat('node.struct.',num2str(node_sel),'.XP'));
disp('============================================')

%% Plotta
figure
plot(t_vec,Pos)
title('Position')
legend('x','y','z')

figure
plot(t_vec,Vel)
title('Velocity')
legend('x','y','z')

%% Autospettro
Nspe=8;
[spPos.X,freq.X] = pwelch(Pos(1,:),2^Nspe,0.5,2^Nspe,1./(dt_vec(end)));
[spPos.Y,freq.Y] = pwelch(Pos(2,:),2^Nspe,0.5,2^Nspe,1./(dt_vec(end)));
[spPos.Z,freq.Z] = pwelch(Pos(3,:),2^Nspe,0.5,2^Nspe,1./(dt_vec(end)));

figure
semilogy(freq.X,spPos.X,'b')
hold all
semilogy(freq.Y,spPos.Y,'r')
semilogy(freq.Z,spPos.Z,'k')
xlim([0 100])

[spVel.X,freq.X] = pwelch(Vel(1,:),2^Nspe,0.5,2^Nspe,1./(dt_vec(end)));
[spVel.Y,freq.Y] = pwelch(Vel(2,:),2^Nspe,0.5,2^Nspe,1./(dt_vec(end)));
[spVel.Z,freq.Z] = pwelch(Vel(3,:),2^Nspe,0.5,2^Nspe,1./(dt_vec(end)));

figure
semilogy(freq.X,spVel.X,'b')
hold all
semilogy(freq.Y,spVel.Y,'r')
semilogy(freq.Z,spVel.Z,'k')
xlim([0 100])

