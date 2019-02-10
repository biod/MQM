/******************************************************************//**
 * \file src/plugins/regression/qtl.d
 * \brief Single marker QTL mapping in D 2.0
 *
 * <i>Copyright (c) 1991-2019</i>Ritsert C. Jansen, Danny Arends, Pjotr Prins, Karl W. Broman<br>
 * Last modified Feb, 2019<br>
 * First written 1991<br>
 * Written in the D Programming Language (http://www.digitalmars.com/d)
 **********************************************************************/
module mqm.qtl;

import std.conv, std.stdio, std.math, std.datetime;
import mqm.matrix, mqm.vector, mqm.io, mqm.support, mqm.regression;

double[][] createDesignmatrix(Genome g, Phenome p, string[] markers, string[] individuals, string[] covariates = []) {
  double[][] designmatrix;
  //writefln("Creating designmatrix: %s x %s", individuals.length, ncol);
  foreach (individual; individuals) {
    double[] row = [1.0];
    foreach (marker; markers) {
      if (g[marker][individual] == "1") {
        row ~= -1;
      } else {
        row ~= 1;
      }
    }
    designmatrix ~= row;
  }
  return designmatrix;
}

double[] createWeights(string[] individuals) {
  double[] weights;
  foreach (individual; individuals) {
    weights ~= 1.0f;
  }
  return(weights);
}

void printDM(double[][] designmatrix, double[] trait) {
  for (size_t i = 0; i < designmatrix.length; i++) {
    trace("[%s] = %s", trait[i], designmatrix[i]);
  }
}

double[] createPheno(Phenome p, string phenotype, string[] individuals) {
  double[] pheno;
  foreach(individual; individuals) {
    pheno ~= to!double(p[phenotype][individual]);
  }
  return(pheno);
}

