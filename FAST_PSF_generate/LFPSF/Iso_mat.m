clear all
psf_path="D:\code\python_code\FLFM\PSF\psf_108nm_view19_iso.tif";
H_img=double(imread3d(psf_path));
H = cell(1,1,121);
for i = 1:121
    H{1,1,i}=H_img(:,:,i);
    Ht{1,1,i} = imrotate(H{1,1,i}, 180);
end
save('./19/H_m6-6_iso.mat','H','-v7.3');
save('./19/Ht_m6-6_iso.mat','Ht','-v7.3');