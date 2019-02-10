/******************************************************************//**
 * \file mqm/regression.d
 * \brief Basic weighted multiple regression by ML or ReML
 *
 * <i>Copyright (c) 1991-2012</i>Ritsert C. Jansen, Danny Arends, Pjotr Prins, Karl W. Broman<br>
 * Last modified Feb, 2019<br>
 * First written 1991<br>
 * Written in the D Programming Language (http://www.digitalmars.com/d)
 **********************************************************************/
module mqm.regression;
 
import std.math : fabs;
import std.string : format;

import mqm.vector : sum;
import mqm.matrix : transpose;
import mqm.io : abort, warning, trace;
import mqm.support : calcparams, calcstats, calcloglik, Model, Stats;

// Model regression (creates a design matrix)
Model[2] modelregression(in double[][] x, ref double[] w, double[] y, in int[] nullmodel = [1]){
  if(x.length != w.length) abort(format("No weights for individuals found", x.length, w.length));
  if(x.length != y.length) abort("No y variable for some individuals found"); 

  if(!x[0].sum() == y.length) warning("NOTE: No estimate of constant in model");

  Model model  = likelihoodbyem(x, w, y);
  trace("Model: %s", model);
  Model nmodel = regression(x, w, y, nullmodel);
  trace("NULL-Model: %s", nmodel);
  return([nmodel, model]);
}

// Expectation minimization computation of a model
Model likelihoodbyem(in double[][] x, ref double[] w, in double[] y, size_t maxemcycles = 1000){
  size_t nvariables = x[0].length;
  size_t nsamples   = x.length;
  size_t emcycle     = 0;
  double delta       = 1.0f;
  double logL        = 0.0f;
  double logLprev    = 0.0f;

  Model f;
  while ((emcycle < maxemcycles) && (delta > 1.0e-9)){
    f = regression(x, w, y);
    for (size_t s = 0; s < nsamples; s++) {
      if(w[s] != 0) w[s] = (w[s] + f.Fy[s])/w[s];
    }
    delta = fabs(f.logL - logLprev);
    logLprev=f.logL;
    emcycle++;
  }
  trace("EM took %d/%d cycles", emcycle, maxemcycles);
  return f;
}

// Matrix regression, uses the null model specification to drop columns from x
Model regression(in double[][] x, in double[] w, in double[] y, in int[] nullmodel = []){
  size_t nvariables = x[0].length;
  size_t nsamples   = x.length;
  double[][] Xt  = transpose!double(x);
  double[] XtWY  = calcparams(nvariables, nsamples, Xt, w, y);

  if (nullmodel.length != 0) {                     // The nullmodel has always 1 parameter
    for (size_t i = 1; i < nvariables; i++) {      // less Y = M + F1..Fn + Error, (The first parameter is the estimated mean)
      if(i > nullmodel.length) {
        warning("Null model too short, %d != %d", nullmodel.length, (nvariables-1));
        break;
      }
      if(nullmodel[(i-1)] == 1) XtWY[i] = 0.0;     // Set the estimated beta to 0
    }
  }

  Stats s  = calcstats(nvariables, nsamples, Xt, XtWY, y, w);
  Model f = calcloglik(nsamples, s.residual, w, s.variance);
  f.params = XtWY;
  f.stats  = s;
  return f;
}

