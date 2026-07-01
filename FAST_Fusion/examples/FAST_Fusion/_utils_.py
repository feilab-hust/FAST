from skimage import io
import os
import numpy as np
import shutil
import re
def nor_(img):
    min=np.amin(img)
    max=1.2*np.amax(img)
    img=255*(img-min)/(max-min)
    return img.astype(np.uint8)

def read_directory(path,regx='.*.tif'):
    img_array=[]
    files=os.listdir(path)
    files=sorted(files)
    return_list = []
    for _, f in enumerate(files):
        if re.search(regx, f):
            return_list.append(f)
    for file_name in return_list:
        img=io.imread(os.path.join(path,file_name))
        img_array.append(img)
    img_array=np.array(img_array)
    return img_array

def hyperstack2stack(path,save_path):
    file_name = os.listdir(path)
    for files in file_name:
        img = io.imread(os.path.join(path, files))
        if img.shape[0] != 10:
            img = np.reshape(img, (10, img.shape[0] // 10, img.shape[1], img.shape[2]))
        for i in range(10):
            io.imsave(os.path.join(save_path, '%d_' + files) % i, img[i].astype(np.uint32))
            print('%d/9' % i)

def move_(path,save_path):
    file_name = os.listdir(path)
    for files in file_name:
      if os.path.isdir(os.path.join(path, files)):
        files_ = os.listdir(os.path.join(path, files))
        for name in files_:
            if name[-3:] == 'raw':
                shutil.move(os.path.join(path, files, name), save_path)



def mkdir(path):
    folder = os.path.exists(path)
    if not folder:
        os.makedirs(path)

def LFP_view(img,num):
    size=img.shape
    view_stack=np.reshape(img,(size[0]//num,num,size[1]//num,num))
    view_stack=np.transpose(view_stack,(1,3,0,2)).reshape(num*num,size[0]//num,size[1]//num)
    return view_stack

def view_LFP(img,num):
    img=np.squeeze(img)
    size=img.shape
    LFP=np.reshape(img,(num,num,size[1],size[2]))
    LFP=np.transpose(LFP,(2,0,3,1)).reshape(size[1]*num,size[2]*num)
    return LFP

def intensity_match(img1,img2):
    max=np.amax(img2)
    min=np.amin(img2)


def gasuss_noise(image, var, SBR):
    image = np.array(image/np.amax(image), dtype=float)
    noise = np.random.normal(0, var ** 0.5, image.shape)
    out = image + noise
    out = (out-np.amin(out))/(np.amax(out)-np.amin(out))
    out = 250*SBR*out + 250
    #out = 250*SBR*out
    return out

def gasuss_possion_noise(image, var, l=1, SBR=1):
    image = np.array(image/np.amax(image), dtype=float)
    noise = np.random.normal(0, var ** 0.5, image.shape)
    noise_type = np.random.poisson(lam=l,size=image.shape).astype(dtype='float32')
    noise_type = noise_type/(np.amax(noise_type)+1e-7)
    out = image + noise + noise_type
    out = (out-np.amin(out))/(np.amax(out)-np.amin(out))
    #out = 250*SBR*out + 250
    out = 250*SBR*out
    return out






