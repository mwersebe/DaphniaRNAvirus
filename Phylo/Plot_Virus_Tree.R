library(treeio)
library(tidytree)
library(ggtree)

#read in newick file from iqtree
tree <- ape::read.tree(file = "Daphnia_pulex_virus.treefile")
# midpoint root
tree <- phangorn::midpoint(tree, node.labels = 'support')
# write out file
write.tree(tree, file = "Daphnia_pulex_virus_midpoint.nwk")

# read in and plot
tree <- read.newick(file = "Daphnia_pulex_virus_midpoint.nwk", node.label = 'support')
metadata <- readr::read_csv("Reference_virus_metadata.csv", col_names = T)

tree <- tree %>%
  full_join(., metadata, by = "label")

ggtree(tree) + theme_tree2() +
  geom_tippoint(aes(color = source)) +
  geom_tiplab(aes(label = accession), size = 2, hjust = -0.02) +
  geom_nodelab(geom='text', aes(label= support, subset= as.numeric(support) > 51),
               size = 1.75, nudge_y = 0.75, hjust = 1.5, color = "dark red") +
  theme(legend.title = element_blank())
