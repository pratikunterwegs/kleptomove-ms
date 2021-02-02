# code for landscape gradients and moran i

#### importing libraries and paths
# check python path
import sys

# should yield python 3.7 file path
for p in sys.path:
    print(p)

import pandas as pd  # similar to dplyr! yay!
import os  # has list dir functions etc
import numpy as np  # some matrix functions
import re
from scipy import misc
import matplotlib.pyplot as plt
import imageio  # library to read images

# check the current working directory
os.getcwd()
current_wd = p  # os.path.dirname(os.path.abspath(__file__)) #os.getcwd()

# check again
print(current_wd)

# gather image output
output_folder = os.path.join(os.getcwd(), "data/results/images/")  # os.path.abspath("output")
# check for the right folder
if "images" not in output_folder:
    raise Exception('seems like the wrong output folder...')

#### list files and filter by name
# gather contents of the folder
img_files = list()
for root, directories, filenames in os.walk(output_folder):
    for filename in filenames:
        img_files.append(os.path.join(root, filename))

# filter filenames to match foodlandscape
img_files = list(filter(lambda x: "landscape" in x, img_files))


# function to get image generation and rep number
def get_image_generation (x):
    assert "str" in str(type(x)), "input doesn't seem to be a filepath"
    assert "landscape" in x, "input is not a landscape"
    name = ((x.split("landscape")[1]))
    generation = int(re.findall(r'(\d{5})', name)[0])
    return generation


# get the image identity to match to parameters later
img_gen = list(map(get_image_generation, img_files))
# make a pd df
img_gen = pd.DataFrame({
    'gen': img_gen,
    'path': img_files
})
# make gen integer
img_gen['gen'] = pd.to_numeric(img_gen['gen'])


# function to read images, get gradient, and count non zero
# takes a 2d array
def get_prop_plateau (x, dim, layer):
    assert "landscape" in x, "input is not a landscape"
    image = imageio.imread(x)[:,:,layer]
    assert image.ndim == 2, "get_prop_plateau: not a 2d array"
    gradient = np.gradient(image)
    mag = np.sqrt(gradient[0]**2 + gradient[1]**2)
    mag = mag[mag == 0]
    p_plateau = len(mag) / (dim**2)
    return p_plateau


# run over files
img_gen['p_clueless'] = img_gen['path'].apply(get_prop_plateau, dim=128, layer=3)


# supplement code
# test import by showing the n/2th landscape
# plt.imshow(imageio.imread(img_gen['path'][100])[:,:,3], cmap="inferno")
# plt.colorbar()

# gradient = np.gradient(imageio.imread(img_gen['path'][100])[:,:,3])
# mag = np.sqrt(gradient[0]**2 + gradient[1]**2)
# plt.imshow(mag)
# plt.colorbar()

# # test on kernels32
# land = imageio.imread("data/data_parameters/kernels32.png")[:,:,3]
# plt.imshow(land)
# gradient = np.gradient(land)
# ## plot gradient
# mag = np.sqrt(gradient[0]**2 + gradient[1]**2)
# plt.imshow(mag, cmap="plasma")
# plt.colorbar()


# read the images in using a function and access the second channel (green)
import pysal.lib
from pysal.explore.esda.moran import Moran

# get image size, assuming square
landsize = (512)  # this should be set manually

# function to read image and calculate Moran I
def get_moran_i (x, dim, layer):
    # create a spatial weights matrix
    w = pysal.lib.weights.lat2W(dim, dim)
    assert "str" in str(type(x)), "input doesn't seem to be a filepath"
    image = imageio.imread(x)
    image = image[:, :, layer]  # selects the second channel (1) which is green
    assert "array" in str(type(image)), "input doesn't seem to be an array"
    assert len(image.shape) == 2, "non 2-d array, input must be a 2d array"
    mi = Moran(image, w)
    del image
    return mi.I


# read in images and do Moran I
img_gen['moran_i'] = img_gen['path'].apply(get_moran_i, dim=128, layer=1)

# write to csv
img_gen.to_csv(path_or_buf="data/results/test_data_moran_i.csv")

# ends here