# MedBioinfo 2022 Applied Bioinformatics
## Slurm jobs and Snakemake workflows for virus abundant analysis

### Data source

Data is from Daniel Castañeda-Mogollón et al. Dec 2021 https://www.sciencedirect.com/science/article/pii/S1386653221002924

Samples (either Nasopharyngeal or Throat swabs) from 125 patients, either COVID+ or COVID- by RT-PCR, were subjected to Illumina sequencing (one RNA and one DNA sequencing run for each patient).


### Structure of the repository

 - ```docs``` contains documentation (eg papers, manuals etc.)
 - ```slurm_jobs``` contain SLURM bash scripts used in the analysis
 - ```snakemake``` contain snakemake workflow of slurm jobs
 - ```standalone_scripts``` contain test scripts before creating ```slurm_jobs``` and ```snakemake```. It's of no practical use.

### References
 - MedBioinfo: https://www.medbioinfo.se/
 - publication in Journal of Clinical Virology, Volume 145, December 2021: https://www.sciencedirect.com/science/article/pii/S1386653221002924
 - snakemake: Mölder, F., Jablonski, K.P., Letcher, B., Hall, M.B., Tomkins-Tinch, C.H., Sochat, V., Forster, J., Lee, S., Twardziok, S.O., Kanitz, A., Wilm, A., Holtgrewe, M., Rahmann, S., Nahnsen, S., Köster, J., 2021. Sustainable data analysis with Snakemake. F1000Res 10, 33.
