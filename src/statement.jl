import Base: show

#--------------------------------------------------------------------------------------------------#
#                                       GenericStatementLine                                       #
#--------------------------------------------------------------------------------------------------#

"""
`struct GenericStatementLine <: AbstractStatementLine`\n
A data structure representing a generic (any operation type) statement line.
"""
struct GenericStatementLine <: AbstractStatementLine
    HistoryTradesWsData::String
    TransactionType::String
    TransactionCoin::String
    TransactionAmount::String
    TransactionOutcome::String
    GenericStatementLine(RawStatementLine::String) = begin
        if length(strip(RawStatementLine)) == 0
            return new("", "", "", "", "")
        end
        noCGr(lab::String) = raw"(?<" * lab * raw">[^,]+)"
        noQGr(lab::String) = raw""""?(?<""" * lab * raw""">[^"]+)"?"""
        tmp = join([noCGr("dat"), noCGr("typ"), noCGr("coi"), noQGr("amt"), noCGr("out")], ",")
        rex = Regex(join(["^", tmp, "\$"]))
        m = match(rex, RawStatementLine)
        new(m[:dat], m[:typ], m[:coi], m[:amt], m[:out])
    end
end

export GenericStatementLine

function Base.show(io::IO, ::MIME"text/plain", gl::GenericStatementLine)
    WBOLD = Crayon(foreground = :white, bold = true, background = :dark_gray)
    FAINT = Crayon(foreground = :light_gray, bold = false, background = :default)
    RESET = Crayon(reset = true)
    print(WBOLD, "Date:", FAINT, @sprintf("%20s ", gl.HistoryTradesWsData))
    print(WBOLD, "Type:", FAINT, @sprintf("%22s ", gl.TransactionType    ))
    print(WBOLD, "Coin:", FAINT, @sprintf("%10s ", gl.TransactionCoin    ))
    print(WBOLD, "Amnt:", FAINT, @sprintf("%38s ", gl.TransactionAmount  ))
    print(WBOLD, "Outc:", FAINT, @sprintf("%08s.", gl.TransactionOutcome ))
    print(RESET)
end


