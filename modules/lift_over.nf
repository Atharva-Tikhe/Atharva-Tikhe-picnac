process LIFT_OVER {

    
  publishDir "${params.outdir}/${manifest.sample_id}/liftover", pattern: '*.bed'

    input:
       tuple val(manifest), path(geno_tsv)

    output:
        tuple val(manifest), path("${manifest.sample_id}.hg38.bed"), emit: lifted_bed

    script:

        def do_liftover = manifest.batch_meta.Build == "37"
        def liftover_cmd = do_liftover ? """
        ${params.tools.liftover} "${manifest.sample_id}.bed" "${params.references.chain_file}" "${manifest.sample_id}.hg38.bed"  "${manifest.sample_id}.hg38.unmapped.bed" -bedPlus=3 -tab > "liftover_${manifest.sample_id}.log"  2>&1 
    """ : "${do_liftover}"

    """
        ${liftover_cmd}
    """
    
}
