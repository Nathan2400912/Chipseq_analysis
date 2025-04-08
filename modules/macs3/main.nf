#!/usr/bin/env nextflow

process MACS3 {
    container "ghcr.io/bf528/macs3:latest"
    label "process_high"
    publishDir params.outdir

    input:
    tuple val(rep), path(control), path(treatment)

    output:
    path("*.narrowPeak"), emit: peaks

    shell:
    """
    macs3 callpeak -t $treatment $control -f BAM -g hs -n ${rep} 
    """

}