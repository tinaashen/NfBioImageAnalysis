#!/usr/bin/env nextflow
process pyTask {
    input:
    stdin
 
    output:
    stdout
 
    """
    #!/usr/bin/env python3
    def main():
        print("hello")
    if __name__ = "__main__":
        main()
    
    """
}

workflow {
    pyTask | view
}

