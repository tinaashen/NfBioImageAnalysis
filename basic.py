
import numpy as np
from skimage.transform import resize
import matplotlib.pyplot as plt 
import tifffile as tiff
import matplotlib.pyplot as plt
from skimage.io import imread
import sys

def properties():
    filepath = sys.argv[1]
    img = imread(filepath)
    print("Loaded array is of type:", type(img))
    print("Loaded array has shape:", img.shape)
    print("Loaded values are of type:", img.dtype)
    plt.figure(figsize=(7,7))
    plt.imshow(img, interpolation='none', cmap='gray')
    plt.show()
    plt.savefig('./results/image.tif')
    plt.close()
    

if __name__ == "__main__":
    properties()
