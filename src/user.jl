#--------------------------------------------------------------------------------------------------#
#                                          User Functions                                          #
#--------------------------------------------------------------------------------------------------#

# RFB's fiat currency
RFBFiat = :BRL

function initStmt(prBal::MultiFTBalance = MultiFTBalance(RFBFiat))
    return prBal
end

export initStmt

function rollStatement(srcFi::String, prBal::MultiFTBalance = initStmt())
    STM = strip(read(srcFi, String), '\n')
    LIN = reverse(split(STM, '\n'))
    BAL = prBal # initializes as previous balance
    for lin in LIN # TODO: change into a while loop allowing internal fast-forwards
        gen = GenericStatementLine(lin)
        par = ParsedStmtLine(gen)
        if par.TYPE[1] == "Header"
            # No action
            println(lin)
            display(BAL)
        elseif par.TYPE[1] == "Deposit" || par.TYPE[1] == "Redeemed"
            if par.OUTC
                dep = SingleFTBalance(par.COIN, par.AMNT[2])
                # ASSUMES negative "Deposit"s never make it into statements
                BAL += dep
                println(lin)
                display(BAL)
            end
        elseif par.TYPE[1] == "Buy"
            buyCurPair = par.TYPE[2]
            buyIniDate = par.DATE
            cryp, fiat = [ Symbol(i) for i in split(buyCurPair, '/') ]
            # tmpB = MultiFTBalance(SingleFTBalance(fiat), SingleFTBalance(cryp, fiat))
            if par.OUTC
                amt = SingleFTBalance(par.COIN, par.AMNT[2])
                if par.AMNT[1]; BAL -= amt; else BAL += amt; end
                println(lin)
                display(BAL)
            end
            # TODO: add an inner while loop for fast-forward
            # Balance wallets likely need to change to SIGNED ones
            # Balance wallets likely need untracked version, as to group transactions.
        end
    end
end

export rollStatement

