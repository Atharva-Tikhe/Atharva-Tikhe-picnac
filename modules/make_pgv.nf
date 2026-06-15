process MAKE_PGV {

    input:
        path(lrr_bed)
        tuple val(manifest), path(segments)
        tuple val(manifest2), path(gene_scores)

    script:
    """
    
        ${params.scripts.make_bedgraph} ${lrr_bed} ${manifest.sample_id}_lrr
        ${params.scripts.make_bedgraph} ${segments} ${manifest.sample_id}_seg

        ${params.tools.bedgraphToBw} ${manifest.sample_id}_lrr.dedup.sorted.bedGraph ${params.references.chrom_sizes} ${manifest.sample_id}_lrr.bw
        ${params.tools.bedgraphToBw} ${manifest.sample_id}_seg.dedup.sorted.bedGraph ${params.references.chrom_sizes} ${manifest.sample_id}_seg.bw

        ${params.tools.python} ${params.scripts.panel_ranges} ${gene_scores} ${manifest.sample_id}

        cp ${manifest.sample_id}_lrr.bw ~/pgv/pgv-backend/static/data/
        cp ${manifest.sample_id}_seg.bw ~/pgv/pgv-backend/static/data/


        bgzip ${manifest.sample_id}_gene_calls.bed
        cp ${manifest.sample_id}_gene_calls.bed.gz ~/pgv/pgv-backend/static/data/
        cp ${manifest.sample_id}_lrr.dedup.sorted.bedGraph ~/pgv/pgv-backend/static/data/
        cp ${manifest.sample_id}_seg.dedup.sorted.bedGraph ~/pgv/pgv-backend/static/data/


    """
}

