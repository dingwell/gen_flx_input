# gen_flx_input
## Introduction
Some simple tools to make setting up __flexpart__ domains simpler

These tools were written for __flexpart v.10__ (in BETA at time of writing).
The input files have been modified in v.10 and an option to input data on the
much more flexible namelist format has been added.
Many of these tools will therefore _not_ work with earlier version of __flexpart__.

## Scripts
A brief description of the scripts in this repository
### grib2outgrid.sh
Prints an __OUTGRID__ file to stdout for use in __flexpart v.10__,
it takes a _grib_-file as input and creates a flexpart domain covering the same
geographical region. The script was written for data from ECMWF so
I don't know if it will work for __GFS__ data, regardless,
__GFS__-data is currently only supported on global domains so this script
wouldn't be much of use anyway...

The script accepts some commandline options;
such as specifying the vertical levels in the generated __OUTGRID__,
or increasing the output resolution relative the input data.

Basic usage:
grib2outgrid.sh [options] GRIBFILE > OUTGRID
