#!/usr/bin/env nextflow

process BEDTOOLS_INTERSECT {
    container "ghcr.io/bf528/bedtools:latest"
    label "process_medium"
    publishDir params.outdir

    input:
    tuple path(peaks_rep1), path(peaks_rep2)

    output:
    path "reproducible_peaks.bed", emit: peaks

    script:
    """
    bedtools sort -i $peaks_rep1 > rep1_sorted.narrowPeak
    bedtools sort -i $peaks_rep2 > rep2_sorted.narrowPeak
    bedtools intersect -a rep1_sorted.narrowPeak -b rep2_sorted.narrowPeak -f 0.5 -r -wa | sort -k1,1 -k2,2n > reproducible_peaks.bed
    """
}