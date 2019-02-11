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

import std.algorithm : sort, uniq, map;
import std.array : array;
import std.conv : to, ConvException;

import mqm.io : Map, Genome, Phenome, trace;

/* ChromosomeSet, holds autosomes and other genetic material (X, Y, Z, W, MT, Chloroplast) */
struct ChromosomeSet {
  size_t[] autosomes;
  string[] other;
}

/* A genetic marker has a name, chromosome and position */
struct Marker {
  string name;
  string chr;
  double pos;
}

/* Get the sorted unique chromosomes provided by the map */
ChromosomeSet chromosomes(in Map m) {
  ChromosomeSet chrs;
  foreach (marker; m["chr"].keys) {
    try {
      chrs.autosomes ~=  to!(size_t)(m.chromosome(marker));
    } catch (ConvException e) {
      chrs.other ~=  to!(string)(m.chromosome(marker));
    }
  }
  chrs.autosomes = sort(chrs.autosomes).uniq().array;
  chrs.other = sort(chrs.other).uniq().array;
  return(chrs);
}

/* getMarkers returns all markers per chromosome or an unsorted list of all markers */
Marker[] getMarkers(in Map m, in string chr = "1", in bool sorted = true) { 
  auto markers = m["chr"].keys;
  Marker[] onchr;
  foreach (marker; markers) {
    //writefln("%s: %s:%s", marker, m.chromosome(marker), m.position(marker) );
    if (m.chromosome(marker) == chr) {
      onchr ~= Marker(marker, m.chromosome(marker), to!double(m.position(marker)));
    }
  }
  if(sorted) onchr = sort!("a.pos < b.pos")(onchr).array;
  return(onchr);
}

/* string[] of markernames in the correct marker order */
string[] markers(in Map m) {
  string[] result;
  auto chrs = m.chromosomes;
  foreach (autosome; chrs.autosomes) {
    auto markers = m.getMarkers(to!string(autosome));
    result ~= map!(a => a.name)(markers).array;
  }
  foreach (other; chrs.other) {
    auto markers = m.getMarkers(other);
    result ~= map!(a => a.name)(markers).array;
  }
  return(result);
}

/* Chromosome on which the marker is located */
string chromosome(in Map m, in string marker) { return(m["chr"][marker]); }
/* Position on the chromosome on which the marker is located */
string position(in Map m, in string marker) { return(m["pos"][marker]); }

/* All phenotype names */
string[] phenotypes(Phenome p) { return(p.keys); }
/* All individuals names */
string[] individuals(string[string] x) { return(x.keys); }

/* Create the QTL designmatrix */
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

/* Print the QTL designmatrix */
void printDesignmatrix(double[][] designmatrix, double[] trait) {
  for (size_t i = 0; i < designmatrix.length; i++) {
    trace("[%s] = %s", trait[i], designmatrix[i]);
  }
}

/* Create a phenotype vector using the order in individuals */
double[] createPheno(Phenome p, string phenotype, string[] individuals) {
  double[] pheno;
  foreach(individual; individuals) {
    pheno ~= to!double(p[phenotype][individual]);
  }
  return(pheno);
}

