process CBS {

    publishDir "${params.outdir}/${manifest.sample_id}/cbs" 

    conda "/home/atharva/miniforge3/envs/dnacopy/"

    input:
    tuple val(manifest), path(bedfile)

    output:
    tuple val(manifest), path("*.tsv"), emit: cbs
    tuple val(manifest), path("*.png"), emit: cbs_images


    script:
    """
        which R > version.txt

        Rscript ${params.scripts.gc_corr} -i ${bedfile} -s ${manifest.sample_id}

        Rscript ${params.scripts.segments_gc_corr} -i ${manifest.sample_id}.corrected.bed -s ${manifest.sample_id}

        #Rscript ${params.scripts.segments} -i ${bedfile} -s ${manifest.sample_id}

        #Rscript ${params.scripts.overlaps} -s ${manifest.sample_id} -l ${params.references.locus_file}
         


    """

}
