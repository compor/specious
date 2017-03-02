# 429.mcf input set manipulation utility

# The aim of this script is to produce a reduced input set from an already
# existing for the SPEC CPU2006 429.mcf benchmark.
# The method is described in:
# Technical Report
# "Reduced input data sets selection for SPEC CPUint2006" 
# Virginia Escuder, Rafael Rico
# 2009

# In short, the first 2 numbers denote the lenght of the 2 lists following:
# a) the start and end time of each timetabled (TT) trip
# b) for each dead-head (DH) trip, the start and end of the timetabled trip
# along with a cost
# The index of each TT trip is implied by the order found in the file.
# This number is stated explicitly in the first and second elements of the
# second list.
# Thus, after selecting a number of elements in the first list, we shift through
# the first and second elements of the second list, while also keeping a count
# to be used as part of the first line in the new listing.


BEGIN {
  REDUCED_TT_TRIPS = N;
  CURRENT_TT_TRIPS = 0;

  TT_TRIPS_CNT = 0;
  DH_TRIPS_CNT = 0;

  if(REDUCED_TT_TRIPS <= 0) {
    print "selected trips number must be greater than 0" > "/dev/stderr"
    print "set variable N at the command line" > "/dev/stderr"

    exit 1
  }
}
{
  if(NR == 1) {
    CURRENT_TT_TRIPS = $1

    if(REDUCED_TT_TRIPS > CURRENT_TT_TRIPS) {
      print "selected trips number is greater than current set" > "/dev/stderr"

      exit 1
    }
  }
  else if(NR > 1 && NR <= REDUCED_TT_TRIPS + 1) {
    TT_TRIPS[TT_TRIPS_CNT++] = $0
  }
  else {
    if($1 <= REDUCED_TT_TRIPS && $2 <= REDUCED_TT_TRIPS) {
      DH_TRIPS[DH_TRIPS_CNT++] = $0
    }
  }
}
END {
  print REDUCED_TT_TRIPS" "DH_TRIPS_CNT

  for(tt in TT_TRIPS)
    print TT_TRIPS[tt]

  for(dh in DH_TRIPS)
    print DH_TRIPS[dh]
}

