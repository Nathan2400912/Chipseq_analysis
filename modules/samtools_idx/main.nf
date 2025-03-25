#!/usr/bin/env nextflow

process SAMTOOLS_IDX {
    label 'process_medium'
    container 'ghcr.io/bf528/samtools:latest'
    publishDir params.outdir, mode: 'copy'

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path(bam), path("*.bai"), emit: index

    shell:
    """
    samtools index --threads $task.cpus $bam
    """
}