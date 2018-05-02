clear all
close all
clc

%% Generation parameters
fsamp=3e2;
dt=1/fsamp;

Tfin=4;
N=floor(Tfin*fsamp);

f_pass=2;
f_stop=60;

RMS_output=25;


%===============================PROCESSING=============================
%% Sample noise
disp('Sampling noise...')
ng_vec=rand(N,1)-0.5;

%% create filter
disp('Design bandpass...')
fny=fsamp/2;
w_lowpass=f_pass/fny;
w_highstop=f_stop/fny;

[b,a]=butter(4,[w_lowpass,w_highstop]);

%% filter noise
disp('Broadband filtering...')
ng_vec_filt=filtfilt(b,a,ng_vec);

% figure
% plot(ng_vec)
% hold all
% plot(ng_vec_filt)
%
% figure
% pwelch(ng_vec)
% hold all
% pwelch(ng_vec_filt)

%% scale signal
disp('Adjust amplitude...')
RMS_ng_filt=rms(ng_vec_filt);
ng_ZN=ng_vec_filt./RMS_ng_filt;

sig_out=RMS_output.*ng_ZN;

%% Transition set
dg=input('Insert transition window?...(y/n)','s')
if strcmp(dg,'y')
  disp('---->Transitioning...')
  fin=tukeywin(N,0.15);
  sig_out=sig_out.*fin;
end

 figure
 plot(sig_out)



%% move folder
gendir=cd;
simdir=gendir(1:end-15);
cd(simdir)

%% write file
fnam='drive_sig.dat';
disp(strcat('Saving output to ',fnam,' ...'))
dlmwrite(fnam,sig_out);
cd(gendir)
