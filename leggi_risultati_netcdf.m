clear all
close all
clc

%=============================================================
%% Carica file

disp('Seleziona un file output MBDyn')
fnam=uigetfile('*.nc');
%fnam='trave_sospesa.nc';

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

%% Scopri nodi

