/******************************************************************//**
 * \file mqm/vector.d
 * \brief Array type definition
 *
 * <i>Copyright (c) 2012</i> Danny Arends<br>
 * Last modified Feb, 2019<br>
 * First written May, 2011<br>
 * Written in the D Programming Language (http://www.digitalmars.com/d)
 **********************************************************************/
module mqm.vector;

import std.conv;

/* Create a new vector, holding T init as value */
pure T[] newvector(T)(size_t length, T value = T.init){
  T[] x;
  for (size_t j = 0; j < length; j++) { x ~= value; }
  return x;
}

/* Sum of a vector */
@nogc T sum(T)(in T[] v) nothrow {
  T sum = to!T(0);
  foreach(e; v){ sum += e; }
  return sum;
}

