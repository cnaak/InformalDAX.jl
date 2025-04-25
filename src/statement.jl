#--------------------------------------------------------------------------------------------------#
#                       statement.jl - InformalDAX statement reading/parsing                       #
#--------------------------------------------------------------------------------------------------#

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

# export
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
    TYPE::Tuple{String, String}
    COIN::Symbol
    AMNT::Tuple{Bool, SFD, Symbol}
    OUTC::Bool
    function ParsedStmtLine(g::GenericStatementLine)
        # Early exit for empty/last statement lines
        if length(g.HistoryTradesWsData) == 0
            return new(DateTime(0, 1, 1, 0, 0, 0), ("Header", ""),
                       :nothing, (false, zero(SFD), :nothing), false)
        elseif (g.TransactionType    == "Type"   || 
                g.TransactionCoin    == "Coin"   ||
                g.TransactionAmount  == "Amount" ||
                g.TransactionOutcome == "Status")
            return new(DateTime(0, 1, 1, 0, 0, 0), ("Footer", ""), 
                       :nothing, (false, zero(SFD), :nothing), false)
        end
        # Date parsing
        dex  = raw"^(?<MM>[0-9]{2})/(?<DD>[0-9]{2})/(?<YY>[0-9]{4})"
        tex  = raw" (?<hh>[0-9]{2}):(?<mm>[0-9]{2}):(?<ss>[0-9]{2})"
        rex  = Regex(join([dex, tex], ""))
        m    = match(rex, g.HistoryTradesWsData)
        if m isa Nothing
            return new(
                DateTime(0, 1, 1, 0, 0, 0),
                ("Header", ""),
                :nothing,
                (false, zero(SFD), :nothing),
                false
            )
        end
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
        splt = split(g.TransactionType, ' ')
        if length(splt) >= 3
            𝑡𝑦𝑝𝑒 = (string(splt[1]), string(splt[end]))
        elseif length(splt) == 2
            𝑡𝑦𝑝𝑒 = (string(splt[1]), string(splt[2]))
        elseif length(splt) == 1
            splt = split(splt[1], ['(', ')'])
            if length(splt) >= 2
                𝑡𝑦𝑝𝑒 = (string(splt[1]), string(splt[2]))
            else
                𝑡𝑦𝑝𝑒 = (string(splt[1]), "")
            end
        end
        # Coin parsing
        coin = Symbol(strip(g.TransactionCoin))
        # Amount parsing
        dash = "-\u2010\u2011\u2012\u2013\u2014\u2015\ufe58\ufe63\uff0d\u2e3a\u2e3b"
        if startswith(raw"R$")(g.TransactionAmount)
            # R$ (BRL) parsing
            rex  = r"R\$ ?(?<sig>[+-]?)(?<val>[0-9.,]+)"
            m    = match(rex, g.TransactionAmount)
            if m isa Nothing
                return new(date, 𝑡𝑦𝑝𝑒, coin, (false, zero(SFD), :nothing), false)
            end
            sig  = m[:sig]
            val  = m[:val]
            sbt  = sig[1] in dash ? true : false
            DENO = 100
            NUME = Int64(
                round(
                    parse(BigFloat, join(split(val, ','))) * DENO,
                    RoundNearest,
                    digits=0
                )
            )
            amnt = (sbt, SFD(NUME//DENO), :BRL)
        else
            # Other parsing
            rex  = r"^(?<sig>[+-]?)(?<val>[0-9.,]+) ?(?<cur>[A-Z]+)"
            m    = match(rex, g.TransactionAmount)
            if m isa Nothing
                return new(date, 𝑡𝑦𝑝𝑒, coin, (false, zero(SFD), :nothing), false)
            end
            sig  = m[:sig]
            val  = m[:val]
            cur  = m[:cur]
            sbt  = sig[1] in dash ? true : false
            DENO = 10000000000
            NUME = Int64(
                round(
                    parse(BigFloat, join(split(val, ','))) * DENO,
                    RoundNearest,
                    digits=0
                )
            )
            amnt = (sbt, SFD(NUME//DENO), Symbol(cur))
        end
        # Outcome parsing
        outc = g.TransactionOutcome == "Success"
        # Final assembly
        new(date, 𝑡𝑦𝑝𝑒, coin, amnt, outc)
    end
end

# export
export ParsedStmtLine

function Base.show(io::IO, ::MIME"text/plain", pl::ParsedStmtLine)
    print(@sprintf("Statement Line: (%s)\n  %s\n  %s\n  %s\n  %s",
                   pl.OUTC ? "\u2714" : "\u2716",
                   pl.DATE, pl.TYPE, pl.COIN, pl.AMNT))
end


