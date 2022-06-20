
######## snakemake preamble start (automatically inserted, do not edit) ########
library(methods)
Snakemake <- setClass(
    "Snakemake",
    slots = c(
        input = "list",
        output = "list",
        params = "list",
        wildcards = "list",
        threads = "numeric",
        log = "list",
        resources = "list",
        config = "list",
        rule = "character",
        bench_iteration = "numeric",
        scriptdir = "character",
        source = "function"
    )
)
snakemake <- Snakemake(
    input = list('/shared/projects/form_2022_19/pascal/central_database/sample_collab.db', "db" = '/shared/projects/form_2022_19/pascal/central_database/sample_collab.db'),
    output = list('output/heatmap/sample_virus_heatmap.html', "pdf" = 'output/heatmap/sample_virus_heatmap.html'),
    params = list('output/heatmap', "outdir" = 'output/heatmap'),
    wildcards = list(),
    threads = 1,
    log = list(),
    resources = list('mem_mb', 'disk_mb', 'tmpdir', "mem_mb" = 1000, "disk_mb" = 1000, "tmpdir" = '/tmp'),
    config = list(),
    rule = 'sample_virus_heatmap',
    bench_iteration = as.numeric(NA),
    scriptdir = '/shared/ifbstor1/projects/form_2022_19/hong/sars2copath/snakemake/scripts',
    source = function(...){
        wd <- getwd()
        setwd(snakemake@scriptdir)
        source(...)
        setwd(wd)
    }
)


######## snakemake preamble end #########
library(heatmaply)
library(tidyverse)
library(DBI)

dir.create(snakemake@params[["outdir"]], showWarnings = FALSE)

mydb <- dbConnect(RSQLite::SQLite(), snakemake@input[["db"]])
abun_long <- as_tibble(dbGetQuery(mydb, "select * from bracken_abundances_long abu left join sample_annot spl using(run_accession);"))
min_abun  <- abun_long %>% filter(fraction_total_reads > 0) %>% summarize(min=min(fraction_total_reads,na.rm = TRUE)) %>% as.numeric
abun_long_log <- abun_long %>% mutate(log_fraction=log2(fraction_total_reads+min_abun/2))
abun_wide <- abun_long_log %>%  pivot_wider(id_cols = taxon_name, names_from = host_subject_id, values_from = log_fraction) %>% slice_head(n=1500) %>% arrange(taxon_name) %>% replace(is.na(.), 0)
 
samples <- dbGetQuery(mydb, 'SELECT * FROM sample_annot order by patient_code;') 
metadata <- samples %>% select(host_subject_id,nuc,host_disease_status,host_body_site) %>% arrange(host_subject_id)

metadata <- samples %>% filter(host_subject_id %in% names(abun_wide)[-1]) %>% select(host_subject_id,nuc,host_disease_status,host_body_site) %>% arrange(host_subject_id)

tmp <- heatmaply(select(abun_wide, -taxon_name),
          xlab='Sample',ylab='Taxa',margins=c(5,15,30,10),
          col_side_colors = metadata[-1],showticklabels=FALSE,
          main = "Oral microbiome diversity in COVID+/- patients",
          key.title='Abundance',
          plot_method='plotly',
          file = snakemake@output[["html"]]
)
rm(tmp)
## forgot the way to generate static pdf without installing orca