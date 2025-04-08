#!/usr/bin/env nextflow

process BEDTOOLS_REMOVE {
    container "ghcr.io/bf528/bedtools:latest"
    label "process_medium"
    publishDir params.outdir

    input:
    path(peaks)
    path(blacklist)

    output:
    path "filtered_peaks.bed", emit: peaks

    script:
    """
    bedtools intersect -a $peaks -b $blacklist -v -f 0.1 > filtered_peaks.bed
    """
}