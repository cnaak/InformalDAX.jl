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
    GenericStatementLine(RawStatementLine::AbstractString) = begin
        @assert(length(strip(RawStatementLine)) > 0, "Empty line.")
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


#--------------------------------------------------------------------------------------------------#
#                                          ParsedStmtLine                                          #
#--------------------------------------------------------------------------------------------------#

struct ParsedStmtLine <: AbstractStatementLine
    DATE::DateTime
    TYPE::String
    COIN::Symbol
    AMNT::Tuple{Bool,UFD}
    OUTC::Bool
    function ParsedStmtLine(g::GenericStatementLine)
        # Date parsing
        dex  = raw"^(?<MM>[0-9]{2})/(?<DD>[0-9]{2})/(?<YY>[0-9]{4})"
        tex  = raw" (?<hh>[0-9]{2}):(?<mm>[0-9]{2}):(?<ss>[0-9]{2})"
        rex  = Regex(join([dex, tex], ""))
        m    = match(rex, g.HistoryTradesWsData)
        date = DateTime(
            Date(
                 parse(Int, m[:YY]),
                 parse(Int, m[:MM]),
                 parse(Int, m[:DD]),
            ),
            Time(
                 parse(Int, m[:hh]),
                 parse(Int, m[:mm]),
                 parse(Int, m[:ss]),
            )
        )
        # Type parsing
        𝑡𝑦𝑝𝑒 = string(split(g.TransactionType, " ")[1])
        # Coin parsing
        coin = Symbol(strip(g.TransactionCoin))
        # Amount parsing
        rex  = r"^(?<gr>[^(]+)"
        m    = match(rex, g.TransactionAmount)
        grp  = split(m[:gr], " ")
        dash = "-\u2010\u2011\u2012\u2013\u2014\u2015\ufe58\ufe63\uff0d\u2e3a\u2e3b"
        sbt  = grp[1][1] in dash ? true : false
        DENO = 10000000000
        NUME = Int64(
            round(
                parse(BigFloat, grp[1][2:end]) * DENO,
                RoundNearest,
                digits=0
            )
        )
        amnt = (sbt, UFD(SFD(NUME//DENO)))
        # Outcome parsing
        outc = g.TransactionOutcome == "Success"
        # Final assembly
        new(date, 𝑡𝑦𝑝𝑒, coin, amnt, outc)
    end
end





