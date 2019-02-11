/******************************************************************//**
 * \file mqm/main.d
 * \brief Main function for rake app::regression
 *
 * <i>Copyright (c) 2012</i> Danny Arends<br>
 * Last modified Feb, 2019<br>
 * First written Dec, 2011<br>
 * Written in the D Programming Language (http://www.digitalmars.com/d)
 **********************************************************************/
import std.math, std.conv, std.datetime, core.time, std.getopt;
import std.stdio;
import std.string;
import mqm.regression;
import mqm.support;
import mqm.io;
import mqm.qtl;
import mqm.vector;

public: __gshared string phenome = "data/hyper_pheno.txt";
public: __gshared string genome = "data/hyper_geno.txt";
public: __gshared string map = "data/hyper_map.txt";
public: __gshared string output = "data/hyper_out.txt";

void parseCommandLine(string[] args) {
    try {
      getopt(args,
             "v|verbose", &(stdoutverbose),
             "p|phenome", &(phenome),
             "g|genome", &(genome),
             "o|output", &(output),
             "m|map", &(map)
            );
    } catch (Exception e) {
      abort(format("Exception: '%s'", e.msg), -1);
    }
}

void main (string[] args) {
  args.parseCommandLine();
  info("Multiple QTL mapping");
  Phenome p = Phenome(loadFile(phenome));
  Genome g = Genome(loadFile(genome));
  Map m = Map(loadFile(map));

  info("Chromosomes: %s", m.chromosomes());
  info("Orderedmap: %s markers", m.markers.length);
  info("Markers in genotypes %s", g.keys.length);
  info("Phenotypes: %s", p.phenotypes);
  info("Blood pressure on %s individuals", p["bp"].individuals.length);

  string[] ind = p["bp"].individuals;

  double[] trait = p.createPheno("bp", ind);
  auto file = File(output, "wt"); // Open for reading
  file.writefln("chr\tpos\tlod\teffect(s)");
  foreach (marker; m.markers()) {
    double[][] designmatrix = g.createDesignmatrix(p, [marker], ind);
    double[] weight = newvector!double(p["bp"].individuals.length, 1.0f);
    int[] nullmodellayout = [1];  //The D[][1] is dropped from the model to test its predictive value 
    Model[2] models = modelregression(designmatrix, weight, trait, nullmodellayout);
    file.writefln("%s\t%s\t%s\t%.2f\t%s", marker, m.chromosome(marker), m.position(marker), models.lod(), models[MODEL].params[1 .. ($)]);
  }
}

