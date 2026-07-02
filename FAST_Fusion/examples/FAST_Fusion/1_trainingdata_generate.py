from __future__ import print_function, unicode_literals, absolute_import, division
import numpy as np
import matplotlib.pyplot as plt
from csbdeep.utils import  plot_some
from csbdeep.data import RawData, create_patches
import os
print(os.getcwd())


raw_data = RawData.from_folder (
    basepath    =r'.\example_Trainingimgs',
    source_dirs = ['SADA'],
    target_dir  = 'FA_train',
    axes        = 'YX',
)


from csbdeep.data import no_background_patches, norm_percentiles, sample_percentiles

X, Y, XY_axes = create_patches (
    raw_data            = raw_data,
    patch_size          = (64,64),
    patch_filter        = no_background_patches(0),
    n_patches_per_image = 4,
    save_file           = 'training data file/traindata_example.npz',
)


assert X.shape == Y.shape
print("shape of X,Y =", X.shape)
print("axes  of X,Y =", XY_axes)

for i in range(2):
    plt.figure(figsize=(16,4))
    sl = slice(8*i, 8*(i+1)), 0
    plot_some(X[sl],Y[sl],title_list=[np.arange(sl[0].start,sl[0].stop)])
    plt.show()

