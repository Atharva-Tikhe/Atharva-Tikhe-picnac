process ASCAT {

    publishDir "${params.outdir}/${manifest.sample_id}/ascat" 

    conda "/home/atharva/miniforge3/envs/ascat/"

    input:
    val(manifest)
    path(bedfile)

    output:
    tuple val(manifest), path("*.txt"), emit: values
    tuple val(manifest), path("*.png"), emit: plots


    script:
    """
        ${params.scripts.separate_bed} $bedfile $manifest.sample_id

        Rscript ${params.scripts.ascat} -i $bedfile -s $manifest.sample_id
    """

}

