#!/usr/bin/env nextflow

include {FASTQC} from './modules/fastqc'
include {TRIMMOMATIC} from './modules/trimmomatic'
include {BOWTIE2_BUILD} from './modules/bowtie2_build'
include {BOWTIE2_ALIGN} from './modules/bowtie2_align'
include {SAMTOOLS_IDX} from './modules/samtools_idx'
include {SAMTOOLS_SORT} from './modules/samtools_sort'
include {SAMTOOLS_FLAGSTAT} from './modules/samtools_flagstat'
include {MULTIQC} from './modules/multiqc'
include {BAMCOVERAGE} from './modules/bamcoverage'

workflow {

    Channel.fromPath(params.subset_samplesheet)
    | splitCsv(header: true)
    | map { row -> tuple(row.name, file(row.path))}
    | set { fa_ch }

    FASTQC(fa_ch)
    TRIMMOMATIC(fa_ch, params.adapter_fa)

    BOWTIE2_BUILD(params.genome)
    BOWTIE2_ALIGN(TRIMMOMATIC.out.trimmed, BOWTIE2_BUILD.out.index, BOWTIE2_BUILD.out.name)

    SAMTOOLS_SORT(BOWTIE2_ALIGN.out.bam)
    SAMTOOLS_IDX(SAMTOOLS_SORT.out.sorted)
    SAMTOOLS_FLAGSTAT(SAMTOOLS_IDX.out.index)

    BAMCOVERAGE(SAMTOOLS_IDX.out.index)

    multiqc_ch = FASTQC.out.zip 
    .mix(TRIMMOMATIC.out.log)
    .mix(SAMTOOLS_FLAGSTAT.out.flagstat)
    .map { it[1] }
    .collect()
    MULTIQC(multiqc_ch)

}