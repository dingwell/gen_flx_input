# gen_flx_input
## Introduction
Some simple tools to make setting up __flexpart__ domains simpler

These tools were written for __flexpart v.10__ (in BETA at time of writing).
The input files have been modified in v.10 and an option to input data on the
much more flexible namelist format has been added.
Many of these tools will therefore _not_ work with earlier version of __flexpart__.

## Scripts
A brief description of the scripts in this repository

### files2available.sh
Prints an __AVAILABLE__ file to stdout for use in __flexpart v.10__.
Takes a list of input files as argument, the file names must follow the format:
AA11223344
where
AA are two arbitrary characters
11 is the year on 2-digit format (will assume 1900s when year>50, else: 2000s)
22 is the 2-digit month
33 is the 2-digit day
44 is the 2-digit hour (24-hour format)

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
