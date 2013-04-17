# MATrax

A GUI-based DJ software, built in MATLAB.

## Goals

* Custom GUI
* MP3 Decoding and Encoding (reading and saving files)
* Track sampling (selection portions of a track)
* Cross-fading
* Independent volume control
* BPM matching
  * BPM detection
  * Time stretching + pitch matching
* Effects/Filters
  * Reverb
  * Delay/Echo
  * Flange
  * Custom filter
* Overall transformations
  * Upsampling
  * Downsampling
  * Changing bit-depth

## Compiling

### Prerequisites

Compilation requires a C/C++ compiler and `make`.

Ensure that a C/C++ compiler is configured in MATLAB. If it isn't, run `mbuild
-setup` within MATLAB to set the appropriate compiler.

In addition, make sure that the MATLAB binaries are in your `$PATH`.

### Building

Building can simply be done using `make all` in your terminal.
