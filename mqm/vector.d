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

import std.conv : to;
import std.string: format;
import std.stdio : writeln;

import mqm.io : abort, expect;

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

unittest {
  writeln("Unit test: ", __FILE__);
  try {
    double[] a = newvector!double(5, 2.0f);
    expect(a[1] == 2.0f, "Expected a[1] to be 2.0f, was '%s'", a[1]);
    expect(a.sum == 10.0f, "Expected a.sum to be 10.0f, was '%s'", a.sum);

    double[] b = newvector!double(15, 5.0f);
    expect(b[1] == 5.0f, "Expected b[1] to be 5.0f, was '%s'", b[1]);
    expect(b.sum == 75.0f, "Expected b.sum to be 75.0f, was '%s'", b.sum);
    writeln("OK: ",__FILE__);  
  } catch (Throwable e) {
    abort(format(" - %s\nFAILED: %s", to!string(e), __FILE__), -1);
  }
}

