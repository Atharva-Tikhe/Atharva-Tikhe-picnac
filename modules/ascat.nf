process ASCAT {

    publishDir "${params.outdir}/${manifest.sample_id}/ascat" 

    conda "/home/atharva/miniforge3/envs/ascat/"

    input:
    tuple val(manifest), path(bedfile)
    // val(manifest)
    // path(bedfile)

    output:
    tuple val(manifest), path("*.txt"), emit: values
    tuple val(manifest), path("*.png"), emit: plots
    tuple val(manifest), path("*.tsv"), emit: calls


    script:
    """
        ${params.scripts.separate_bed} $bedfile $manifest.sample_id

        Rscript ${params.scripts.ascat} -i $bedfile -s $manifest.sample_id

    """

}

