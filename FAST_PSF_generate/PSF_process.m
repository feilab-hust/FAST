clc
clear

%% Config
crop_size=101;
view_number=7;
z_number=101;
z_start=1;
z_finish=161;
centerPSF_size_xy=51;
center_PSF=zeros(centerPSF_size_xy,centerPSF_size_xy,z_number);
scale=2.09;

z_start_fit_coordi  = 1;
z_finish_fit_coordi = 161;   
z_idx = z_start_fit_coordi:z_finish_fit_coordi;
z_number_coord = numel(z_idx);

edge_trim = 10;   
fit_idx = (1+edge_trim):(z_number_coord-edge_trim);
fit_idx = fit_idx(fit_idx >= 1 & fit_idx <= z_number_coord);


%% PSF Processing
large_PSF=imread3d('.\PSF_example\PSF_[60 1.5 z-8-8 0.1um].tif');
MLcenters=double(imread('.\PSF_example\mask\mask_PSF_[60 1.5 z-5-5 0.1um].tif'));
FA_PSF=double(imread(".\PSF_example\FA-PSF.tif"));
[coordiy,coordix]=find(MLcenters==1);
coordi=zeros(length(coordiy),2);
for i=1:length(coordiy)
    coordi(i,1) =coordiy(i);
    coordi(i,2) =coordix(i);
end

[rank_co,ii]=sort(coordi(:,1));
temp=rank_co;
temp(:,2)=coordi(ii,2);
coordi=temp;

H_raw = cell(1,1,view_number,z_number);
H_scale = cell(1,1,view_number,z_number);
H_FAST = cell(1,1,view_number,z_number);
for idx=1:length(coordiy)

    %% LR PSF Crop
    PSF_crop=large_PSF(coordi(idx,1)-floor(crop_size/2):coordi(idx,1)+floor(crop_size/2),coordi(idx,2)-floor(crop_size/2):coordi(idx,2)+floor(crop_size/2),:);
    write3d(PSF_crop,sprintf('./PSF_example/crop_raw/psf_raw_view%d.tif',idx),32);

    fprintf('\n generate raw PSF view %d',idx);
    for i = 1:z_number
        H_raw{1,1,idx,i}=PSF_crop(:,:,i);  
        Ht_raw{1,1,idx,i} = imrotate(H_raw{1,1,idx,i}, 180);
    end

    %% PSF Shift to center
    for z=z_start:z_finish
       m=max(max(PSF_crop(:,:,z)));
       [y,x]=find(PSF_crop(:,:,z)==m);
       center_PSF(:,:,z+1-z_start)=PSF_crop(y-floor(centerPSF_size_xy/2):y+floor(centerPSF_size_xy/2),x-floor(centerPSF_size_xy/2):x+floor(centerPSF_size_xy/2),z);
    end
    write3d(center_PSF,sprintf('./PSF_example/crop_shift/psf_center_view%d.tif',idx),32);
    fprintf('\n generate shift PSF view %d',idx);
    
    % PSF Upsampling
    psf_upsample=imresize(PSF_crop,scale);
    write3d(psf_upsample,sprintf('./PSF_example/crop_upsample/psf_scale_view%d.tif',idx),32);

    for i = 1:z_number
        H_scale{1,1,idx,i}=psf_upsample(:,:,i);  
        Ht_scale{1,1,idx,i} = imrotate(H_scale{1,1,idx,i}, 180);
    end

    %% Find PSF center coordinate
    [H,W,Ztot] = size(psf_upsample);

    x_max = zeros(1, z_number_coord);
    y_max = zeros(1, z_number_coord);

    for k = 1:z_number_coord
        z = z_idx(k);
        slice = psf_upsample(:,:,z);

        [m, lin_idx] = max(slice, [], 'all', 'linear'); 
        [yy, xx] = ind2sub([H, W], lin_idx);

        x_max(k) = xx;
        y_max(k) = yy;
    end

    z_for_fit = z_idx(fit_idx);

    px = polyfit(z_for_fit, x_max(fit_idx), 1);   
    py = polyfit(z_for_fit, y_max(fit_idx), 1); 

    x_lin = polyval(px, z_idx);   
    y_lin = polyval(py, z_idx);   

    x_lin = round(x_lin);
    y_lin = round(y_lin);

    x_lin = min(max(x_lin, 1), W);
    y_lin = min(max(y_lin, 1), H);


    PSF_coord = zeros(H, W, z_number_coord);

    for k = 1:z_number_coord
        z_out = k;                        
        xx = x_lin(k);
        yy = y_lin(k);
        PSF_coord(yy, xx, z_out) = 1;        
    end

    %% FAST PSF Generate
    FAST_PSF=zeros(size(PSF_coord,1),size(PSF_coord,2),size(PSF_coord,3));
    for z=1:size(FAST_PSF,3) 
        FAST_PSF(:,:,z)=conv2(PSF_coord(:,:,z),FA_PSF,'same');
    end
    write3d(FAST_PSF,sprintf('./PSF_example/crop_FAST/PSF_FAST_view%d.tif',idx),32);
    fprintf('\n generate FAST PSF view %d',idx);
    for i = 1:z_number
        H_FAST{1,1,idx,i}=FAST_PSF(:,:,i);  
        Ht_FAST{1,1,idx,i} = imrotate(H_FAST{1,1,idx,i}, 180);
    end
end


save('./PSF_example/crop_raw/H_raw_[60 1.5 -5-5 0.1].mat','H_raw','-v7.3');  
save('./PSF_example/crop_raw/Ht_raw_[60 1.5 -5-5 0.1].mat','Ht_raw','-v7.3');
save('./PSF_example/crop_upsample/H_scale_[60 1.5 -5-5 0.1].mat','H_scale','-v7.3');  
save('./PSF_example/crop_upsample/Ht_scale_60 1.5 -5-5 0.1].mat','Ht_scale','-v7.3');
save('./PSF_example/crop_FAST/H_fast_[60 1.5 -5-5 0.1].mat','H_FAST','-v7.3');  
save('./PSF_example/crop_FAST/Ht_fast_[60 1.5 -5-5 0.1].mat','Ht_FAST','-v7.3');








