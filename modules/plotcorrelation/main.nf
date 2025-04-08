#!/usr/bin/env nextflow

process PLOTCORRELATION {
    container "ghcr.io/bf528/deeptools:latest"
    label "process_low"
    publishDir params.outdir

    input:
    path(matrix)

    output:
    path("*.png"), emit: heatmap

    shell:
    """
    plotCorrelation -in $matrix -c spearman -p heatmap -o correlation_heatmap.png
    """

}