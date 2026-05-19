process CBS {

    publishDir "${params.outdir}/${manifest.sample_id}/cbs" 

    conda "/home/atharva/miniforge3/envs/dnacopy/"

    input:
    tuple val(manifest), path(bedfile), path(WF)

    output:
    tuple val(manifest), path("*calls.tsv"), emit: cbs
    tuple val(manifest), path("*.png"), emit: cbs_images


    script:
    """
        which R > version.txt

        Rscript ${params.scripts.segments} -i ${bedfile} -s ${manifest.sample_id}
    """

}
