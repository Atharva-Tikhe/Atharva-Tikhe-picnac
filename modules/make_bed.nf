process MAKE_BED {

    input:
       tuple val(manifest), path(geno_tsv)

    output:
        tuple val(manifest), path("${manifest.sample_id}.merged_XY.bed"), emit: bed
    
    script:
    """

        ~/opt/merge_XY.sh $geno_tsv ${manifest.sample_id}.merged_XY.tsv

        ${params.tools.python} ${params.scripts.make_bed} -i ${manifest.sample_id}.merged_XY.tsv
    """



}
