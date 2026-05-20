process ILLUMINA_EXTRACT_DATA {

  publishDir "${params.outdir}/${manifest.sample_id}/extracted_data/", pattern: "*.tsv"

  label 'process_high'

  input:
  tuple val(manifest), path(gtc_file)

  output:
  tuple val(manifest), path("${manifest.sample_id}.tsv"), emit: illumina_tsv

  script:
  """
  
    ${params.tools.python} ${params.scripts.illumina_extraction_script} --gtc $gtc_file --manifest ${params.references.manifest} --output $manifest.sample_id

  """


}
