#!/usr/bin/env nextflow

params.x = '/home/users/allstaff/shen.t/NfBioImageAnalysis/example_data/example_cells_1.tif'

process pyTask {
    conda '/home/users/allstaff/shen.t/.conda/envs/myenv'
    memory '8 GB'

    input:
    val x

    output:
    stdout

    script:
    """
#!/usr/bin/env python3
import numpy as np
import matplotlib.pyplot as plt
import scipy.ndimage as ndi
import sys
import csv
def printer(x):
    from skimage.io import imread
    img = imread(x)


    ## Preprocessing

    sigma = 3
    img_smooth = ndi.gaussian_filter(img, sigma)


    ## Adaptive Thresholding

    i = 31
    SE = (np.mgrid[:i,:i][0] - np.floor(i/2))**2 + (np.mgrid[:i,:i][1] - np.floor(i/2))**2 <= np.floor(i/2)**2

    from skimage.filters import rank 
    bg = rank.mean(img_smooth, footprint=SE)

    mem = img_smooth > bg


    ## Improving Masks with Binary Morphology

    mem_holefilled = ~ndi.binary_fill_holes(~mem) # Short form

    i = 15
    SE = (np.mgrid[:i,:i][0] - np.floor(i/2))**2 + (np.mgrid[:i,:i][1] - np.floor(i/2))**2 <= np.floor(i/2)**2

    pad_size = i+1
    mem_padded = np.pad(mem_holefilled, pad_size, mode='reflect')
    mem_final = ndi.binary_closing(mem_padded, structure=SE)
    mem_final = mem_final[pad_size:-pad_size, pad_size:-pad_size]


    ## Cell Segmentation by Seeding & Expansion

    ### Seeding by Distance Transform

    dist_trans = ndi.distance_transform_edt(~mem_final)
    dist_trans_smooth = ndi.gaussian_filter(dist_trans, sigma=5)

    from skimage.feature import peak_local_max
    seed_coords = peak_local_max(dist_trans_smooth, min_distance=10)
    seeds = np.zeros_like(dist_trans_smooth, dtype=bool)
    seeds[tuple(seed_coords.T)] = True

    seeds_labeled = ndi.label(seeds)[0]

    ### Expansion by Watershed

    from skimage.segmentation import watershed



    ws = watershed(img_smooth, seeds_labeled)


    ## Postprocessing: Removing Cells at the Image Border

    border_mask = np.zeros(ws.shape, dtype=bool)
    border_mask = ndi.binary_dilation(border_mask, border_value=1)

    clean_ws = np.copy(ws)

    for cell_ID in np.unique(ws):
        cell_mask = ws==cell_ID
        cell_border_overlap = np.logical_and(cell_mask, border_mask)
        total_overlap_pixels = np.sum(cell_border_overlap)
        if total_overlap_pixels > 0: 
            clean_ws[cell_mask] = 0

    for new_ID, cell_ID in enumerate(np.unique(clean_ws)[1:]): 
        clean_ws[clean_ws==cell_ID] = new_ID+1


    ## Identifying Cell Edges

    edges = np.zeros_like(clean_ws)

    for cell_ID in np.unique(clean_ws)[1:]:
        cell_mask = clean_ws==cell_ID
        eroded_cell_mask = ndi.binary_erosion(cell_mask, iterations=1)
        edge_mask = np.logical_xor(cell_mask, eroded_cell_mask)
        edges[edge_mask] = cell_ID


    ## Extracting Quantitative Measurements

    with open('/home/users/allstaff/shen.t/NfBioImageAnalysis/results/results.csv', 'w', newline='') as file:
        writer = csv.writer(file)
        # Write the header
        writer.writerow(['cell_id', 'int_mean', 'int_mem_mean', 'cell_area', 'cell_edge'])
        
        # Write the data rows
        for cell_id in np.unique(clean_ws)[1:]:
            cell_mask = clean_ws==cell_id
            edge_mask = edges==cell_id
            int_mean = np.mean(img[cell_mask])
            int_mem_mean = np.mean(img[edge_mask])
            cell_area = np.sum(cell_mask)
            cell_edge = np.sum(edge_mask)
            writer.writerow([cell_id, int_mean, int_mem_mean, cell_area, cell_edge])
  
if __name__ == "__main__":
        printer('${x}')
    """
}

workflow {
    input_file = file(params.x) // Create a channel with the input file
    pyTask(input_file)
}

