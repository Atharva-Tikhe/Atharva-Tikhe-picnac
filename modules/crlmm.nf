process CRLMM {

    conda 'CRLMM' // crlmm is installed in CRLMM (replicate env on cluster)


    input:
    val(manifest)

    output:
    tuple val(manifest), path("output.tsv"), emit: crlmm_tsv


    script:
    """
        #TODO: Rscript
        #TODO: Run Rscript with cmdline options
        #TODO: Normalize outputs
    """

}
