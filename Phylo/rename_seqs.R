library(Biostrings)
library(tidyverse)

sequences1 <- Biostrings::readAAStringSet(filepath = "PDGDJCHL_17863_COBALT_alignment.fa") %>%
  as.data.frame() %>%
  tibble::rownames_to_column(var = "seqid") %>%
  dplyr::rename(aa_aln = x)

sequences2 <- Biostrings::readAAStringSet(filepath = "PDGDJCHL_27476_COBALT_alignment.fa") %>%
  as.data.frame() %>%
  tibble::rownames_to_column(var = "seqid") %>%
  dplyr::rename(aa_aln = x) %>%
  filter(seqid == "Query_508817 PDGDJCHL_27476 RNA-directed RNA polymerase")


sequences1 <- sequences1 %>% bind_rows(., sequences2)

sequences2 <- sequences1 %>%
  filter(str_detect(seqid, "^Query")) %>%
  mutate( seqid = str_remove(seqid, " RNA-directed RNA polymerase")) %>%
  mutate(seqid = str_replace_all(seqid, " ", "|"),
         seqid = paste(seqid, "Daphnia_pulex_virus", sep = "|"))


sequences1 <- sequences1 %>%
  filter(str_detect(seqid, "^Query", negate = T)) %>%
  mutate(seqid = str_remove_all(seqid, "RNA-dependent RNA polymerase | putative | MAG:|, partial|\\]|\\[")) %>%
  mutate(seqid = str_remove_all(seqid, " ORF1RT| hypothetical protein 1 | hypothetical protein 3 | hypothetical protein 2 | RNA-dependent RNA polymerase ")) %>%
  mutate(seqid = str_remove_all(seqid, " hypothetical protein | polyprotein | RNA dependent | RNA polymerase|RNA dependent")) %>%
  mutate(seqid = str_remove_all(seqid, " readthrough protein |\\(p85\\) |p85 | P85 |\\(p99\\) ")) %>%
  mutate(seqid = str_remove_all(seqid, "RNA-dependent |RNA polymerase |\\.$")) %>%
  mutate(seqid = str_replace(seqid, "\\| ", "\\|")) %>%
  mutate(seqid = str_replace_all(seqid, " ", "_"))

final <- bind_rows(sequences2, sequences1)

seq <- AAStringSet(x = final$aa_aln)
names(seq) <- final$seqid

writeXStringSet(x = seq, filepath = "Daphnia_pulex_virus_COBALT_alignment.fasta")
