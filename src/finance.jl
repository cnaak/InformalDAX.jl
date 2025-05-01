#--------------------------------------------------------------------------------------------------#
#            finance.jl - FixedPoint number for crypto finances with 10 decimal places             #
#--------------------------------------------------------------------------------------------------#

SFD =  FixedDecimal{Int64,8}    # from -92233720368.54775808
                                # upto            0.00000000
                                # upto            0.00000001
                                # upto  92233720368.54775807

# export
export SFD

# Other Constants
const CRYP_SYMB_MAX_LEN = 6

# export
export CRYP_SYMB_MAX_LEN

