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
    ${params.tools.iaap} gencall -f "${manifest.folder}"  /home/atharva/data/${manifest.batch_meta.Manifest_file} /home/atharva/data/${manifest.batch_meta.Cluster_file} . -g 

  """

}
