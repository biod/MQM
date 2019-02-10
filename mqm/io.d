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

import std.algorithm;
import std.conv;
import std.stdio;
import std.string;
import std.array;
import std.math;

public: __gshared size_t stdoutverbose = 1;

void write(T)(const T fmt) {
    if(stdoutverbose > 0) stdout.write(fmt);
}

void info(A...)(const string fmt, auto ref A args) {
    if(stdoutverbose > 0) writefln("[INFO]  " ~ fmt, args);
}

void trace(A...)(const string fmt, auto ref A args) {
    if(stdoutverbose > 1) writefln("[TRACE] " ~ fmt, args);
}

void err(A...)(const string fmt, auto ref A args) {
    writefln("[ERROR] " ~ fmt, args);
}

void warn(A...)(const string fmt, auto ref A args) {
    writefln("[WARN]  " ~ fmt, args);
}

struct DataStore {
  string[string][string] data;
  alias data this;
}

alias DataStore Genome;
alias DataStore Phenome;
alias DataStore Map;

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

struct ChromosomeSet {
  size_t[] autosomes;
  string[] other;
}

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

struct Marker {
  string name;
  string chr;
  double pos;
}

Marker[] getMarkers(Map m, string chr = "all", bool sorted = true) { 
  auto markers = m["chr"].keys;
  Marker[] onchr;
  foreach (marker; markers) {
    //writefln("%s: %s:%s", marker, m.chromosome(marker), m.position(marker) );
    if (m.chromosome(marker) == chr || chr == "all") {
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

