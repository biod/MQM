/******************************************************************//**
 * \file mqm/support.d
 * \brief Regression supporting functions
 *
 * <i>Copyright (c) 1991-2012</i>Ritsert C. Jansen, Danny Arends, Pjotr Prins, Karl W. Broman<br>
 * Last modified May, 2012<br>
 * First written 1991<br>
 * Written in the D Programming Language (http://www.digitalmars.com/d)
 **********************************************************************/
module mqm.support;

import std.range : put;
import std.math : log, exp, pow, abs, sqrt, acos;
import std.string : format;

import mqm.vector : newvector;
import mqm.matrix : newmatrix;
import mqm.LUdecomposition : LUdecompose, LUsolve;

immutable size_t NULL = 0;
immutable size_t MODEL = 1;

/* Stats Structure */
struct Stats {
  double variance = 0.0;
  double[] fit;
  double[] residual;

  void toString(scope void delegate(const(char)[]) sink) const {
    put(sink, format("[S]  variance: %f\n", variance));
    put(sink, format("[S]  fit: %s\n", fit));
    put(sink, format("[S]  residual: %s", residual));
  }
}

/* Model Structure */
struct Model {
  double logL = 0.0; // Raw loglikelihood of the model
  double[] Fy;
  double[] indL;
  double[] params;
  Stats stats;

  void toString(scope void delegate(const(char)[]) sink) const {
    put(sink, format("logL: %f\n", logL));
    put(sink, format("[M]  Fy: %s\n", Fy));
    put(sink, format("[M]  indL: %s\n", indL));
    put(sink, format("[M]  params: %s\n", params));
    put(sink, format("%s", stats));
  }
}

/* Log normal distribution */
@nogc pure double Lnormal (double residual, double variance) nothrow {
  return exp(-pow(residual / sqrt(variance), 2.0f) / 2.0f - log(sqrt(2.0 * acos(-1.0f) * variance)));
}

/* LOD score between a two models (M, H0) */
@nogc pure double lod(in Model model, in Model nullmodel) nothrow { 
  return(abs((2.0f * model.logL) - (2.0f * nullmodel.logL)) / 4.60517f);
}

/* LOD score between a two models (M, H0) */
@nogc pure double lod(in Model[2] models) nothrow { return lod(models[MODEL], models[NULL]); }

/* Calculate the loglikelihood based the deviation from the weighted residuals to the variance */
pure Model calcloglik(size_t nsamples, in double[] residual, in double[] w, real variance, bool verbose = true){
  Model f = Model(0.0f, newvector!double(nsamples, 0.0f), newvector!double(nsamples, 0.0f));

  for (size_t i = 0; i < nsamples; i++) {
    f.Fy[i] = Lnormal(residual[i], variance);
    f.indL[i] += w[i] * f.Fy[i];
    f.logL += log(f.indL[i]);
  }
  return f;
}

/* Calculate the statistics of the model (fit, residuals, variance) */
pure Stats calcstats(size_t nv, size_t ns, in double[][] xt, in double[] xtwy, in double[] y, in double[] w){
  Stats s = Stats(0.0, newvector!double(ns, 0.0), newvector!double(ns, 0.0));

  for (size_t i = 0; i < ns; i++) {
    s.fit[i]      = 0.0;
    s.residual[i] = 0.0;
    for (size_t j = 0; j < nv; j++) {
      s.fit[i]     += xt[j][i] * xtwy[j];
    }
    s.residual[i]   = y[i] - s.fit[i];
    s.variance     += w[i] * pow(s.residual[i], 2.0);
  }
  s.variance /= ns;
  return s;
}

/* Calculate the estimated beta parameters for the regression */
double[] calcparams(size_t nvariables, size_t nsamples, in double[][] xt, in double[] w, in double[] y){
  int d = 0;
  double xtwj;
  double[][] XtWX = newmatrix!double(nvariables, nvariables, 0.0);
  double[] XtWY = newvector!double(nvariables, 0.0);
  int[] indx = newvector!int(nvariables, 0);

  for(size_t i = 0; i < nsamples; i++){
    for(size_t j = 0; j < nvariables; j++){
      xtwj     = xt[j][i] * w[i];
      XtWY[j] += xtwj     * y[i];
      for(size_t jj=0; jj <= j; jj++){
        XtWX[j][jj] += xtwj * xt[jj][i];
      }
    }
  }

  LUdecompose(XtWX, nvariables, indx, &d);
  LUsolve(XtWX, nvariables, indx, XtWY);

  return XtWY;
}

