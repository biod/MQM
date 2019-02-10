/******************************************************************//**
 * \file src/core/arrays/matrix.d
 * \brief Fasta file type definition
 *
 * <i>Copyright (c) 2012</i> Danny Arends<br>
 * Last modified May, 2012<br>
 * First written May, 2012<br>
 * Written in the D Programming Language (http://www.digitalmars.com/d)
 **********************************************************************/
module mqm.matrix;

import std.stdio, std.conv, std.math;
import mqm.vector;

/* Create a new matrix, holding T init as value */
pure T[][] newmatrix(T) (size_t nrow, size_t ncol, T init = T.init) {
  T[][] x;
  x.length=nrow;
  for(size_t i=0;i < nrow;i++){
    x[i] = newvector!T(ncol,init);
  }
  return x;
}

/* Transpose a matrix */
pure T[][] transpose(T)(in T[][] i) {
  if(i.length == 0) throw new Exception("Matrix needs to be at least of dim 1,1");
  T[][] m = newmatrix!T(i[0].length, i.length);
  for (size_t r = 0;r < i.length; r++) {
    for (size_t c = 0;c < i[0].length; c++) {
      m[c][r] = i[r][c];
    }
  }
  return m;
}

