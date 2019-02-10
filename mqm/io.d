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

import std.algorithm;
import std.conv;
import std.stdio;
import std.string;
import std.array;
import std.math;

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

/* DataStore holds Genotypes, Phenotypes and Genetic Map */
struct DataStore {
  string[string][string] data; // Data is accessed by string rownames and colnames (tripple store)
  alias data this; // DataStore object is the data
}

alias DataStore Genome;
alias DataStore Phenome;
alias DataStore Map;

/* Load a tab separated file into the DataStore */
string[string][string] loadFile(string path) {
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

/* ChromosomeSet, holds autosomes and other genetic material (X, Y, Z, W, MT, Chloroplast) */
struct ChromosomeSet {
  size_t[] autosomes;
  string[] other;
}

/* Get the sorted unique chromosomes provided by the map */
ChromosomeSet chromosomes(Map m) {
  ChromosomeSet chrs;
  foreach (marker; m["chr"].keys) {
    try {
      chrs.autosomes ~=  to!(size_t)(m.chromosome(marker));
    } catch (ConvException e) {
      chrs.other ~=  to!(string)(m.chromosome(marker));
    }
  }
  chrs.autosomes = sort(chrs.autosomes).uniq().array;
  chrs.other = sort(chrs.other).uniq().array;
  return(chrs);
}

/* A genetic marker has a name, chromosome and position */
struct Marker {
  string name;
  string chr;
  double pos;
}

/* getMarkers returns all markers per chromosome or an unsorted list of all markers */
Marker[] getMarkers(Map m, string chr = "1", bool sorted = true) { 
  auto markers = m["chr"].keys;
  Marker[] onchr;
  foreach (marker; markers) {
    //writefln("%s: %s:%s", marker, m.chromosome(marker), m.position(marker) );
    if (m.chromosome(marker) == chr) {
      onchr ~= Marker(marker, m.chromosome(marker), to!double(m.position(marker)));
    }
  }
  if(sorted) onchr = sort!("a.pos < b.pos")(onchr).array;
  return(onchr);
}

string[] markers(Map m) {
  string[] result;
  auto chrs = m.chromosomes;
  foreach (autosome; chrs.autosomes) {
    auto markers = m.getMarkers(to!string(autosome));
    result ~= map!(a => a.name)(markers).array;
  }
  foreach (other; chrs.other) {
    auto markers = m.getMarkers(other);
    result ~= map!(a => a.name)(markers).array;
  }
  return(result);
}

string chromosome(Map m, string marker) { return(m["chr"][marker]); }
string position(Map m, string marker) { return(m["pos"][marker]); }

string[] phenotypes(Phenome p) { return(p.keys); }
string[] individuals(string[string] x) { return(x.keys); }

