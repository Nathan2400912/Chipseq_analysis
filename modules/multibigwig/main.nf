#!/usr/bin/env nextflow

process MULTIBIGWIG {
    container "ghcr.io/bf528/deeptools:latest"
    label "process_medium"
    publishDir params.outdir

    input:
    path(bigwig)

    output:
    path("*.npz"), emit: matrix

    shell:
    """
    multiBigwigSummary bins -b ${bigwig.join(' ')} -o samples.npz
    """

}