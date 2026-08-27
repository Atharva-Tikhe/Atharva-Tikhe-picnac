process PLOT_PANEL {

    publishDir "${params.outdir}/panel_plots/" , mode: 'copy'
    publishDir "${params.outdir}/report/", mode: 'copy', pattern: '*.png'

    conda "/home/atharva/miniforge3/envs/dnacopy/"

    input:
    tuple val(manifest), path(segments)
    tuple val(manifest2),path(lrr_bed)
    tuple val(manifest3),path(ascat_calls)

    output:
    tuple val(manifest), path("*.tsv"), emit: gene_scores
    tuple val(manifest), path("*.png"), emit: plots

    script:
    """
        Rscript ${params.scripts.gene_scores} -s $segments -p ${params.references.gene_panel} -t ${params.threshold}

        Rscript ${params.scripts.plot_panel} -l $lrr_bed -s ${manifest.sample_id}.hg38.calls.tsv -a ${manifest.sample_id}_gene_level_ascat_calls.tsv -g ${params.references.genes} -p ${params.references.panel_ranges}


    """
}
