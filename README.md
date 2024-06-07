[![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A523.04.3-brightgreen.svg)](https://www.nextflow.io/)

# `staramr`: nextflow pipeline

## Introduction

**staramr: nextflow pipeline** is the nextflow adaptation of the [staramr](https://github.com/phac-nml/staramr/)

> `staramr` (_AMR) scans bacterial genome contigs against the [ResFinder][resfinder-db], [PointFinder][pointfinder-db], and [PlasmidFinder][plasmidfinder-db] databases (used by the [ResFinder webservice][resfinder-web] and other webservices offered by the Center for Genomic Epidemiology) and compiles a summary report of detected antimicrobial resistance genes. The `star|_`in`staramr` indicates that it can handle all of the ResFinder, PointFinder, and PlasmidFinder databases.

## Usage

If you are new to Nextflow and nf-core, please refer to [this page](https://nf-co.re/docs/usage/installation) on how
to set-up Nextflow. Make sure to [test your setup](https://nf-co.re/docs/usage/introduction#how-to-run-a-pipeline)
with `-profile test` before running the workflow on actual data.

```bash
 nextflow run main.nf -profile test,docker --outdir ./results
```

### Input

The input to the pipeline is a standard sample sheet (passed as `--input samplesheet.csv`) that looks like:

| sample  | contigs          | species             |
| ------- | ---------------- | ------------------- |
| SampleA | genomeA.fastq.gz | Salmonella enterica |

The structure of this file is defined in [assets/schema_input.json](assets/schema_input.json). Validation of the sample sheet is performed by [nf-validation](https://nextflow-io.github.io/nf-validation/).

### Output

```bash
results/staramr/
└── SampleA_results
    ├── detailed_summary.tsv
    ├── mlst.tsv
    ├── plasmidfinder.tsv
    ├── resfinder.tsv
    ├── results.xlsx
    ├── settings.txt
    └── summary.tsv
```

See the [staramr documentation](https://github.com/phac-nml/staramr/blob/development/README.md) for more details and explanations.

## Citation

### staramr

> Bharat A, Petkau A, Avery BP, Chen JC, Folster JP, Carson CA, Kearney A, Nadon C, Mabon P, Thiessen J, Alexander DC, Allen V, El Bailey S, Bekal S, German GJ, Haldane D, Hoang L, Chui L, Minion J, Zahariadis G, Domselaar GV, Reid-Smith RJ, Mulvey MR. **Correlation between Phenotypic and In Silico Detection of Antimicrobial Resistance in Salmonella enterica in Canada Using Staramr**. Microorganisms. 2022; 10(2):292. https://doi.org/10.3390/microorganisms10020292

### Databases used by staramr

> **Zankari E, Hasman H, Cosentino S, Vestergaard M, Rasmussen S, Lund O, Aarestrup FM, Larsen MV**. 2012. Identification of acquired antimicrobial resistance genes. J. Antimicrob. Chemother. 67:2640–2644. doi: [10.1093/jac/dks261][resfinder-cite]

> **Zankari E, Allesøe R, Joensen KG, Cavaco LM, Lund O, Aarestrup F**. PointFinder: a novel web tool for WGS-based detection of antimicrobial resistance associated with chromosomal point mutations in bacterial pathogens. J Antimicrob Chemother. 2017; 72(10): 2764–8. doi: [10.1093/jac/dkx217][pointfinder-cite]

> **Carattoli A, Zankari E, Garcia-Fernandez A, Voldby Larsen M, Lund O, Villa L, Aarestrup FM, Hasman H**. PlasmidFinder and pMLST: in silico detection and typing of plasmids. Antimicrob. Agents Chemother. 2014. April 28th. doi: [10.1128/AAC.02412-14][plasmidfinder-cite]

> **Seemann T**, MLST Github https://github.com/tseemann/mlst

> **Jolley KA, Bray JE and Maiden MCJ**. Open-access bacterial population genomics: BIGSdb software, the PubMLST.org website and their applications [version 1; peer review: 2 approved]. Wellcome Open Res 2018, 3:124. doi: [10.12688/wellcomeopenres.14826.1][mlst-cite]

### nf-core

This pipeline uses code and infrastructure developed and maintained by the [nf-core](https://nf-co.re) community, reused here under the [MIT license](https://github.com/nf-core/tools/blob/master/LICENSE).

> The nf-core framework for community-curated bioinformatics pipelines.
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> Nat Biotechnol. 2020 Feb 13. doi: 10.1038/s41587-020-0439-x.
> In addition, references of tools and data used in this pipeline are as follows:

## Legal

Copyright 2024 Government of Canada

Licensed under the MIT License (the "License"); you may not use
this work except in compliance with the License. You may obtain a copy of the
License at:

https://opensource.org/license/mit/

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.
