#!/usr/bin/env nextflow

process HOMER_ANNOTATE {
    container "ghcr.io/bf528/homer:latest"   
    label "process_low"
    publishDir params.outdir

    input:
    path(peaks)
    path(genome)
    path(gtf)
    
    output:
    path("peak_annotations.txt")

    script:
    """
    annotatePeaks.pl $peaks $genome -gtf $gtf > peak_annotations.txt
    """

}