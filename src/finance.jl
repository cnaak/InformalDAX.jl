#--------------------------------------------------------------------------------------------------#
#            finance.jl - FixedPoint number for crypto finances with 10 decimal places             #
#--------------------------------------------------------------------------------------------------#

SFD =  FixedDecimal{Int64,10}   # from -922337203.6854775808
                                # upto          0.0000000000
                                # upto          0.0000000001
                                # upto  922337203.6854775807

INPUTS = Union{SFD, Rational, Integer}

# export
export SFD, INPUTS


