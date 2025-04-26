#--------------------------------------------------------------------------------------------------#
#                      operations.jl - balance-changing statement operations                       #
#--------------------------------------------------------------------------------------------------#

# RFB's fiat currency
RFBFiat = :BRL

# export
export RFBFiat

# Empty balance initializer with :BRL as tracking fiat
emptyRFB() = MTB(STB((RFBFiat, RFBFiat)))


#--------------------------------------------------------------------------------------------------#
#                                       Operation Functions                                        #
#--------------------------------------------------------------------------------------------------#

"""
`𝑜Init(prev::MTB = emptyRFB())`\n
Initialization operation, for a new month's statement processing. Argument is previous month's
balance. If ommitted, defaults to an emptyRFB() one.
"""
function 𝑜Init(prev::MTB = emptyRFB())
    return prev
end

