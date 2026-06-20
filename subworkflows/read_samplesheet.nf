workflow READ_SAMPLESHEET {
  
  take:
  input_csv

  main:
    input_csv.view()
    // id,sample_id,parent_folder,platform,array,batch,Platform,Build,Manifest_file,Cluster_file,N_cases,Import_data

    samples = input_csv.splitCsv(header: true).map {
        row -> 
        def m = [
            batch: row.batch?.trim(),
            id: row.id,
            sample_id: row.sample_id,
            folder: row.parent_folder,
            platform: row.platform,
            array: row.array,
            batch_meta: [
                    Platform: row.Platform,
                    Build: row.Build,
                    Manifest_file: row.Manifest_file,
                    Cluster_file: row.Cluster_file,
                    N_cases: row.N_cases,
                    Import_date: row.Import_data
                ]
            ]
        m
    }.map { it -> it.collectEntries { k,v -> [(k): v] }}

    // batch_metadata = channel
    //     .fromPath(params.batch_metadata)
    //     .splitCsv(header : true)
    //     .map { row -> 
    //         tuple(row.batch?.trim(), row)
    //     }


    // result = samples.join(batch_metadata)
    //

    // result = samples
    //         .map { sample ->
    //             def meta = batch_metadata.val[sample.batch]
    //
    //             def enriched = [:] + sample
    //             enriched.batch_meta = meta
    //
    //             enriched
    //         }


    // sample_manifest = channel.fromPath(input)
    //     .splitCsv(header: true)
    //     .map { row ->
    //         def m = map_data(row)
    //         tuple(m.batch?.trim(), m)
    //     }

    // group all samples per batch
    // grouped_samples = sample_manifest.groupTuple()
    //
    // batch_meta = channel.fromPath(params.batch_metadata)
    //     .splitCsv(header: true)
    //     .map { row -> tuple(row.batch?.trim(), row) }
    //     .collect()
    //     .map { rows -> rows.collectEntries { [(rows[0]): rows[1]] } }
    //
    // result = grouped_samples
    //     .map { batch, samples ->
    //         def meta = batch_meta.val[batch]
    //         samples.collect { s ->
    //             s + [batch_meta: meta]
    //         }
    //     }
    //     .flatten()

  emit:
   samples
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
