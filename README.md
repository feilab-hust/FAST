
# FAST
This repository is developed based on the paper *Full-aperture single-shot tomography unifies high-speed and high-resolution 3D imaging*, which provides a computational framework which enables full-pupil 3D imaging of biological dynamics from in situ 2D FA-ST snapshot.


The repository contains FAST software enabling PSF generation, FAST-Fusion network training and FAST Deconvolution. 


# Contents
- [Requirements](#Requirements)
- [Usage](#Usage)
- [Citation](#Citation)
- [Contact](#Contact)
- [ToDo](#ToDo)


# Requirements
- System requirements
```
· Windows 10. Linux should be able to run the code but the code has been only tested on Windows 10 so far.
· Python 3.8.8 
· CUDA 11.1 and cuDNN 8.2.0
· Graphics: NVIDIA RTX 3090, or better
· Memeory: > 128 GB 
· Hard Drive: ~50GB free space (SSD recommended)
```
- Running environment requirements 
```
Matlab-based GUI requirments:
· Matlab 2021b (or later version)
· Parallel Computing Toolbox and Image Processing Toolbox

Deep-learning model requirments:
- python=3.8.8
- tensorflow-1.15.4+nv-cp38-cp38-win_amd64.whl
- easydict==1.9
- protobuf==3.20.3
- scipy==1.6.2
- scikit-image==0.18.1
- numpy==1.18.0
- matplotlib==3.4.1
- mat73==0.59
```


# Usage
### Structure & Workflow of FAST software
* Tools under this repository are used to **PSF generate** ,**fast-fusin network training**and **fast deconvolution for 3D reconstruction**. 


