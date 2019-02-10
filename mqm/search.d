/******************************************************************//**
 * \file mqm/search.d
 * \brief Array search and ranges
 *
 * <i>Copyright (c) 2012</i> Danny Arends<br>
 * Last modified May, 2012<br>
 * First written May, 2011<br>
 * Written in the D Programming Language (http://www.digitalmars.com/d)
 **********************************************************************/
module mqm.search;

import std.conv;
import std.string;
import std.random;
import std.stdio;

import mqm.io;

unittest {
  writeln("Unit test: ",__FILE__);
  try {
    writeln("OK: ",__FILE__);  
  } catch (Throwable e) {
    error(" - %s\nFAILED: %s", to!string(e), __FILE__);  
  }
}

