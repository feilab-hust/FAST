clc
clear
addpath ./util
addpath ./solvers
addpath ./LFPSF
addpath ./projectionOperators

%% loading H
GPU_enable=1;

H=load('..\FAST_PSF_generate\PSF_example\crop_upsample\H_scale_[60 1.5 -5-5 0.1].mat');
H=H.H_scale;
Ht=load('..\FAST_PSF_generate\PSF_example\crop_FAST\Ht_fast_[60 1.5 -5-5 0.1].mat');
Ht=Ht.Ht_FAST;

%% loading image
H_size=size(full(H{:,:,1}));
[hr_file_name,hr_filepath] = uigetfile('*.tif','Select HR Volumes','MultiSelect','on');
if ~iscell(hr_file_name)
    hr_file_name = {hr_file_name};
end

file_name=sprintf('\\Deconv');
save_Path=fullfile(hr_filepath,file_name);
if exist(save_Path,'dir')==7
    ;
else
    mkdir(save_Path);
end

%% RL Deconvolution wDAO
for img_idx=1:length(hr_file_name)
    img_name=hr_file_name{img_idx};
    img_path=fullfile(hr_filepath,img_name);
    LensletImage=double(imread3d(img_path));
    volumeSize = [size(LensletImage,1), size(LensletImage,2), size(Ht,4)];
    init = ones(volumeSize);
    forwardFUN = @(H,volume) FLFM_forwardProjectGPU(H, volume);
    backwardFUN = @(Ht,projection) FLFM_backwardProjectGPU(Ht, projection);
    global zeroImageEx;
    global exsize;
    xsize = [volumeSize(1), volumeSize(2)];
    msize = [H_size(1), H_size(2)];
    mmid = floor(msize/2);
    exsize = xsize + mmid;  
    exsize = [ min( 2^ceil(log2(exsize(1))), 128*ceil(exsize(1)/128) ), min( 2^ceil(log2(exsize(2))), 128*ceil(exsize(2)/128) ) ];    
    zeroImageEx = gpuArray(zeros(exsize, 'single'));
    disp(['FFT size is ' num2str(exsize(1)) 'X' num2str(exsize(2))]); 
    %%  Richardson Lucy deconvolution
    iter=10; % number of iterations
    Nb = 1;
    DAO = 1;
    recon = deconvRL_DAO(forwardFUN,backwardFUN,LensletImage,iter,init,H,Ht,img_name,save_Path,DAO,Nb);
end



