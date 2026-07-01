clear all
[hr_file_name,hr_filepath] = uigetfile('*.tif','Select HR Volumes','MultiSelect','on');
H = cell(1,1,6,81);
for img_idx=1:length(hr_file_name)
    img_name=hr_file_name{img_idx};
    img_path=fullfile(hr_filepath,img_name);
    psf_view=double(imread3d(img_path));
    for i = 1:81
     H{1,1,img_idx,i}=psf_view(:,:,i);
     Ht{1,1,img_idx,i} = imrotate(H{1,1,img_idx,i}, 180);
    end
end
save('./view7_lens/H_iso.mat','H','-v7.3');
save('./view7_lens/Ht_iso.mat','Ht','-v7.3');