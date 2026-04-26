process MAKE_BED {

    input:
       tuple val(manifest), path(geno_tsv)

    output:
        tuple val(manifest), path("${manifest.sample_id}.bed"), emit: bed
    
    script:
    """
        ${params.tools.python} ${params.scripts.make_bed} -i $geno_tsv
    """



}
