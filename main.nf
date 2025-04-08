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
include {MULTIBIGWIG} from './modules/multibigwig'
include {PLOTCORRELATION} from './modules/plotcorrelation'
include {MACS3} from './modules/macs3'
include {BEDTOOLS_INTERSECT} from './modules/bedtools_intersect'
include {BEDTOOLS_REMOVE} from './modules/bedtools_remove'
include {HOMER_ANNOTATE} from './modules/homer_annotate'

workflow {

    Channel.fromPath(params.full_samplesheet)
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

    MULTIBIGWIG(BAMCOVERAGE.out.bigwig.collect())
    PLOTCORRELATION(MULTIBIGWIG.out.matrix)

    bam = SAMTOOLS_IDX.out.index
    paired_samples = bam
    .map { label, file, bai ->
        def parts = label.split('_')
        def sample_type = parts[0] 
        def replicate = parts[1]   
        tuple(replicate, sample_type, file)
    }
    .groupTuple(by: 0)
    .map { replicate, sample_types, files ->
        def file_map = [:]
        sample_types.eachWithIndex { type, index ->
            file_map[type] = files[index]
        }
        tuple(replicate, file_map.INPUT, file_map.IP)
    }

    MACS3(paired_samples)

    paired_narrowpeaks = MACS3.out.peaks
    .collect()
    .map { files -> tuple(files[0], files[1]) }

    BEDTOOLS_INTERSECT(paired_narrowpeaks)
    BEDTOOLS_REMOVE(BEDTOOLS_INTERSECT.out.peaks, params.blacklist)
    HOMER_ANNOTATE(BEDTOOLS_REMOVE.out.peaks, params.genome, params.gtf)
    
}