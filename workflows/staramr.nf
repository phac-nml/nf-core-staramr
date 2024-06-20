/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    PRINT PARAMS SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { paramsSummaryLog; paramsSummaryMap; fromSamplesheet  } from 'plugin/nf-validation'

def logo = NfcoreTemplate.logo(workflow, params.monochrome_logs)
def citation = '\n' + WorkflowMain.citation(workflow) + '\n'
def summary_params = paramsSummaryMap(workflow)

// Print parameter summary log to screen
log.info logo + paramsSummaryLog(workflow) + citation

WorkflowStaramr.initialise(params, log)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    CONFIG FILES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//
include { INPUT_CHECK    } from '../subworkflows/local/input_check'
include { STARAMR_SEARCH } from '../modules/local/staramr/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//
include { CUSTOM_DUMPSOFTWAREVERSIONS } from '../modules/nf-core/custom/dumpsoftwareversions/main'
include { CSVTK_CONCAT } from '../modules/local/csvtk/concat/main.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow STARAMR {

    // Create a new channel of metadata from a sample sheet
    // NB: `input` corresponds to `params.input` and associated sample sheet schema
    ch_input = Channel.fromSamplesheet("input")

    //
    // MODULE: StarAMR
    //
    STARAMR_SEARCH (
        ch_input
    )

    //
    // MODULE: CSVTK_CONCAT
    // Create a single file for all tsv files

    // 1) summary.tsv file
    tsv_files_1 = STARAMR_SEARCH.out.summary_tsv

    ch_tsvs_1 = tsv_files_1.map{
        meta, summary_tsv -> summary_tsv
    }.collect().map{
        summary_tsv -> [ [id:"merged_summary"], summary_tsv]
    }

    // 2) detailed_summary.tsv file
    tsv_files_2 = STARAMR_SEARCH.out.detailed_summary_tsv

    ch_tsvs_2 = tsv_files_2.map{
        meta, detailed_summary_tsv -> detailed_summary_tsv
    }.collect().map{
        detailed_summary_tsv -> [ [id:"merged_detailed_summary"], detailed_summary_tsv]
    }

    // 3) resfinder.tsv file
    tsv_files_3 = STARAMR_SEARCH.out.resfinder_tsv

    ch_tsvs_3 = tsv_files_3.map{
        meta, resfinder_tsv -> resfinder_tsv
    }.collect().map{
        resfinder_tsv -> [ [id:"merged_resfinder"], resfinder_tsv]
    }

    // 4) plasmidfinder.tsv file
    tsv_files_4 = STARAMR_SEARCH.out.plasmidfinder_tsv

    ch_tsvs_4 = tsv_files_4.map{
        meta, plasmidfinder_tsv -> plasmidfinder_tsv
    }.collect().map{
        plasmidfinder_tsv -> [ [id:"merged_plasmidfinder"], plasmidfinder_tsv]
    }

    // 5) mlst.tsv file
    tsv_files_5 = STARAMR_SEARCH.out.mlst_tsv

    ch_tsvs_5 = tsv_files_5.map{
        meta, mlst_tsv -> mlst_tsv
    }.collect().map{
        mlst_tsv -> [ [id:"merged_mlst"], mlst_tsv]
    }

    // 6) pointfinder.tsv file
    tsv_files_6 = STARAMR_SEARCH.out.pointfinder_tsv

    ch_tsvs_6 = tsv_files_6.map{
        meta, pointfinder_tsv -> pointfinder_tsv
    }.collect().map{
        pointfinder_tsv -> [ [id:"merged_pointfinder"], pointfinder_tsv]
    }.mix(ch_tsvs_1,ch_tsvs_2,ch_tsvs_3,ch_tsvs_4,ch_tsvs_5)

    CSVTK_CONCAT(
        ch_tsvs_6,
        "tsv",
        "tsv"
    )

    }


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION EMAIL AND SUMMARY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {
    if (params.email || params.email_on_fail) {
        NfcoreTemplate.email(workflow, params, summary_params, projectDir, log)
    }
    NfcoreTemplate.dump_parameters(workflow, params)
    NfcoreTemplate.summary(workflow, params, log)
    if (params.hook_url) {
        NfcoreTemplate.IM_notification(workflow, params, summary_params, projectDir, log)
    }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
