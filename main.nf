#!/usr/bin/env nextflow

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Atharva-Tikhe/picnac
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/Atharva-Tikhe/picnac
----------------------------------------------------------------------------------------
*/


include { IAAP  } from './modules/iaap'
include { ILLUMINA_EXTRACT_DATA } from './modules/illumina_extract_data'

include { READ_SAMPLESHEET } from './subworkflows/read_samplesheet.nf'


workflow {
  
  main:
  
    manifest = READ_SAMPLESHEET('/home/atharva/dev/pipeline/Atharva-Tikhe-picnac/samplesheet.csv').result

    IAAP(manifest)

    ILLUMINA_EXTRACT_DATA(IAAP.output.gtc)

    ILLUMINA_EXTRACT_DATA.output.illumina_tsv.view()
  

}

