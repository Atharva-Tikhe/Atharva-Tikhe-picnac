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
// include { GC_CORRECTION } from './modules/gc_correction'
include { WAVE_CORRECTION } from './modules/wave_correction'
include { CBS } from './modules/cbs'
include { PLOT_PANEL } from './modules/plot_panel'
include { ASCAT } from './modules/ascat'
include { MAKE_PGV } from './modules/make_pgv.nf'
include { AGGREGATE_REPORT } from './modules/aggregate_report.nf'

include { READ_SAMPLESHEET } from './subworkflows/read_samplesheet.nf'

include { RUN_APT } from './modules/affy/run_apt.nf'
include { EXTRACT_CN } from './modules/affy/extract_cn.nf'

workflow {
  
  main:
  
    manifest_ch = READ_SAMPLESHEET(channel.fromPath(params.input))

    manifest = manifest_ch.samples

    def lines = file(params.input).readLines()
    def header = lines[0].split(',').collect { it.trim() }
    def firstRow = lines[1].split(',').collect { it.trim() }
    def rowMap = [header, firstRow].transpose().collectEntries { k, v -> [(k): v] }

    def platform = rowMap.platform

    println(platform)
    println(platform.trim() == 'Affymetrix')

    if ( platform == "Affymetrix" ) {
        RUN_APT(manifest)
        EXTRACT_CN(RUN_APT.out.segments)
    } else {

        IAAP(manifest)

        ILLUMINA_EXTRACT_DATA(IAAP.output.gtc)

        MAKE_BED(ILLUMINA_EXTRACT_DATA.output.illumina_tsv)

        LIFT_OVER(MAKE_BED.output.bed)

        WAVE_CORRECTION(LIFT_OVER.output.lifted_bed)

        ASCAT(LIFT_OVER.output.lifted_bed)

        PLOT_PANEL(WAVE_CORRECTION.output.cbs, WAVE_CORRECTION.output.lrr_bed, ASCAT.out.calls)
        
        // MAKE_PGV(WAVE_CORRECTION.out.lrr_bed, WAVE_CORRECTION.out.cbs, PLOT_PANEL.out.gene_scores)
        
        AGGREGATE_REPORT(PLOT_PANEL.out.gene_scores, PLOT_PANEL.out.plots, ASCAT.out.calls)
    }

    workflow.onComplete = {
        def statusText = workflow.success ? "SUCCESS" : "FAILED"
        def statusEmoji = workflow.success ? "✅" : "❌"
        def statusColor = workflow.success ? "Good" : "Attention" // Good = Green, Attention = Red

        // Define Adaptive Card structure
        def adaptiveCardPayload = [
            type: "message",
            attachments: [
                [
                    contentType: "application/vnd.microsoft.card.adaptive",
                    contentUrl : null,
                    content    : [
                        '$schema': "http://adaptivecards.io/schemas/adaptive-card.json",
                        type     : "AdaptiveCard",
                        version  : "1.4",
                        body     : [
                            [
                                type  : "TextBlock",
                                size  : "Medium",
                                weight: "Bolder",
                                text  : "${statusEmoji} Nextflow Pipeline Completed: ${statusText}"
                            ],
                            [
                                type: "FactSet",
                                facts: [
                                    [title: "Run Name:", value: "${workflow.runName}"],
                                    [title: "Script:", value: "${workflow.scriptName ?: 'N/A'}"],
                                    [title: "Duration:", value: "${workflow.duration}"],
                                    [title: "Completed At:", value: "${workflow.complete}"]
                                ]
                            ],
                            [
                                type: "TextBlock",
                                text: "**Command:** `${workflow.commandLine}`",
                                wrap: true
                            ]
                        ]
                    ]
                ]
            ]
        ]

        // Convert Map to JSON String
        def jsonPayload = groovy.json.JsonOutput.toJson(adaptiveCardPayload)

        // Send HTTP POST request
        try {
            def teamsWebhookUrl = "https://default9c5012c9b61644c2a91766814fbe3e.87.environment.api.powerplatform.com:443/powerautomate/automations/direct/cu/19/workflows/21195a9a9cc14faabe68e5ea67b9661b/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=4KQhtBV8kzzQaMCtuO-GDpJ5eAmZQ0RO2LrbnLzSWdE"

            URL endpoint = new URL(teamsWebhookUrl)
            HttpURLConnection connection =  endpoint.openConnection()
            connection.setRequestMethod("POST")
            connection.setRequestProperty("Content-Type", "application/json")
            connection.setDoOutput(true)
            
            def os = connection.getOutputStream()
            os.write(jsonPayload.getBytes("UTF-8"))
            os.close()
            
            int responseCode = connection.getResponseCode()
            if (responseCode == 200 || responseCode == 202) {
                println "Teams Adaptive Card sent successfully."
            } else {
                println "Failed to send Teams Adaptive Card. Status code: ${responseCode}"
            }
        } catch (Exception e) {
            println "Error sending Adaptive Card to Teams: ${e.message}"
        }        

    }
    
}

