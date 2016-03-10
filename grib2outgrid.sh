#!/bin/bash

# Takes one argument (a grib file)
# Will print contents of a corresponding OUTGRID file to stdout
#
# Usage:
#
#   grib2outgrid EN2014021118 [ztops] > OUTGRID
#
#   ztops is a list of the top of vertical layers to be used it
#   should be enclosed in single quotes (e.g. '100, 500, 15000')

# Exit codes used by this script:
ERR_ARG=10

NO_ARGS=0 
E_OPTERROR=85

if [ $# -eq "$NO_ARGS" ]; then  # No arguments given
  echo "Usage: $(basename $0) [-r N] [-z 1,2,..] GRIBFILE"  # Explain usage
  echo "  Options must be given _before_ the filename"
  exit $E_OPTERROR          # Exit
fi  


while getopts ":r:z:" Option
do
  case $Option in
    r | R )
      #echo "Resolution scaling: option -r-   [OPTIND=${OPTIND}]"
      #echo "Scaling set to $OPTARG"
      RSCALE=$OPTARG
      ;;
    z )
      #echo "z-levels specified option -$Option-   [OPTIND=${OPTIND}]"
      #echo "Levels: $OPTARG"
      ZTOPS="$OPTARG"
      ;;
    * )
      echo "Unimplemented option chosen."
      ;;   # Default.
  esac
done

shift $(($OPTIND - 1))
#  Decrements the argument pointer so it points to next argument.
#  $1 now references the first non-option item supplied on the command-line
#+ if one exists.


set -e

GRIBFILE=$1
SCRIPTNAME=${0##*/}
PID=$$

if [[ -z $ZTOPS ]]; then
  OUTHEIGHTS="25,50,100,1000,2000,3000,4000,5000,6000,7000,8000,9000,10000,25000"
fi

# Check that RSCALE is set up properly
RE_INT='^[0-9]+$' # Regular expression which only matches "integer" variables 
# (actually, all bash variables are string variables, but this matches variables
#  which can be interpreted as integers (i.e. that only contain digits) )
if [[ -z $RSCALE ]]; then # if unset
  RSCALE=1    # Set it
elif ! [[ $RSCALE =~ $RE_INT ]] then  # Check if $RSCALE can be used as an integer
  # ('=~' expands righthand side as extended regular expression)
  echo "option '-r' passed, but argument is not an integer!" 1>&2
  echo "(argument given: -r$RSCALE)" 1>&2
  exit $ERR_ARG
fi

TMPFILE="$SCRIPTNAME-${PID}.tmp"

# Settings for floating point operations:
PREC=10   # Number of decimal values in calculations
NDEC=4    # Number of decimal values in output

if [[ -z $GRIBFILE ]]; then
  echo "No input file supplied" 1>&2
  exit $ERR_ARG
elif [[ ! -f $GRIBFILE ]]; then
  echo "No file named $GRIBFILE" 1>&2
  exit 2
fi

if [[ -z $ZTOPS ]]; then
  ZTOPS="25, 50, 100, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 25000"
fi


if which grib_dump >/dev/null; then
  # extract coordinate information:
  grib_dump "$GRIBFILE"|grep -m1 latitudeOfFirstGridPointInDegrees -A5 > "$TMPFILE"

  # Get information for namelist
  LAT1=$(grep "latitudeOfFirstGridPointInDegrees"   "$TMPFILE"|egrep -o '\-*[0-9]{1,3}\.*[0-9]*')
  LAT2=$(grep "latitudeOfLastGridPointInDegrees"    "$TMPFILE"|egrep -o '\-*[0-9]{1,3}\.*[0-9]*')
  LON1=$(grep "longitudeOfFirstGridPointInDegrees"  "$TMPFILE"|egrep -o '\-*[0-9]{1,3}\.*[0-9]*')
  LON2=$(grep "longitudeOfLastGridPointInDegrees"   "$TMPFILE"|egrep -o '\-*[0-9]{1,3}\.*[0-9]*')
  DX=$(grep "iDirectionIncrementInDegrees"  "$TMPFILE"|egrep -o '[0-9]+\.*[0-9]*')
  DY=$(grep "iDirectionIncrementInDegrees"  "$TMPFILE"|egrep -o '[0-9]+\.*[0-9]*')

  # Calculate number of grid points:
  #echo "LON1=$LON1; LON2=$LON2; DX=$DX"
  NX=$(echo "scale=$PREC; ($LON2-$LON1)/$DX" |bc)
  NY=$(echo "scale=$PREC; ($LAT1-$LAT2)/$DY" |bc)

  # Add padding representing half of the resolution:
  #LON1=$(echo "scale=$PREC; $LON1+$DX/2"|bc)
  #LAT2=$(echo "scale=$PREC; $LAT2+$DY/2"|bc)
  #NX=$(echo "$NX-1"|bc) # This also truncates to whole integers
  #NY=$(echo "$NY-1"|bc) #

  # Truncate NX & NY to 0 decimals:
  NX=$(echo "$NX/1"|bc)
  NY=$(echo "$NY/1"|bc)

  # Ensure that LON1 is within [-180,180] ( [0,360] is not supported in flexpart! )
  if [[ $LON1 < "-180" ]]; then
    LON1=$(echo "scale=$PREC; $LON1+360"|bc) 
  elif [[ $LON1 > "180" ]]; then
    LON1=$(echo "scale=$PREC; $LON1-360"|bc) 
  fi
  # Truncate OUTLON0 to NDEC decimals:
  LON1=$(echo "scale=$NDEC; $LON1/1"|bc)

  # OUTPUT INFORMATION IN FLEXPART NAMELIST FORMAT
  echo "&OUTGRID"
  echo "  OUTLON0      =  $LON1"
  echo "  OUTLAT0      =  $LAT2"
  echo "  NUMXGRID     =  $NX"
  echo "  NUMYGRID     =  $NY"
  echo "  DXOUT        =  $DX"
  echo "  DYOUT        =  $DY"
  echo "  OUTHEIGHTS   =  $ZTOPS"
  echo "/"

  rm $TMPFILE
else
  echo "Unable to find grib_dump in \$PATH, please ensure it is installed on your system." >&2
  exit 10
fi
