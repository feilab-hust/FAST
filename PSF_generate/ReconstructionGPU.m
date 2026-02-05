clc
clear
addpath ./util
addpath ./solvers
addpath ./LFPSF
addpath ./projectionOperators

%% loading H
% H=psf;
ds_z=0
GPU_enable=1;
H=load('./19/H_m6-6.mat');
H=H.H;
H=flip(H);
Ht=load('./19/Ht_m6-6.mat');
Ht=Ht.Ht;
Ht=flip(Ht);
H_size=size(full(H{:,:,1}));
img_path="G:\iso_FLFM\tubu_1\iso_stack_108.5nm\stackds\Hex_WF_3x3_projection_test\SAI\1_MMStack_Default.ome-5-10009.tif";
LensletImage=double(imread3d(img_path));
LensletImage=LensletImage;
volumeSize = [size(LensletImage,1), size(LensletImage,2), size(Ht,3)];
init = ones(volumeSize);

if ~GPU_enable
    forwardFUN = @(volume) FLFM_forwardProject(H, volume);
    backwardFUN = @(projection) FLFM_backwardProject(Ht, projection);
else 
    forwardFUN = @(volume) FLFM_forwardProjectGPU(H, volume);
    backwardFUN = @(projection) FLFM_backwardProjectGPU(Ht, projection);
    global zeroImageEx;
    global exsize;
    xsize = [volumeSize(1), volumeSize(2)];
    msize = [H_size(1), H_size(2)];
    mmid = floor(msize/2);
    exsize = xsize + mmid;  
    exsize = [ min( 2^ceil(log2(exsize(1))), 128*ceil(exsize(1)/128) ), min( 2^ceil(log2(exsize(2))), 128*ceil(exsize(2)/128) ) ];    
    zeroImageEx = gpuArray(zeros(exsize, 'single'));
    disp(['FFT size is ' num2str(exsize(1)) 'X' num2str(exsize(2))]); 
end

%%  Richardson Lucy deconvolution
iter =50; % number of iterations
recon = deconvRL(forwardFUN, backwardFUN, LensletImage, iter, init);




