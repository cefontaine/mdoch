

# Quick Start #

## Install Chapel ##

Go to http://chapel.cray.com/download.html and follow the instructions from `chapel/README` to install Chapel.

## Download and Build ##

Download stable release from http://code.google.com/p/mdoch/downloads/, and extract the package by
```
$ tar zxf mdoch.tar.gz
```

Or, check out latest source by
```
$ hg clone https://mdoch.googlecode.com/hg/ mdoch
```

and build simply by
```
$ cd mdoch && make
```

## Run ##
In [src](http://code.google.com/p/mdoch/source/browse/#hg%2Fsrc) directory, a single program includes three files with the same prefix but different suffix:
  * `prog.chpl`: Program Chapel source file
  * `prog.in`:  Program input parameters config file
  * `prog`: Program executable
```
$ ./fmm                # run with default settings
$ ./fmm -ffmm.in       # run with settings in ".in" config file
$ ./fmm -stepLimit=100 # run with settings specified by command arguments
$ ./fmm -h             # show all configurable arguments
```

There is also a C reference implementation in In [c](http://code.google.com/p/mdoch/source/browse/#hg%2Fsrc) directory, which includes identical C implementation.
```
# Settings can only be specified in config file
$ vi c/fmm.in
$ c/fmm
```