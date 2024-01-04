#!/usr/bin/env nextflow
process pyTask {
    conda '/home/users/allstaff/shen.t/.conda/envs/myenv'
    memory '8 GB'
    output:
    stdout
    """
#!~/.conda/envs/myenv/bin/python3
import numpy as np
import sys
from PIL import Image
def printer():
    print("hello bud")
    image = Image.open("/home/users/allstaff/shen.t/NfBioImageAnalysis/example_data/example_cells_1.tif")
    img = np.array(image)
    print(f"Array Type: {img.dtype}")
    print(f"Array Size: {img.size}")
    print(f"Array Shape: {img.shape}")
if __name__ == "__main__":
    printer()
    """
}
workflow {
    pyTask | view
}