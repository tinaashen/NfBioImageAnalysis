#!/usr/bin/env nextflow
process pyTask {
    output:
    stdout
    """
    python /home/users/allstaff/shen.t/NfBioImageAnalysis/printing.py
    """
}
workflow {
    pyTask | view
}
