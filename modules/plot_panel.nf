process PLOT_PANEL {

    publishDir "${params.outdir}/${manifest.sample_id}/panel_plots/" 

    conda "/home/atharva/miniforge3/envs/dnacopy/"

    input:
    tuple val(manifest), path(segments)
    path(lrr_bed)

    output:
    tuple val(manifest), path("*.tsv"), emit: gene_scores
    tuple val(manifest), path("*.pdf"), emit: plots

    script:
    """
        Rscript ${params.scripts.gene_scores} -s $segments -p ${params.references.gene_panel}

        Rscript ${params.scripts.plot_panel} -l $lrr_bed -s $segments -p ${params.references.gene_panel}

    """
}
