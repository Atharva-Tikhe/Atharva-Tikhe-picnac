workflow READ_SAMPLESHEET {
  
  take:
  input

  main:

    sample_manifest = channel.fromPath(input)
        .splitCsv(header: true)
        .map { row ->
            def m = map_data(row)
            tuple(m.batch?.trim(), m)
        }

    // group all samples per batch
    grouped_samples = sample_manifest.groupTuple()

    batch_meta = channel.fromPath(params.batch_metadata)
        .splitCsv(header: true)
        .map { row -> tuple(row.batch?.trim(), row) }
        .collect()
        .map { rows -> rows.collectEntries { [(rows[0]): rows[1]] } }

    result = grouped_samples
        .map { batch, samples ->
            def meta = batch_meta.val[batch]
            samples.collect { s ->
                s + [batch_meta: meta]
            }
        }
        .flatten()


        // mychannel = channel.fromPath(input)
        // sample_manifest = mychannel.splitCsv(header: true).map {
        //     row -> 
        //     def m = map_data(row)
        //     tuple(m.batch?.trim(), m)
        // }
        //
        // batch_meta_map =  channel.fromPath("${params.batch_metadata}").splitCsv(header: true).map {
        //         row -> tuple(row.batch?.trim(), row) }
        //
        // result = sample_manifest
        //     .combine(batch_meta_map)
        //     .map { sm, meta_map ->
        //         def (batch, manifest) = sm
        //         manifest + [batch_meta: meta_map[batch]]
        //     }
        //
        // result.view()
    // joined = sample_manifest.join(batch_meta)
    //
    // joined.view()
    //
    // result = joined.map { _batch, manifest, meta -> manifest + [batch_meta: meta] }

    // result.view() // [batch: 1, id:1, sample_id:205030250061_32215, folder:'/home/atharva/dev/batch 1/205030250061_32215/', platform:'Illumina', array: 'CytoSNP-850Kv1', batch_meta:[batch:1, Platform:Illumina CytoSNP 850K, Build:37, Manifest_file:CytoSNP-850Kv1-2_NS550_B3.bpm, Cluster_file:CytoSNP-850Kv1-2_NS550_B1_ClusterFile.egt, N_cases:95, Import_data:18-Sep-23]]

  emit:
   result
}

def map_data(row) {
    def manifest = [:]
    manifest.batch = row.batch
    manifest.id = row.id
    manifest.sample_id = row.sample_id
    manifest.folder = row.parent_folder
    manifest.platform = row.platform
    manifest.array = row.array

    return manifest
}
