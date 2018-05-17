clear all
close all
clc

%% Load blob data
blob_0=load('blobs_cam0.mat');
blob_1=load('blobs_cam1.mat');

Nf=size(blob_0.blob_storage,3);

data_corr= [1, 1; ...
    2 2; ...
    3 3; ...
    4 4; ...
    5 5; ...
    6 7; ...
    7 6];
connex=[ 4 6;...
        6 3;...
        3 2;...
        3 7; ...
        3 5; ...
        3 1];
%% Load calib
calib_data_vec=dlmread('camera_calib.csv',';',0,1);
calib.T=calib_data_vec(21:23);
calib.om=deg2rad(calib_data_vec(24:26));
calib.fc_left=calib_data_vec(1:2);
calib.cc_left=calib_data_vec(9:10);
calib.kc_left=calib_data_vec(4:8);
calib.alpha_c_left=0;
calib.fc_right=calib_data_vec(11:12);
calib.cc_right=calib_data_vec(19:20);
calib.kc_right=calib_data_vec(14:18);
calib.alpha_c_right=0;

%% Cycle through
coords=zeros(7,3,Nf);

for i=1:Nf
   for j=1:7
       blobSX=blob_0.blob_storage(data_corr(j,1),:,i);
       blobDX=blob_1.blob_storage(data_corr(j,2),:,i);
       [XL,~] = stereo_triangulation(blobSX',blobDX',calib.om,calib.T,calib.fc_left,calib.cc_left,calib.kc_left,calib.alpha_c_left,calib.fc_right,calib.cc_right,calib.kc_right,calib.alpha_c_right);
       coords(j,:,i)=XL';
   end
   disp(strjoin({'Frame', num2str(i),'processed...'}))
end

%% Inspection

poSel=7;

x0=coords(poSel,:,1);
z=zeros(Nf,1);
for i=2:Nf
    x1=coords(poSel,:,i);
    disp=x0-x1;
    z(i)=disp(3);
end

figure
plot(z)

frSel=124;
conf0=coords(:,:,frSel);
plotta_cruci(conf0,connex);
%% Coordinate transform
orig=coords(4,:,1);
p_x=coords(6,:,1);
p_y=coords(3,:,1);
v_x=p_x-orig;
v_y=p_y-p_x;
v_z=cross(v_x,v_y);
vers_x=v_x/norm(v_x);
vers_y=v_y/norm(v_y);
vers_z=v_z/norm(v_z);
Ride=[vers_x',vers_y',vers_z'];

new_positions=gira_coords(coords,orig,Ride');

plotta_cruci(new_positions(:,:,124),connex);



%% Analisi modale sperimentale
signals_z=zeros(Nf,7);
for i=1:7
   signals_z(:,i)=extract_motion(new_positions,i,2); 
end

%DIsplacement based
excitation=signals_z(1:3001,4);
response=[signals_z(1:3001,1:3),signals_z(1:3001,5:end)];

%Force based
% excitation=load('force_excitation.dat');
% response=signals_z(1:3001,:);
tempo=[0:3000]/100;

figure
plot(tempo,excitation)
hold on
plot(tempo,response(:,4))




Nsig=9;
id_int=[10 45];
fs=100;

figure
% modalfrf(excitation,response(:,[1 2 5 7]),fs,hanning(2^Nsig),'Estimator','H1','Sensor','dis');
modalfrf(excitation,response(:,[1 2 4 6]),fs,hanning(2^Nsig),'Estimator','H1','Sensor','dis');

% [H1_ex,f]=modalfrf(excitation,response,fs,hanning(2^Nsig),'Estimator','H1','Sensor','dis');
[H1_ex,f]=tfestimate(excitation,response,hanning(2^Nsig),[],[],fs);

figure
modalsd(H1_ex,f,fs,'MaxModes',14,'FreqRange',id_int);
legend off
[sel]=ginput();
phFreq=sel(:,1);

% Fitta FRF con LSCE
nmod=3;
[fn,h,ODSs,DFRF] =modalfit(H1_ex,f,fs,nmod,'FreqRange',id_int,'PhysFreq',phFreq);

