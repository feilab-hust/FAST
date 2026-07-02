from __future__ import print_function, unicode_literals, absolute_import, division
import numpy as np
from _utils_ import nor_,mkdir
from skimage.transform import resize
from tifffile import imread
from csbdeep.io import save_tiff_imagej_compatible
from csbdeep.models import CARE
import os
import re
os.environ['CUDA_VISIBLE_DEVICES']='0'
os.environ['TF_FORCE_GPU_ALLOW_GROWTH'] = 'true'

axes = 'YX'
[scale_index,ckpt_name] = [1,'model_example.npz']
model = CARE(config=None, name=ckpt_name, basedir='models')
file_folder_name=r'.\example_data\ST'
save_folder=os.path.join(file_folder_name,ckpt_name)
mkdir(save_folder)
file_list = os.listdir(file_folder_name)
tif_list,x = [],[]

for idx, f in enumerate(file_list):
    if re.search('.*.tif', f):
        file_name=os.path.join(file_folder_name,f)
        tif_list.append(file_name)
        img = imread(file_name)
        x.append(img)

for img,file_name in zip(x,tif_list):
    restored=[]
    img = resize(img, (img.shape[0], int(img.shape[1] * scale_index), int(img.shape[2] * scale_index)))
    for i in range(img.shape[0]):
     temp = model.predict(img[i], axes)
     restored.append(temp*1000)
    restored = np.array(restored)
    file_name=os.path.split(file_name)[-1]
    file_name=re.sub('.tif','',file_name)
    save_tiff_imagej_compatible(os.path.join(save_folder,'%s.tif' % (file_name)),restored.astype(np.float32), 'ZYX')
print(save_folder)