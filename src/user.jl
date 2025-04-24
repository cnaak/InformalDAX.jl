#--------------------------------------------------------------------------------------------------#
#                                          User Functions                                          #
#--------------------------------------------------------------------------------------------------#

# RFB's fiat currency
RFBFiat = :BRL

function init(prBal::MultiFTBalance = MultiFTBalance(RFBFiat))
    return prBal
end

export init

function rollStatement(srcFi::String, prBal::MultiFTBalance)
    STM = read(srcFi, String)
    LIN = reverse(split(STM, '\n'))

end

