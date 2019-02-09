/******************************************************************//**
 * \file mqm/main.d
 * \brief Main function for rake app::regression
 *
 * <i>Copyright (c) 2012</i> Danny Arends<br>
 * Last modified Mar, 2012<br>
 * First written Dec, 2011<br>
 * Written in the D Programming Language (http://www.digitalmars.com/d)
 **********************************************************************/
import std.stdio, std.math, std.datetime, core.time, std.getopt;
import mqm.regression;
import mqm.support;
import mqm.io;

void parseCommandLine(string[] args) {
    try {
      getopt(args,
             "v|verbose", &(stdoutverbose)
            );
    } catch (Exception e) {
      err("Exception: '%s'", e.msg);
    }
}

void main (string[] args) {
  args.parseCommandLine();
  info("Multiple QTL mapping\n");

  double[][] designmatrix = [[1.0f, 1.0f, 2.0f], [1.0f, 1.0f, 2.0f], [1.0f, 2.0f, 1.0f], [1.0f, 2.0f, 1.0f], [1.0f, 2.0f, 1.0f], [1.0f, 2.0f, 1.0f]];
  double[]   trait = [4.0f, 1.0f, 3.0f, 7.0f, 5.0f, 6.0f];
  double[]   weight = [1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f];
  int[]      nullmodellayout = [0, 1];  //The D[][1] is dropped from the model to test its predictive value 
  for (size_t i = 0; i < designmatrix.length; i++) {
    info("[%s] = %s", trait[i], designmatrix[i]);
  }
  Model[2] models = modelregression(designmatrix, weight, trait, nullmodellayout);
  info("weight = %s", weight);
  info("LOD = %s", models.lod());
}

