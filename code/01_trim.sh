#!/bin/bash
set -euo pipefail

mkdir -p results/fastqc_raw
mkdir -p results/trimmed
mkdir -p results/fastqc_trimmed

echo "Running FastQC on raw reads..."
fastqc data/fastqs/*.fastq.gz -o results/fastqc_raw

echo "Running trimming with fastp..."
for r1 in data/fastqs/*_R1_001.fastq.gz; do
    base=$(basename "$r1" _R1_001.fastq.gz)
    r2="data/fastqs/${base}_R2_001.fastq.gz"

    fastp \
        -i "$r1" \
        -I "$r2" \
        -o "results/trimmed/${base}_R1_trimmed.fastq.gz" \
        -O "results/trimmed/${base}_R2_trimmed.fastq.gz" \
        --detect_adapter_for_pe \
        --qualified_quality_phred 20 \
        --length_required 50 \
        --thread 4 \
        --html "results/trimmed/${base}_fastp.html" \
        --json "results/trimmed/${base}_fastp.json"
done

echo "Running FastQC on trimmed reads..."
fastqc results/trimmed/*.fastq.gz -o results/fastqc_trimmed

echo "DONE"
