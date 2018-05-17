function [blobs_ord]=blob_analysis_mbd(Im,th_val,cl_size,limits,plot_tok)
  [m,n]=size(Im);
  Fsp=fspecial('gaussian',5,1);
  Im=imfilter(Im,Fsp);
  %figure
  %imshow(Im)

  % sogliatura
  ImThresh=Im>th_val;

  %figure
  %imshow(ImThresh)

  % chiusura
  SE_op=strel('disk',cl_size,0);
  ImClosed=imclose(ImThresh,SE_op);

  %figure
  %imshow(ImClosed)

  % escludi strisce carattere
  [xgr,ygr]=meshgrid(1:n,1:m);
  indx=or(ygr<limits(1),ygr>limits(2));
  ImMask=logical(ImClosed.*not(indx));


  %% regionprops
  blobs=regionprops(ImMask);
  Nblobs=size(blobs,1);
  %% ordina blobs
  vc=zeros(1,Nblobs);
  for i=1:Nblobs
      vc(i)=norm(blobs(i).Centroid);
  end

  [vc_reord,ords]=sort(vc);

  for i=1:Nblobs
    blobs_ord(i)=blobs(ords(i));
  end
 
 global save_fig_name
 if plot_tok
      figure
      imshow(ImMask)
      hold on
      for i=1:Nblobs
        pos=blobs_ord(i).Centroid;
        plot(pos(1),pos(2),'ro')
        plot(pos(1),pos(2),'bx')
        text(pos(1),pos(2),num2str(i),'FontSize',12,'Color','k')
      end
      print(save_fig_name,'-dpng')
 end
  
end