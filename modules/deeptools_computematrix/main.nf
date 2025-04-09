#!/usr/bin/env nextflow

process COMPUTEMATRIX {
    container "ghcr.io/bf528/deeptools:latest"
    label "process_high"
    publishDir params.outdir

    input:
    tuple val(name), path(rep)
    path(bed)

    output:
    tuple val(name), path("*.gz"), emit: matrix

    shell:
    """
    computeMatrix scale-regions -S $rep -R $bed -b 2000 -a 2000 -o ${name}.gz
    """

}