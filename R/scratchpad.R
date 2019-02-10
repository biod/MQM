library(iqtl)
x <- matrix(c(1, 1, 2, 2, 2, 2), 6, 1)
w <- rep(1, 6)
y <- c(4.0, 1.0, 3.0, 7.0, 5.0, 6.0)
o <- multipleregression(x, y, w, verbose=TRUE)


data(hyper)
hyper <- fill.geno(hyper)

x <- pull.geno(hyper)[,"D1Mit178"]
x <- matrix(x, length(x), 1)
y <- pull.pheno(hyper)[, "bp"]
o <- multipleregression(x, y)

r1 <- scanone(hyper)
r2 <- contrastqtlmapping.internal(hyper)
r2["D1Mit178", ]
plot(r1, r2, lwd=c(5,1), col=c("red", "green"))


crosstocontrastlist(hyper)

