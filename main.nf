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
include { MAKE_BED } from './modules/make_bed'
include { LIFT_OVER } from './modules/lift_over'
include { GC_CORRECTION } from './modules/gc_correction'
include { WAVE_CORRECTION } from './modules/wave_correction'
include { CBS } from './modules/cbs'
include { PLOT_PANEL } from './modules/plot_panel'
include { ASCAT } from './modules/ascat'

include { READ_SAMPLESHEET } from './subworkflows/read_samplesheet.nf'

workflow {
  
  main:
  
    manifest = READ_SAMPLESHEET('/home/atharva/dev/pipeline/Atharva-Tikhe-picnac/samplesheet.csv').result

    IAAP(manifest)

    ILLUMINA_EXTRACT_DATA(IAAP.output.gtc)

    MAKE_BED(ILLUMINA_EXTRACT_DATA.output.illumina_tsv)

    LIFT_OVER(MAKE_BED.output.bed)

    WAVE_CORRECTION(LIFT_OVER.output.lifted_bed)

    PLOT_PANEL(WAVE_CORRECTION.output.cbs, WAVE_CORRECTION.output.lrr_bed)

    // ASCAT(manifest, WAVE_CORRECTION.output.lrr_bed)
    ASCAT(LIFT_OVER.output.lifted_bed)

}
