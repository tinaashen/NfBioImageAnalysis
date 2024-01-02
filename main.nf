#!/usr/bin/env nextflow

params.inputPath = './example_data/example_cells_1.tif' // Default input file path

// Define the process
process ProcessImage {

    input:
    path img from params.inputPath

    output:
    path "./results/*"

    script:
    """
    python basic.py ${img}
    """
}


