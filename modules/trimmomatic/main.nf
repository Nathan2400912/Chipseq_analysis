#!/usr/bin/env nextflow

process TRIMMOMATIC {
    container "ghcr.io/bf528/trimmomatic:latest"
    label "process_single"
    publishDir params.outdir

    input:
    tuple val(name), path(fastq)
    path(adapters)

    output:
    tuple val(name), path('*.trimmed.fastq.gz'), emit: trimmed
    tuple val(name), path('*log'), emit: log

    shell:
    """
    trimmomatic SE $fastq ${name}.trimmed.fastq.gz ILLUMINACLIP:$adapters:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 -trimlog ${name}.log
    """
}



