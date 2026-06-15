process AGGREGATE_REPORT {

    publishDir "${params.outdir}/${manifest.sample_id}/report"
    

    input:
    tuple val(manifest), path(gene_scores) // gene_scores
    tuple val(manifest2), path(plots) // plots
    tuple val(manifest3), path(calls) //  calls
    
    output:
    tuple val(manifest), path("report.html"), optional: true
    tuple val(manifest), path("results.tsv"), optional: true
    tuple val(manifest3), path("*.png"), optional: true


    script:
    """
        echo "$manifest3"
        
        ${params.tools.python} ${params.scripts.agg_res} --ascat ${manifest3.sample_id}_gene_level_ascat_calls.tsv --custom panel_gene_scores.tsv --output results.tsv

        ${params.tools.python} ${params.scripts.cna_classifier} --tsv-path results.tsv --sample ${manifest3.sample_id} 

        echo "${manifest3.batch}" >> sample_info.txt
        echo "${manifest3.id}" >> sample_info.txt
        echo "${manifest3.sample_id}" >> sample_info.txt
        echo "${manifest3.folder}" >> sample_info.txt
        echo "${manifest3.platform}" >> sample_info.txt
        echo "${manifest3.array}" >> sample_info.txt
        
        ${params.tools.python} ${params.scripts.gen_report} --results results.tsv --sample_info sample_info.txt --plot_dir ./ --classifier classifier_result.txt  --output ./report.html --template ${params.scripts.report_template}

        cp *.png ~/dev/pipeline/executions/test_h_sense_ascat/${manifest3.sample_id}/report/
        
    """




}
