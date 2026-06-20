process IAAP {
  
  publishDir "${params.outdir}/genotype_files", pattern: '*.gtc'

  label 'process_high'

  input:
  val(manifest)

  output:
  tuple val(manifest), path("*.gtc"), emit: gtc
  //path("*.gtc") 

  script:
  """
    ${params.tools.iaap} gencall -f ${manifest.folder}  ${params.references.manifest} ${params.references.cluster} . -g 

  """

}
