#!/usr/bin/env nextflow

process FINDMOTIFS {
    container "ghcr.io/bf528/homer:latest"   
    label "process_high"
    publishDir params.outdir

    input:
    path(peaks)
    path(genome)

    output:
    path("homer_motifs/*")

    script:
    """
    findMotifsGenome.pl $peaks $genome homer_motifs/ -size 200
    """
}