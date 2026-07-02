from scipy import signal
from skimage import io
import os
import numpy as np
from _utils_ import mkdir,gasuss_noise,gasuss_possion_noise,nor_

PEAK=100000
path = r'.\PSF_example\crop_shift'
root = r'.\example_Trainingimgs'
img_path = os.path.join(root,'FA')
img_path_de = os.path.join(root,'FA')
save_path_HR = os.path.join(root,'FA_train')
save_path_LR = os.path.join(root,'SADA')
mkdir(save_path_HR)
mkdir(save_path_LR)
for name in os.listdir(img_path):
 img_de  = io.imread(os.path.join(img_path_de,name))
 img = io.imread(os.path.join(img_path,name))
 for file in os.listdir(path):
    PSF = io.imread(os.path.join(path,file))
    PSF = PSF[21:81]
    for i in range(PSF.shape[0]):
     PSF_temp = PSF[i]
     img_conv = signal.convolve(img,PSF_temp,'same')
     img_conv = img_conv/np.amax(img_conv)
     index1 = 1 /2500 * np.random.uniform(5, 20)
     index2 = PEAK
     SBR = 1
     img_conv = gasuss_noise(img_conv,index1,SBR=SBR)
     img_conv = np.clip(img_conv,0,np.amax(img_conv))
     io.imsave(os.path.join(save_path_HR, name[:-4]+'_'+file[:-4]+ '_%d.tif' % i), img_de.astype(np.float32))
     io.imsave(os.path.join(save_path_LR, name[:-4]+'_'+file[:-4]+ '_%d.tif' % i), img_conv.astype(np.float32))