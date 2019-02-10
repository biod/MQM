/******************************************************************//**
 * \file mqm/nrc.d
 * \brief Old NRC file, now holding inverseF
 *
 * <i>Copyright (c) 2012</i> Danny Arends<br>
 * Last modified May, 2012<br>
 * First written Jan, 2012<br>
 * Written in the D Programming Language (http://www.digitalmars.com/d)
 **********************************************************************/
module mqm.nrc;

import std.stdio, std.math, std.mathspecial;
import mqm.io;

double inverseF(int df1, int df2, double alfa, size_t maxiter = 1000) {
  double prob = 0.0, minF = 0.0, maxF = 100.0, halfway = 50.0, absdiff = 1.0;
  int niter = 0;
  while ((absdiff > 0.001) && (niter < maxiter)) {
    niter++;
    halfway = (maxF + minF) / 2.0;
    prob = betaIncomplete(df2 / 2.0, df1 / 2.0, df2 / (df2 + df1*halfway));
    if (prob < alfa) {
     maxF = halfway;
    } else {
      minF = halfway;
    }
    absdiff = fabs(prob-alfa);
  }
  trace("inverseF: niter = %s, prob = %s, alfa = %s" , niter, prob, alfa);
  return halfway;
}
