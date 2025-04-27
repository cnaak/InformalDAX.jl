#--------------------------------------------------------------------------------------------------#
#                       statement.jl - InformalDAX statement reading/parsing                       #
#--------------------------------------------------------------------------------------------------#

import Base: show


#--------------------------------------------------------------------------------------------------#
#                                             GenSTLn                                              #
#--------------------------------------------------------------------------------------------------#

"""
`struct GenSTLn <: AbstractSTLn`\n
A data structure representing a generic (any operation type) statement line.
"""
struct GenSTLn <: AbstractSTLn
    dat::String
    typ::String
    coi::String
    amt::String
    out::String
    # Components constructor
    GenSTLn(cmp::NTuple{5,String}) = new(cmp...)
    # Whole line constructor
    GenSTLn(RawStatementLine::AbstractString) = begin
        if length(strip(RawStatementLine)) == 0
            return new("", "", "", "", "")
        end
        noCGr(lab::String) = raw"(?<" * lab * raw">[^,]+)"
        noQGr(lab::String) = raw""""?(?<""" * lab * raw""">[^"]+)"?"""
        tmp = join([noCGr("dat"), noCGr("typ"), noCGr("coi"), noQGr("amt"), noCGr("out")], ",")
        rex = Regex(join(["^", tmp, "\$"]))
        m = match(rex, RawStatementLine)
        @assert(m != nothing, "Couldn't parse the statement line:\n>>> $(RawStatementLine) <<<")
        new(m[:dat], m[:typ], m[:coi], m[:amt], m[:out])
    end
end

# export
export GenSTLn

raw(x::GenSTLn) = join([x.dat, x.typ, x.coi,
                        occursin(',', x.amt) ? "\"$(x.amt)\"" : x.amt,
                        x.out], ",")
# export
export raw

function Base.show(io::IO, ::MIME"text/plain", x::GenSTLn)
    print(@sprintf("GenSTLn(%s)", repr(raw(x))))
end


#--------------------------------------------------------------------------------------------------#
#                                             ParSTLn                                              #
#--------------------------------------------------------------------------------------------------#

struct ParSTLn <: AbstractSTLn
    DATE::DateTime
    TYPE::Tuple{String, String}
    COIN::Symbol
    AMNT::Tuple{Bool, SFD, Symbol}
    OUTC::Bool
    function ParSTLn(g::GenSTLn)
        # Early exit for empty/last statement lines
        if length(g.dat) == 0
            return new(DateTime(0, 1, 1, 0, 0, 0), ("Header", ""),
                       :nothing, (false, zero(SFD), :nothing), false)
        elseif (g.typ    == "Type"   || 
                g.coi    == "Coin"   ||
                g.amt  == "Amount" ||
                g.out == "Status")
            return new(DateTime(0, 1, 1, 0, 0, 0), ("Footer", ""), 
                       :nothing, (false, zero(SFD), :nothing), false)
        end
        # Date parsing
        dex  = raw"^(?<MM>[0-9]{2})/(?<DD>[0-9]{2})/(?<YY>[0-9]{4})"
        tex  = raw" (?<hh>[0-9]{2}):(?<mm>[0-9]{2}):(?<ss>[0-9]{2})"
        rex  = Regex(join([dex, tex], ""))
        m    = match(rex, g.dat)
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
        splt = split(g.typ, ' ')
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
        coin = Symbol(strip(g.coi))
        # Amount parsing
        dash = "-\u2010\u2011\u2012\u2013\u2014\u2015\ufe58\ufe63\uff0d\u2e3a\u2e3b"
        if startswith(raw"R$")(g.amt)
            # R$ (BRL) parsing
            rex  = r"R\$ ?(?<sig>[+-]?)(?<val>[0-9.,]+)"
            m    = match(rex, g.amt)
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
            m    = match(rex, g.amt)
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
        outc = g.out == "Success"
        # Final assembly
        new(date, 𝑡𝑦𝑝𝑒, coin, amnt, outc)
    end
end

# functor
(x::ParSTLn)() = x.DATE, x.TYPE, x.COIN, x.AMNT, x.OUTC

# export
export ParSTLn

function Base.show(io::IO, ::MIME"text/plain", pl::ParSTLn)
    print(@sprintf("Statement Line: (%s)\n  %s\n  %s\n  %s\n  %s",
                   pl.OUTC ? "\u2714" : "\u2716",
                   pl.DATE, pl.TYPE, pl.COIN, pl.AMNT))
end


#--------------------------------------------------------------------------------------------------#
#                                        Utility Functions                                         #
#--------------------------------------------------------------------------------------------------#

# Inverse constructor
function GenSTLn(p::ParSTLn)
    for 𝑥 in ("", "(UTC)dat,Type,Coin,Amount,Status")
        if p == ParSTLn((x = GenSTLn(𝑥); x)); return x; end
    end
    𝑑, 𝑡, 𝑐, 𝑎, 𝑜 = p()
    dStr = @sprintf("%02d/%02d/%04d %02d:%02d:%02d",
                    month(𝑑), day(𝑑), year(𝑑),
                    hour(𝑑), minute(𝑑), second(𝑑))
    if 𝑡[1] == "Fee"
        tStr = join([𝑡[1], "for", 𝑡[2]], " ")
    elseif 𝑡[1] == "Send"
        tStr = join([𝑡...], " ")
    elseif 𝑡[2] != ""
        tStr = @sprintf("%s(%s)", 𝑡...)
    else
        tStr = 𝑡[1]
    end
    cStr = @sprintf("%s", 𝑐)
    aStr = @sprintf("%s%.10f %s", 𝑎[1] ? "-" : "+", 𝑎[2], 𝑎[3])
    return GenSTLn(dStr, tStr, cStr, aStr,oStr)
end


