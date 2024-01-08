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
    from PIL import Image
    def printer(x):
        with open('/home/users/allstaff/shen.t/NfBioImageAnalysis/results/output_1.txt', 'w') as f:
            print("hello bud", file=f)
            image = Image.open(x)
            img = np.array(image)
            print(f"File Name: {x}", file=f)
            print(f"Array Type: {img.dtype}", file=f)
            print(f"Array Size: {img.size}", file=f)
            print(f"Array Shape: {img.shape}", file=f)
    if __name__ == "__main__":
        printer('${x}')
    """
}
workflow {
    input_file = file(params.x) // Create a channel with the input file
    pyTask(input_file)
}
