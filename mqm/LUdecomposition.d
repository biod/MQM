/******************************************************************//**
 * \file mqm/LUdecomposition.d
 * \brief LUdecomposition, LUsolve and LUinvert
 *
 * <i>Copyright (c) 1991-2012</i> Ritsert C. Jansen, Danny Arends, Pjotr Prins, Karl W. Broman<br>
 * Last modified May, 2012<br>
 * First written 1991<br>
 * Written in the D Programming Language (http://www.digitalmars.com/d)
 **********************************************************************/
module mqm.LUdecomposition;

import std.math : fabs;

import mqm.io : abort;
import mqm.vector : newvector;

/* LUdecompose of matrix m */
bool LUdecompose(double[][] m, size_t dim, int[] ndx, int *d) {
  int r, c, rowmax, i;
  double max, temp, sum;
  double[] swap  = newvector!double(dim, 0.0f);
  double[] scale = newvector!double(dim, 0.0f);
  *d = 1;
  for (r = 0; r < dim; r++) {
    for (max = 0.0, c = 0; c < dim; c++) {
      if((temp = fabs(m[r][c])) > max) {
        max = temp;
      }
    }
    if(max == 0.0f) abort("ERROR: Singular matrix");
    scale[r] = 1.0f / max;
  }
  for(c = 0; c < dim; c++) {
    for(r = 0; r < c; r++) {
      for(sum = m[r][c], i = 0; i < r; i++){
        sum -= m[r][i] * m[i][c];
      }
      m[r][c] = sum;
    }
    for(max = 0.0f, rowmax = c, r = c; r < dim; r++) {
      for(sum = m[r][c], i = 0; i < c; i++){
        sum-= m[r][i] * m[i][c];
      }
      m[r][c] = sum;
      if((temp = scale[r]*fabs(sum)) > max) {
        max = temp;
        rowmax = r;
      }
    }
    if(max == 0.0) abort("ERROR: Singular matrix");
    if(rowmax != c) {
      swap = m[rowmax];
      m[rowmax] = m[c];
      m[c] = swap;
      scale[rowmax] = scale[c];
      (*d) = -(*d);
    }
    ndx[c] = rowmax;
    temp=1.0f / m[c][c];
    for(r = (c+1); r < dim; r++) {
      m[r][c] *= temp;
    }
  }
  return true;
}

/* LUsolve of matrix lu */
@nogc void LUsolve(in double[][] lu, size_t dim, in int[] ndx, ref double[] b) nothrow {
  int r, c;
  double sum;
  for (r = 0; r < dim; r++) {
    sum = b[ndx[r]];
    b[ndx[r]] = b[r];
    for (c = 0; c < r; c++) {
      sum -= lu[r][c]*b[c];
    }
    b[r] = sum;
  }
  for (r = cast(int)(dim)-1; r>-1; r--) {
    sum = b[r];
    for (c = r + 1; c < dim; c++){
      sum -= lu[r][c] * b[c];
    }
    b[r] = sum / lu[r][r];
  }
}

