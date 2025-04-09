#!/usr/bin/env nextflow

process PLOTPROFILE {
    container "ghcr.io/bf528/deeptools:latest"
    label "process_low"
    publishDir params.outdir

    input:
    tuple val(name), path(matrix)

    output:
    path("*.png"), emit: read_counts

    shell:
    """
    plotProfile -m $matrix -o ${name}_counts.png
    """

}