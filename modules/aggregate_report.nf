process AGGREGATE_REPORT {

    publishDir "${params.outdir}/report"
    

    input:
    tuple val(manifest), path(gene_scores) // gene_scores
    tuple val(manifest2), path(plots) // plots
    tuple val(manifest3), path(calls) //  calls
    
    output:
    path("report.html"), optional: true
    path("results.tsv"), optional: true
    path("*.png"), optional: true


    script:
    """
        echo "$manifest"
        
        ${params.tools.python} ${params.scripts.agg_res} --ascat ${manifest.sample_id}_gene_level_ascat_calls.tsv --custom panel_gene_scores.tsv --output results.tsv

        ${params.tools.python} ${params.scripts.cna_classifier} --tsv-path results.tsv --sample ${manifest.sample_id} 

        echo "${manifest.batch}" >> sample_info.txt
        echo "${manifest.id}" >> sample_info.txt
        echo "${manifest.sample_id}" >> sample_info.txt
        echo "${manifest.folder}" >> sample_info.txt
        echo "${manifest.platform}" >> sample_info.txt
        echo "${manifest.array}" >> sample_info.txt
        
        ${params.tools.python} ${params.scripts.gen_report} --results results.tsv --sample_info sample_info.txt --plot_dir ./ --classifier classifier_result.txt  --output ./report.html --template ${params.scripts.report_template}

        # cp *.png ~/dev/pipeline/executions/test_h_sense_ascat/${manifest.sample_id}/report/
        
    """




}
