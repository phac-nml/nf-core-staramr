process STARAMR_SEARCH {
    tag "$meta.id"
    label 'process_single'

    conda "bioconda::staramr=0.10.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/staramr:0.10.0--pyhdfd78af_0':
        'biocontainers/staramr:0.10.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(contigs)

    output:
    tuple val(meta), path("*_results/${meta.id}_results.xlsx")          , emit: results_xlsx
    tuple val(meta), path("*_results/${meta.id}_summary.tsv")           , emit: summary_tsv
    tuple val(meta), path("*_results/${meta.id}_detailed_summary.tsv")  , emit: detailed_summary_tsv
    tuple val(meta), path("*_results/${meta.id}_resfinder.tsv")         , emit: resfinder_tsv
    tuple val(meta), path("*_results/${meta.id}_plasmidfinder.tsv")     , emit: plasmidfinder_tsv
    tuple val(meta), path("*_results/${meta.id}_mlst.tsv")              , emit: mlst_tsv
    tuple val(meta), path("*_results/${meta.id}_settings.txt")          , emit: settings_txt
    tuple val(meta), path("*_results/${meta.id}_pointfinder.tsv")       , emit: pointfinder_tsv, optional: true
    path "versions.yml"                                                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def is_gzipped = contigs.getName().endsWith(".gz") ? true : false
    def genome_uncompressed_name = contigs.getName().replace(".gz", "")
    def genome_filename = "${meta.id}.fasta"
    """
    if [ "$is_gzipped" = "true" ]; then
        gzip -c -d $contigs > $genome_uncompressed_name
    fi

    #Change name of input genome to allow irida-next output of metadata
    mv $genome_uncompressed_name $genome_filename

    staramr \\
        search \\
        $args \\
        --nprocs $task.cpus \\
        -o ${prefix}_results \\
        $genome_filename

    # Add prefix ($meta.id) to the names of output files (allows for CSVTK module to concatenate files downstream)
    for f in ${prefix}_results/* ; do mv "\$f" \$(echo \$f | sed 's;/;/${prefix}_;'); done

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        staramr : \$(echo \$(staramr --version 2>&1) | sed 's/^.*staramr //' )
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir ${prefix}_results
    touch ${prefix}_results/results.xlsx
    touch ${prefix}_results/{${prefix}_summary,${prefix}_detailed_summary,${prefix}_resfinder,${prefix}_pointfinder,${prefix}_plasmidfinder,mlst}.tsv
    touch ${prefix}_results/settings.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        staramr : \$(echo \$(staramr --version 2>&1) | sed 's/^.*staramr //' )
    END_VERSIONS
    """
}
