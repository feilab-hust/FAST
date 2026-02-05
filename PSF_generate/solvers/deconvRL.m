% oLaF - a flexible 3D reconstruction framework for light field microscopy
% Copyright (c)2017-2020 Anca Stefanoiu

function recon = deconvRL_1(forwardFUN, backwardFUN, img, iter, init, H, Ht,img_name,save_Path)
% Richardson-Lucy deconvolution algorithm
fprintf('\nDeconvolution:')

% Initialize volume
recon = init;
view_save=fullfile(save_Path,'view_iter30.tif');
temp_view_stack=zeros(size(img,1),size(img,2),3);
for i = 1:iter
    tic
    bpjError = zeros(size(recon));
    for view = 1:7
    H_temp = H(:,:,view,:);
    Ht_temp = Ht(:,:,view,:);
    img_temp = img(:,:,view);
    fpj = forwardFUN(H_temp,recon);
    if i == 10
        temp_view_stack(:,:,view)=fpj;
    end
    
    % compute error towards the real image
    errorBack = img_temp./fpj;
    
    % make sure the computations are safe
    errorBack(isnan(errorBack)) = 0;
    errorBack(isinf(errorBack)) = 0;
    errorBack(errorBack < 0) = 0;
    
    % backproject the error
    bpjError = bpjError+backwardFUN(Ht_temp,errorBack);
    
    % update the result
    end
    recon = recon.*bpjError;
    ttime = toc;
    fprintf(['\niter ' num2str(i) ' | ' num2str(iter) ', took ' num2str(ttime) ' secs']);
    if mod(i,10)==0 && i~=0
        recon = gather(recon);
        str_save=fullfile(save_Path,sprintf('Deconv_iter%d.tif',i));
        write3d(recon,str_save,32)
    end
end