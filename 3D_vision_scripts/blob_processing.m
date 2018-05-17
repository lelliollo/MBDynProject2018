clear all
close all
clc

%% Load images list
ImList=dir('cam0/*.jpg');
Nfile=size(ImList,1);

 global save_fig_name
 
%% PRocess cam0
blob_storage=zeros(7,2,Nfile);

for i=1:Nfile
  imLocFile=strcat(ImList(i).folder,'\',ImList(i).name);
  ImLoc=imread(imLocFile);
  if size(ImLoc,3)>1
      ImLoc=rgb2gray(ImLoc);
  end
  save_fig_name=strcat('cam0_',num2str(i),'.png');
  blobs=blob_analysis_mbd(ImLoc,30,5,[60,1000],false);
  if size(blobs,2)>7
      warning('C''è problema')
  end
  for j=1:7
     blob_storage(j,:,i)=blobs(j).Centroid; 
  end
  close all
  disp(strcat('Proc fig ',num2str(i)))
end

save('blobs_cam0.mat','blob_storage')

%% PRocess cam1
blob_storage=zeros(7,2,Nfile);
ImList=dir('cam1/*.jpg');

for i=1:Nfile
  imLocFile=strcat(ImList(i).folder,'\',ImList(i).name);
  ImLoc=imread(imLocFile);
  if size(ImLoc,3)>1
      ImLoc=rgb2gray(ImLoc);
  end
  save_fig_name=strcat('cam1_',num2str(i),'.png');
  blobs=blob_analysis_mbd(ImLoc,30,5,[60,1000],false);
  if size(blobs,2)>7
      warning('C''è problema')
  end
  for j=1:7
     blob_storage(j,:,i)=blobs(j).Centroid; 
  end
  close all
  disp(strcat('Proc fig ',num2str(i)))
end

save('blobs_cam1.mat','blob_storage')