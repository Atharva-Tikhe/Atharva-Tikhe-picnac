process WAVE_CORRECTION {

    publishDir "${params.outdir}/wave_correction_cbs/" 
    publishDir "${params.outdir}/stats/", pattern: "*.WF"

    conda "/home/atharva/miniforge3/envs/dnacopy/"

    input:
    tuple val(manifest), path(bedfile)

    output:
    tuple val(manifest), path("*calls.tsv"), emit: cbs
    tuple val(manifest), path("*.png"), emit: cbs_images
    tuple val(manifest), path("output.bed"), emit: lrr_bed
    tuple val(manifest), path("*.WF"), emit: stats

    script:
    """
        which R > version.txt

        ${params.scripts.wave_correction} $bedfile

        ${params.scripts.genomic_wave_adj} -calwf output.bed --output pre-adj.WF

        if [[ \$(cut -f3 pre-adj.WF) < 0.04 || \$(cut -f3 pre-adj.WF) > -0.04 ]]; then
            echo "No Wave correction needed; skipping"
            Rscript ${params.scripts.segments} -i output.bed -s ${manifest.sample_id} -c F -t ${params.threshold}
        else
            echo "WF out of bounds; performing wave correction"
            ${params.scripts.genomic_wave_adj} --adjust --gcmodel ${params.references.illumina_gc_model} output.bed

            ${params.scripts.genomic_wave_adj} -calwf output.bed.adjusted --output post-adj.WF  
            Rscript ${params.scripts.segments} -i output.bed.adjusted -s ${manifest.sample_id} -c T -t ${params.threshold}
        fi

    """
}
