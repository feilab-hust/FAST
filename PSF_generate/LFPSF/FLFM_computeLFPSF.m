% oLaF - a flexible 3D reconstruction framework for light field microscopy
% Copyright (c)2017-2020 Anca Stefanoiu

function [H, Ht] = FLFM_computeLFPSF(psfSTACK, Camera, Resolution, tolLFpsf,ax2ca,mla2axicon,is_axicon)

%% Precompute the MLA transmittance function
ulensPattern = FLFM_ulensTransmittance(Camera, Resolution);
MLARRAY = FLFM_mlaTransmittance(Resolution, ulensPattern);

%% Compute forward light trasport (LFPSF)
H = cell(1, 1, length(Resolution.depths));
for c = 1:length(Resolution.depths)
    psfREF = psfSTACK(:,:,c);
          
            % MLA transmittance
            psfMLA = psfREF.*MLARRAY;  %size=[1075,1075]
            LFpsfSensor = prop2Sensor(psfMLA, Resolution.sensorRes, ax2ca, Camera.WaveLength, 0);
            % store the response 
            H{1,1,c} = sparse(abs(double(LFpsfSensor).^2));
        fprintf('\nDepth:%d mla2axicon:%.1f ax2ca:%.1f ',c,mla2axicon,ax2ca);
end

% clip small values to speed up further computations involving H
H = ignoreSmallVals(H, tolLFpsf);
%% Compute backward light transport 
% disp('Computing backward light propagation')

% backward patterns in this case are just rotated forward patterns
Ht = cell(1, 1, length(Resolution.depths));
for i = 1:length(Resolution.depths)
    Ht{1,1,i} = imrotate(H{1,1,i}, 180);
end

% make sure the application of the inverse psf (through convolution) preserves the object energy (See Richardson Lucy algorithm)
Ht = normalizeHt(Ht); 