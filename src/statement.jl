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
    STML::String
    DATE::DateTime
    TYPE::Tuple{String, String}
    COIN::Symbol
    AMNT::Tuple{Bool, SFD, Symbol, Union{Tuple{SFD,Symbol},Nothing}}
    OUTC::Bool
    function ParSTLn(g::GenSTLn)
        stml = raw(g)
        # Early exit for empty/last statement lines
        if length(g.dat) == 0
            return new(stml, DateTime(0, 1, 1, 0, 0, 0), ("Header", ""),
                       :nothing, (false, zero(SFD), :nothing, Nothing()), false)
        elseif (g.typ == "Type"   || 
                g.coi == "Coin"   ||
                g.amt == "Amount" ||
                g.out == "Status")
            return new(stml, DateTime(0, 1, 1, 0, 0, 0), ("Footer", ""), 
                       :nothing, (false, zero(SFD), :nothing, Nothing()), false)
        end
        # Date parsing
        dex  = raw"^(?<MM>[0-9]{2})/(?<DD>[0-9]{2})/(?<YY>[0-9]{4})"
        tex  = raw" (?<hh>[0-9]{2}):(?<mm>[0-9]{2}):(?<ss>[0-9]{2})"
        rex  = Regex(join([dex, tex], ""))
        m    = match(rex, g.dat)
        if m isa Nothing
            return new(
                stml,
                DateTime(0, 1, 1, 0, 0, 0),
                ("Header", ""),
                :nothing,
                (false, zero(SFD), :nothing, Nothing()),
                g.out == "Success"
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
                return new(stml, date, 𝑡𝑦𝑝𝑒, coin, (false, zero(SFD), :nothing, Nothing()), false)
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
            amnt = (sbt, SFD(NUME//DENO), :BRL, Nothing())
        else
            # Other parsing
            rex  = r"^(?<sig>[+-]?)(?<val>[0-9.,]+) ?(?<cur>[A-Z]+)(?<gra>.*)$"
            m    = match(rex, g.amt)
            if m isa Nothing
                return new(date, 𝑡𝑦𝑝𝑒, coin,
                           (false, zero(SFD), :nothing, Nothing()),
                           g.out == "Success")
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
            # Approx BRL parsing
            if startswith("(≈R\$")(m[:gra])
                rex  = r"\(≈R\$(?<apr>[0-9.,]+)\)"
                m    = match(rex, m[:gra])
                if m isa Nothing
                    return new(stml, date, 𝑡𝑦𝑝𝑒, coin,
                               (sbt, SFD(NUME//DENO), Symbol(cur), Nothing()),
                               g.out == "Success")
                end
            end
            Deno = 100
            Nume = Int64(
                round(
                    parse(BigFloat, join(split(m[:apr], ','))) * Deno,
                    RoundNearest,
                    digits=0
                )
            )
            amnt = (sbt, SFD(NUME//DENO), Symbol(cur), (SFD(Nume//Deno), :BRL))
        end
        # Outcome parsing
        outc = g.out == "Success"
        # Final assembly
        new(stml, date, 𝑡𝑦𝑝𝑒, coin, amnt, outc)
    end
end

# functor
(x::ParSTLn)() = x.DATE, x.TYPE, x.COIN, x.AMNT, x.OUTC

# export
export ParSTLn

function raw(x::ParSTLn)
    x.STML
end

# export
export raw

# function Base.show(io::IO, ::MIME"text/plain", x::ParSTLn)
#     print(@sprintf("ParSTLn(GenSTLn(%s))", repr(raw(x))))
# end


#--------------------------------------------------------------------------------------------------#
#                                        Utility Functions                                         #
#--------------------------------------------------------------------------------------------------#

# Inverse constructor
function GenSTLn(p::ParSTLn)
    return GenSTLn(p.STML)
end


#--------------------------------------------------------------------------------------------------#
#                                      Accumulating Functions                                      #
#--------------------------------------------------------------------------------------------------#

# Accumulates and groups transactions, translating them into a Vector of operations with arguments
function accumGroupTrans!(TR::Vector{AbstractOP},
                          ST::Vector{ParSTLn},
                          fwd::Bool,
                          PREV::MTB,                    # This (previous) MTB
                          OTHR::Union{MTB,Nothing})     # Other (external) MTB
    # function Dep
    function Dep()
        𝑝 = ST[𝑖]
        @assert(𝑝.COIN == 𝑝.AMNT[3], "Inconsistent deposit amount currency!")
        amt = SUB(𝑝.COIN, 𝑝.AMNT[2])
        append!(TR, [𝒐𝒑Dep(amt; date = 𝑝.DATE)])
        return 1 # Dep runs one at a time
    end
    # function Buy
    function Buy(startType::NTuple{2,AbstractString})
        𝑐, 𝑓 = [Symbol(j) for j in split(startType[2], "/")]    # crypto and fiat
        i, 𝑝 = 0, ST[𝑖]
        oper = 𝒐𝒑Buy(SUB(𝑓, 0), SUB(𝑐, 0), SUB(𝑐, 0), SUB(𝑓, 0))
        while 𝑝.TYPE in [startType, ("Fee", "transaction")]
            @assert(𝑝.COIN == 𝑝.AMNT[3], "Inconsistent purchase amount currency!")
            if 𝑝.COIN == 𝑓
                rec, fee = SUB(𝑐, 0), SUB(𝑐, 0)
                if 𝑝.TYPE[1] == "Buy"
                    pay, eef = SUB(𝑝.COIN, 𝑝.AMNT[2]), SUB(𝑓, 0)
                elseif 𝑝.TYPE[1] == "Fee"
                    pay, eef = SUB(𝑓, 0), SUB(𝑝.COIN, 𝑝.AMNT[2])
                end
            elseif 𝑝.COIN == 𝑐
                pay, eef = SUB(𝑓, 0), SUB(𝑓, 0)
                if 𝑝.TYPE[1] == "Buy"
                    rec, fee = SUB(𝑝.COIN, 𝑝.AMNT[2]), SUB(𝑐, 0)
                elseif 𝑝.TYPE[1] == "Fee"
                    rec, fee = SUB(𝑐, 0), SUB(𝑝.COIN, 𝑝.AMNT[2])
                end
            end
            oper += 𝒐𝒑Buy(pay, rec, fee, eef; date = 𝑝.DATE)
            i += 1
            𝑝 = ST[𝑥(𝑖, i)]
        end
        append!(TR, [oper])
        return i
    end
    # function Seℓ
    function Seℓ(startType::NTuple{2,AbstractString})
        𝑐, 𝑓 = [Symbol(j) for j in split(startType[2], "/")]    # crypto and fiat
        i, 𝑝 = 0, ST[𝑖]
        oper = 𝒐𝒑Seℓ(SUB(𝑐, 0), SUB(𝑓, 0), SUB(𝑓, 0))
        while 𝑝.TYPE in [startType, ("Fee", "transaction")]
            @assert(𝑝.COIN == 𝑝.AMNT[3], "Inconsistent purchase amount currency!")
            if 𝑝.COIN == 𝑓
                pay = SUB(𝑐, 0)
                if 𝑝.TYPE[1] == "Seℓ"
                    rec, fee = SUB(𝑝.COIN, 𝑝.AMNT[2]), SUB(𝑓, 0)
                elseif 𝑝.TYPE[1] == "Fee"
                    rec, fee = SUB(𝑓, 0), SUB(𝑝.COIN, 𝑝.AMNT[2])
                end
            elseif 𝑝.COIN == 𝑐
                rec, fee, pay = SUB(𝑓, 0), SUB(𝑓, 0), SUB(𝑝.COIN, 𝑝.AMNT[2])
            end
            oper += 𝒐𝒑Seℓ(pay, rec, fee; date = 𝑝.DATE)
            i += 1
            𝑝 = ST[𝑥(𝑖, i)]
        end
        append!(TR, [oper])
        return i
    end
    # function Xch
    function Xch(startType::NTuple{2,AbstractString})
        𝑟, 𝑎 = [Symbol(j) for j in split(startType[2], "/")]    # puR and pAy cryptos
        i, 𝑝 = 0, ST[𝑖]
        oper = 𝒐𝒑Xch(SUB(𝑎, 0), SUB(𝑟, 0), SUB(𝑟, 0), SUB(𝑎, 0))
        while 𝑝.TYPE in [startType, ("Fee", "transaction")]
            @assert(𝑝.COIN == 𝑝.AMNT[3], "Inconsistent purchase amount currency!")
            if 𝑝.COIN == 𝑎
                if 𝑝.TYPE[1] == "Buy"
                    pay, eef = SUB(𝑝.COIN, 𝑝.AMNT[2]), SUB(𝑎, 0)
                    rec, fee = SUB(𝑟, 0), SUB(𝑟, 0)
                elseif 𝑝.TYPE[1] == "Sell"
                    pay, eef = SUB(𝑟, 0), SUB(𝑟, 0)
                    rec, fee = SUB(𝑝.COIN, 𝑝.AMNT[2]), SUB(𝑎, 0)
                elseif 𝑝.TYPE[1] == "Fee"
                    pay, eef = SUB(𝑎, 0), SUB(𝑝.COIN, 𝑝.AMNT[2])
                    rec, fee = SUB(𝑟, 0), SUB(𝑟, 0)
                end
            elseif 𝑝.COIN == 𝑟
                if 𝑝.TYPE[1] == "Buy"
                    pay, eef = SUB(𝑎, 0), SUB(𝑎, 0)
                    rec, fee = SUB(𝑝.COIN, 𝑝.AMNT[2]), SUB(𝑟, 0)
                elseif 𝑝.TYPE[1] == "Sell"
                    pay, eef = SUB(𝑝.COIN, 𝑝.AMNT[2]), SUB(𝑟, 0)
                    rec, fee = SUB(𝑎, 0), SUB(𝑎, 0)
                elseif 𝑝.TYPE[1] == "Fee"
                    pay, eef = SUB(𝑎, 0), SUB(𝑎, 0)
                    rec, fee = SUB(𝑟, 0), SUB(𝑝.COIN, 𝑝.AMNT[2])
                end
            end
            oper += 𝒐𝒑Xch(pay, rec, fee, eef; date = 𝑝.DATE)
            i += 1
            𝑝 = ST[𝑥(𝑖, i)]
        end
        append!(TR, [oper])
        return i
    end
    # -------------
    ℓ = length(ST)
    𝑥 = fwd ? (+) : (-)
    𝑖 = fwd ? 1 : ℓ
    isBound(ind) = 1 <= ind <= ℓ
    append!(TR, [𝒐𝒑Ini(PREV, date = 𝑥(ST[𝑖].DATE, -Day(1)))])
    while isBound(𝑖)
        if ST[𝑖].TYPE[1] in ["Deposit", "Redeemed"]
            𝑖 = 𝑥(𝑖, Dep())
        elseif ST[𝑖].TYPE[1] in ["Buy",]
            𝑎, 𝑏 = [Symbol(j) for j in split(ST[𝑖].TYPE[2], "/")]
            𝑠 = sum([isFiat(𝑘) for 𝑘 in (𝑎, 𝑏)])
            if 𝑠 == 1
                𝑖 = 𝑥(𝑖, Buy(ST[𝑖].TYPE))
            elseif 𝑠 == 0
                𝑖 = 𝑥(𝑖, Xch(ST[𝑖].TYPE))
            end
        elseif ST[𝑖].TYPE[1] in ["Sell",]
            𝑎, 𝑏 = [Symbol(j) for j in split(ST[𝑖].TYPE[2], "/")]
            𝑠 = sum([isFiat(𝑘) for 𝑘 in (𝑎, 𝑏)])
            if 𝑠 == 1
                𝑖 = 𝑥(𝑖, Seℓ(ST[𝑖].TYPE))
            elseif 𝑠 == 0
                𝑖 = 𝑥(𝑖, Xch(ST[𝑖].TYPE))
            end
        else
            𝑖 = 𝑥(𝑖, 1)
        end
    end
end

# export
export accumGroupTrans!

# Run operations
function run!(sBal::MTB, oBal::Union{Nothing, MTB}, TR::Vector{AbstractOP})
    for x in TR
        if x isa 𝒐𝒑Ini
            sBal = x()
        elseif x isa 𝒐𝒑Dep
            sBal = x(sBal, oBal)[1]
        end
    end
    return sBal
end

# export
export run!

