process IAAP {
  
  /* 

    Uses Illumina's iaap-cli to generate a gtc file for each sample.

    Note: The iaap-cli requires a folder, this should be work folder which has only one sample each time.
    
  */

  publishDir "${params.outdir}/${manifest.sample_id}/genotype_files", pattern: '*.gtc'

  label 'process_high'

  input:
  val(manifest)
  // tuple val(sample_id), path(file_red), path(file_green)

  output:
  tuple val(manifest), path("*.gtc"), emit: gtc
  path("*.gtc") 

  script:
  """
    echo "sample: $manifest.sample_id"

    echo "$manifest"

    ${params.tools.iaap} gencall -f ${manifest.folder}  ${params.references.manifest} ${params.references.cluster} . -g 

  """

}
