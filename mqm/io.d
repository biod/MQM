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

import std.stdio;

public: __gshared size_t stdoutverbose = 1;

void write(T)(const T fmt) {
    if(stdoutverbose > 0) stdout.write(fmt);
}

void info(A...)(const string fmt, auto ref A args) {
    if(stdoutverbose > 0) writefln("[INFO]  " ~ fmt, args);
}

void err(A...)(const string fmt, auto ref A args) {
    writefln("[ERROR] " ~ fmt, args);
}

void warn(A...)(const string fmt, auto ref A args) {
    writefln("[WARN]  " ~ fmt, args);
}

