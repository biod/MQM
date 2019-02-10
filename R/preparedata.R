#
# Prepare genotype, map and phenotype data 
#

library(qtl)
data(hyper)

geno <- pull.geno(fill.geno(hyper))
rownames(geno) <- paste0("Ind", 1:nrow(geno))
write.table(geno, "../data/hyper_geno.txt", sep = "\t", quote=FALSE)

pheno <- pull.pheno(hyper)
rownames(pheno) <- paste0("Ind", 1:nrow(pheno))
write.table(pheno, "../data/hyper_pheno.txt", sep = "\t", quote=FALSE)

qtl <- scanone(hyper)
qtl[,2:3] <- apply(qtl[,2:3], 2, round, 2)
write.table(qtl, "../data/hyper_map.txt", sep = "\t", quote=FALSE)

q("no")

