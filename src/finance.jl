#--------------------------------------------------------------------------------------------------#
#                                  FixedPoint number for finances                                  #
#--------------------------------------------------------------------------------------------------#

SFD =  FixedDecimal{Int64,10}   # from -922337203.6854775808
                                # upto          0.0000000000
                                # upto          0.0000000001
                                # upto  922337203.6854775807

UFD = FixedDecimal{UInt64,10}   # from          0.0000000000
                                # upto          0.0000000001
                                # upto  922337203.6854775807
                                # upto 1844674407.3709551615 (not meant to be used for compat)

INPUTS = Union{UFD, SFD, Rational, Integer}

export UFD, SFD, INPUTS


