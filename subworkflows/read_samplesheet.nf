workflow READ_SAMPLESHEET {
  
  take:
  input

  main:
    mychannel = channel.fromPath(input)
    sample_manifest = mychannel.splitCsv(header: true).map( {it -> map_data(it)})
  emit:
    sample_manifest

}
// id,sample_id,parent_folder,platform,array,batch

def map_data(row) {
    def manifest = [:]
    manifest.id = row.id
    manifest.sample_id = row.sample_id
    manifest.folder = row.parent_folder
    manifest.platform = row.platform
    manifest.array = row.array
    manifest.batch = row.batch

    return manifest
}

