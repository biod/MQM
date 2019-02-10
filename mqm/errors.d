module mqm.errors;

import core.stdc.stdlib : exit;
import std.stdio    : stderr, writeln, writefln;
import std.string   : format;

import mqm.io;

/* Abort because an expectation isn't satisfied (-2) */
void expected(in string s, in string o){
  abort(format("'%s' expected, but found: '%s'", s, o), -2);
}

/* Abort because an identifier is undefined (-3) */
void undefined(in string name){
  abort(format("Undefined identifier: %s", name), -3);
}

/* Abort because an identifier is duplicated (-4) */
void duplicate(in string name){
  abort(format("Duplicate identifier: %s", name), -4);
}

