/******************************************************************//**
 * \file mqm/io.d
 * \brief io for multiple qtl mapping
 *
 * <i>Created by:</i>Danny Arends<br>
 * Last modified Feb, 2019<br>
 * First written Feb, 2019<br>
 * Written in the D Programming Language (http://www.digitalmars.com/d)
 **********************************************************************/
module mqm.io;

import core.stdc.stdlib : exit;

import std.stdio : File, stderr, writefln;
import std.string : chomp, format;
import std.array : split;

/* Thread shared verbose level set at startup */
public: __gshared size_t stdoutverbose = 1;

/* Verbose level control of stdout */
void write(T)(const T fmt) {
    if(stdoutverbose > 0) stdout.write(fmt);
}

/* Informational level of debug to stdout */
void info(A...)(const string fmt, auto ref A args) {
    if(stdoutverbose > 0) writefln("[INFO]  " ~ fmt, args);
}

/* Trace level debug to stdout */
void trace(A...)(const string fmt, auto ref A args) {
    if(stdoutverbose > 1) writefln("[TRACE] " ~ fmt, args);
}

/* Write an error string to stderr */
void error(A...)(const string fmt, auto ref A args) {
    stderr.writeln();
    stderr.writefln("[ERROR] " ~ fmt, args);
}

/* Abort with error code, default: -1 */
void abort(in string s, int exitcode = -1){
  error(s);
  exit(exitcode);
}

/* Write an warning string to stdout */
void warning(A...)(const string fmt, auto ref A args) {
    writefln("[WARN]  " ~ fmt, args);
}

/* Abort because an identifier is duplicated (-4) */
void expect(A...)(bool cond, string msg, auto ref A args) {
  if (!cond) abort(format(msg, args), -1);
}

/* DataStore holds Genome, Phenome, and Map */
struct DataStore {
  string[string][string] data; // Data is accessed by string rownames and colnames (tripple store)
  alias data this; // DataStore object is the data
}

/* Aliases to Genome, Phenome, and Map */
alias DataStore Genome;
alias DataStore Phenome;
alias DataStore Map;

/* Load a tab separated file into the DataStore */
string[string][string] loadFile(in string path) {
  string[string][string] content;
  auto file = File(path); // Open for reading
  string line;
  size_t i = 0;
  string[] header;
  while ((line = file.readln()) !is null) {
    string[] words = line.chomp().split("\t");
    if(i == 0) {
      header = words;
    } else {
      for (size_t x = 1; x < words.length; x++) {
        content[header[(x-1)]][words[0]] = words[x];
      }
    }
    i++;
  }
  return(content);
}

