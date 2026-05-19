process GC_CORRECTION {

    publishDir "${params.outdir}/${manifest.sample_id}/gc_corr" 

    conda "/home/atharva/miniforge3/envs/dnacopy/"

    input:
    tuple val(manifest), path(bedfile)

    output:
    tuple val(manifest), path("*.corrected.bed"), emit: corrected_bed

    script:
    """
        which R > version.txt

        echo "span 0.2" >> version.txt
        
        Rscript ${params.scripts.gc_corr} -i ${bedfile} -s ${manifest.sample_id}

    """
}
