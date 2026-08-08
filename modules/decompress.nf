// =============================================================================
// DECOMPRESS  (step 01, per sample)
// Decompresses .fastq.gz / .fastq.bz2 → .fastq; plain .fastq files are copied.
// Renames non-standard 1_1 / 1_2 suffixes to R1 / R2.
// =============================================================================
process DECOMPRESS {
    tag "${sample_id}"
    publishDir "${params.outdir}/01_decompressed", mode: 'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("*.fastq"), emit: reads

    script:
    """
    set -euo pipefail

    for f in ${reads.join(' ')}; do
        base=\$(basename "\$f")
        if [[ "\$f" == *.fastq.bz2 ]]; then
            bzip2 -cd "\$f" > "\${base%.bz2}"
        elif [[ "\$f" == *.fastq.gz ]]; then
            gzip -cd  "\$f" > "\${base%.gz}"
        elif [[ "\$f" == *.fastq ]]; then
            # Nextflow's output glob excludes any file whose NAME matches a
            # staged input, even if the file content differs (e.g. after
            # cp) — the exclusion is name-based, not identity-based. Give
            # the passthrough copy a distinct name so it is recognised as
            # a genuine output.
            cp "\$f" "\${base%.fastq}_dc.fastq"
        else
            echo "WARNING: \$f has unrecognised format — skipping" >&2
        fi
    done

    # Rename non-standard Illumina suffixes
    shopt -s nullglob
    for f in *1_1.fastq; do mv "\$f" "\${f//1_1.fastq/R1.fastq}"; done
    for f in *1_2.fastq; do mv "\$f" "\${f//1_2.fastq/R2.fastq}"; done
    """
}
