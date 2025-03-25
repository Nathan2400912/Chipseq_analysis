#!/usr/bin/env nextflow

process SAMTOOLS_FLAGSTAT {
    container "ghcr.io/bf528/samtools:latest"
    label "process_single"
    publishDir params.outdir

    input:
    tuple val(name), path(bam), path(index)

    output:
    tuple val(name), path("${name}.flagstat.txt"), emit: flagstat

    shell:
    """
    samtools flagstat $bam > ${name}.flagstat.txt
    """
}