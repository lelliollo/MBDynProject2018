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
    displaceme=x0-x1;
    z(i)=displaceme(3);
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
v_z=p_y-p_x;
v_y=cross(v_x,v_z);
vers_x=v_x/norm(v_x);
vers_y=v_y/norm(v_y);
vers_z=v_z/norm(v_z);
Ride=[vers_x',vers_y',vers_z'];

new_positions=gira_coords(coords,orig,Ride');

plotta_cruci(new_positions(:,:,124),connex);



%% Analisi modale sperimentale
fs=200;
signals_z=zeros(Nf,7);
signals_y=signals_z;
for i=1:7
   signals_x(:,i)=extract_motion(new_positions,i,1); 
   signals_y(:,i)=extract_motion(new_positions,i,2); 
   signals_z(:,i)=extract_motion(new_positions,i,3);
   
end

%Extract excitation
excitation_x=signals_x(1:6001,1);
excitation_y=signals_y(1:6001,4);
excitation_z=signals_z(1:6001,4);
excitation_zy=combina_dofs(excitation_z,excitation_y,Rmat(pi/4));
%extract response
response_z=[signals_z(1:6001,1:3),signals_z(1:6001,5:end)];
response_y=[signals_y(1:6001,1:3),signals_y(1:6001,5:end)];
response_x=[signals_x(1:6001,1:3),signals_x(1:6001,5:end)];
response_total=[response_x, response_y, response_z];

tempo=[0:6000]/fs;

% figure
% plot(tempo,excitation_z)
% hold on
% plot(tempo,response_z(:,4))



%=========SETUP LSCE========
Nsig=9;
id_int=[10 80];
fs=200;
Nmodes=30;
%===========================

figure
% modalfrf(excitation,response(:,[1 2 5 7]),fs,hanning(2^Nsig),'Estimator','H1','Sensor','dis');
% modalfrf(excitation_zy,response_y(:,[1 2 4 6]),fs,hanning(2^Nsig),'Estimator','H1','Sensor','dis');

% [H1_ex,f]=modalfrf(excitation,response,fs,hanning(2^Nsig),'Estimator','H1','Sensor','dis');
[H1_ex,f]=tfestimate(excitation_zy,response_total,hanning(2^Nsig),[],[],fs);
plotta_frf_id(H1_ex,f,{1:6,7:12,13:18},{'X axis','Y axis','Z axis'})



figure
modalsd(H1_ex,f,fs,'MaxModes',Nmodes,'FreqRange',id_int);
legend off
[sel]=ginput();
phFreq=sel(:,1);

% Fitta FRF con LSCE
[fn,h,ODSs,DFRF] =modalfit(H1_ex,f,fs,Nmodes,'FreqRange',id_int,'PhysFreq',phFreq);

%% Plotta modo
Mag=10;
fn_MBD=[ 16.7519;...
      19.0179;...
    31.2444;...
    40.9452];
h_MBD=[1.4848;...
     0.89625; ...
     1.47251;...
      8.66328]./100;     
TitoliRighe=cell(1,4);
for i=1:4
   TitoliRighe{i}=strjoin({'Mode n.',num2str(i)}); 
end

figure
for i=1:4
subplot(2,2,i)
plotta_modi_3d(new_positions(:,:,1),connex,ODSs,i,[0 1 1],{1:6,7:12,13:18},4,Mag)
title(strjoin({'Mode',num2str(i),num2str(fn(i)),'Hz'}))
end

fn_EMA=fn;
h_EMA=h;

f_err=100*(fn_EMA./fn_MBD-1);
h_err=100*(h_EMA./h_MBD-1);

TabMod=table(fn_MBD,fn_EMA,f_err,h_MBD,h_EMA,h_err,'RowNames',TitoliRighe)

%% Animazione modi
% Mag=2;
% Nfram=100;
% fps=25;
% F(Nfram) = struct('cdata',[],'colormap',[]);
% for i=4
% 
%     figure('units','inch','position',[2,0.5,8,8]);
%     for j=1:Nfram
%         angolo=exp(1i*2*pi/Nfram*j);
%         plotta_modi_3d_anim(new_positions(:,:,1),connex,ODSs,i,[0 1 1],{1:6,7:12,13:18},4,Mag,angolo)
%         title(strjoin({'Mode',num2str(i),num2str(fn(i)),'Hz'}))
%         hold off
%         xlim([0 550])
%         ylim([-300 300])
%         zlim([-100 400])
%         drawnow
%         F(j)=getframe;
%         clc
%         disp(num2str(j))
%     end
% 
%     v=VideoWriter(strcat('Mod_',num2str(i),'.mp4'),'MPEG-4');
%     v.FrameRate=25;
%     open(v)
%     writeVideo(v,F);
%     close(v)
% end