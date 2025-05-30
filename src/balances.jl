#--------------------------------------------------------------------------------------------------#
#         balances.jl - crypto assets balances with fiat/on-ramp tracking (purchase price)         #
#--------------------------------------------------------------------------------------------------#

import Base: show, +, -, *, ==, isless
import Base: keys
import Base: zero, one


#--------------------------------------------------------------------------------------------------#
#                                       Primitive Functions                                        #
#--------------------------------------------------------------------------------------------------#


# Returns true if x.cur is a fiat currency
isFiat(x::Symbol) = x in Currencies.allsymbols()

# Returns true if x.cur is not a fiat currency
isCryp(x::Symbol) = !isFiat(x)



#--------------------------------------------------------------------------------------------------#
#                                    Single, Untracked Balance.                                    #
#--------------------------------------------------------------------------------------------------#

"""
`struct SUB <: Untrakd`\n
Single, Untracked Balance.
"""
struct SUB <: Untrakd
    cur::Symbol
    bal::SFD
    function SUB(CUR::Symbol, BAL::SFD = zero(SFD))
        #@assert(BAL >= zero(SFD), "InformalDAX does not operate with negative balances!")
        cur = string(CUR)
        if length(cur) > CRYP_SYMB_MAX_LEN
            j = i = firstindex(cur)
            for k in 2:6
                i = nextind(cur, i)
            end
            cro = cur[j:i]
            new(Symbol(cro), BAL)
        else
            new(Symbol(cur), BAL)
        end
    end
end

# Outer constructors
function SUB(CUR::Symbol, BAL::Real)
    DENO = 100000000
    NUME = Int64(
        round(
            parse(BigFloat, @sprintf("%.8f", BAL)) * DENO,
            RoundNearest,
            digits=0
        )
    )
    SUB(CUR, SFD(NUME//DENO))
end

# bare function to return the "bare" balance
bare(x::SUB) = x.bal

# symb function to return the currency symbol
symb(x::SUB) = x.cur

# Functor returns currency => balance Pair
(x::SUB)() = symb(x) => bare(x)

# name function to return the currency "name"
name(x::SUB) = string(symb(x))

# decs function to return the currency number of decimal places
decs(x::SUB) = isFiat(x) ? Currencies.unit(x.cur) : 8

# Returns true if x.cur is a fiat currency
isFiat(x::SUB) = x.cur in Currencies.allsymbols()

# Returns true if x.cur is not a fiat currency
isCryp(x::SUB) = !isFiat(x)

# Pretty string function
pretty(x::SUB) = begin
    isCryp(x) ?
        @sprintf("%+*.*f %6s", 13 + decs(x), decs(x), bare(x), name(x)) :
        @sprintf("%+*.*f %3s", 13 + decs(x), decs(x), bare(x), name(x))
end

# Uniformly pretty
unipre(x::SUB) = @sprintf("%+21.8f %6s", bare(x), name(x))

# zero function
zero(x::SUB) = SUB(symb(x), zero(SFD))
zero(::Type{SUB}, s::Symbol) = SUB(s, zero(SFD))

# one function
one(x::SUB) = SUB(symb(x), one(SFD))
one(::Type{SUB}, s::Symbol) = SUB(s, one(SFD))

# export
export SUB, bare, symb, name, decs, isFiat, isCryp, zero, one

# Unary minus
-(x::SUB) = SUB(symb(x), -bare(x))

# Addition
+(x::SUB, y::SUB) = begin
    @assert(symb(x) == symb(y), "Can't add different currency balances!")
    return SUB(x.cur, x.bal + y.bal)
end

# Subtraction
-(x::SUB, y::SUB) = begin
    @assert(symb(x) == symb(y), "Can't sub different currency balances!")
    return SUB(x.cur, x.bal - y.bal)
end

# Left/right scalar multiplication
*(x::SUB, y::Real) = SUB(x.cur, x.bal * y)
*(y::Real, x::SUB) = x * y

# isless
isless(x::SUB, y::SUB) = begin
    @assert(symb(x) == symb(y), "Can't order different currencies without exchange rates!")
    isless(bare(x), bare(y))
end

# ==
==(x::SUB, y::SUB) = begin
    @assert(symb(x) == symb(y), "Can't order different currencies without exchange rates!")
    ==(bare(x), bare(y))
end

# show/display
function Base.show(io::IO, ::MIME"text/plain", x::SUB)
    print(pretty(x))
end


#--------------------------------------------------------------------------------------------------#
#                                     Single, Tracked Balance.                                     #
#--------------------------------------------------------------------------------------------------#

"""
`struct STB <: UniTracked`\n
Single, Tracked Balance.
"""
struct STB <: UniTracked
    cryp::SUB
    fiat::SUB
    function STB(CRYP::SUB, FIAT::SUB)
        @assert(isFiat(FIAT), "Tracking must be against a Fiat currency!")
        bothNonZero() = (bare(CRYP) != zero(SFD)) && (bare(FIAT) != zero(SFD))
        bothAreZero() = (bare(CRYP) == zero(SFD)) && (bare(FIAT) == zero(SFD))
        #@assert(bothNonZero() || bothAreZero(), "Exchange ratio must be finite!")
        new(CRYP, FIAT)
    end
end

# outer constructors
STB(symb::NTuple{2,Symbol},
    bare::NTuple{2,Real} = (0, 0)) = begin
    STB(SUB(symb[1], bare[1]), SUB(symb[2], bare[2]))
end

# export
export STB

# bare function to return the "bare" balance
bare(x::STB) = (bare(x.cryp), bare(x.fiat))

# symb function to return the currency symbol
symb(x::STB) = (symb(x.cryp), symb(x.fiat))

# Functor returns currency => balance Pair
(x::STB)() = symb(x) => bare(x)

# name function to return the currency "name"
name(x::STB) = @sprintf("%s/%s", name(x.cryp), name(x.fiat))

# decs function to return the currency number of decimal places
decs(x::STB) = (decs(x.cryp), decs(x.fiat))

# Returns true if x.cryp.cur is a fiat currency
isFiat(x::STB) = x.cryp.cur in Currencies.allsymbols()

# Returns true if x.cryp.cur is not a fiat currency
isCryp(x::STB) = !isFiat(x)

# Pretty string function
function pretty(x::STB)
    @sprintf("%s (%s)", unipre(x.cryp), pretty(x.fiat))
end

# zero function
zero(x::STB) = STB(zero(x.cryp), zero(x.fiat))
zero(::Type{STB}, c::Symbol, f::Symbol) = STB(zero(SUB, c), zero(SUB, f))

# one function
function one(x::STB)
    if x.cryp == zero(x.cryp)
        STB(one(x.cryp), one(x.fiat))
    else
        inv(bare(x.cryp)) * x
    end
end

# one function
function one(::Type{STB}, c::Symbol, f::Symbol, x_r::Real = 1)
    STB(one(SUB, c), x_r * one(SUB, f))
end

# Left/right scalar multiplication
*(x::STB, y::Real) = STB(x.cryp * y, x.fiat * y)
*(y::Real, x::STB) = x * y

# Unary minus
-(x::STB) = STB(-x.cryp, -x.fiat)

# Addition
+(x::STB, y::STB) = begin
    @assert(symb(x) == symb(y), "Can't add different tracking pair balances!")
    STB(x.cryp + y.cryp, x.fiat + y.fiat)
end

# Reference rate subtraction
-(x::STB, ref::STB) = begin
    @assert(symb(x.fiat) == symb(ref.fiat), "Can't subtract different fiat trackings!")
    @assert(symb(x.cryp) == symb(ref.cryp), "Can't subtract different single crypto trackings!")
    return -(x, ref.cryp, ref)  # Explicitly falls back to reference rate subtraction
end

# Subtraction
"""
# InformalDAX's "tracked" subtraction of crypto assets

`-(x::STB, y::SUB, ref::Union{STB,Nothing} = nothing)::Tuple{STB,STB}`\n
Tracked subtraction \$x - y\$ that returns a `(result, taken)` tuple, where `result` is the
resulting tracked subtraction, and `taken` is the tracked taken amount based on `y` (an
untracked balance), such that `taken.cryp == y`, and `taken.fiat` is adjusted to the proper
ratio of purchasing fiat currency.

The `ref` tracking serves as reference (not mandatory) crypto-to-fiat exchange rate, and is only
used if the rate cannot be calculated from `x` (for instance `x == STB(SUB(:cryp, 0), SUB(:fiat,
0)) --> true`).

## Example:

Suppose initially one buys `0.01 BTC` for `980 USD`; one's tracked balance is therefore:

```julia
julia> using InformalDAX

julia> myBTCBal = STB((:BTC, :USD), (1//100, 980))  # STB is a Single Tracked Balance object
        +0.0100000000    BTC (      +980.00 USD)
```

Then, out of this balance, `0.001 BTC` gets transfered away. The remaining tracked (adjusted)
and tracked taken balances are:

```julia
julia> xfer = SUB(:BTC, 1//1000)                    # SUB is a Single Untracked Balance object
        +0.0010000000    BTC

julia> myBTCBal, xfer = myBTCBal - xfer;            # Updates `myBTCBal` and adds
                                                    # tracking info to `xfer`
julia> [ display(i) for i in (myBTCBal, xfer) ];
        +0.0090000000    BTC (      +882.00 USD)
        +0.0010000000    BTC (       +98.00 USD)
```

Meaning the retained balance of `0.009 BTC` retained `882 USD` in fiat purchase price—the data
in `myBTCBal`; and the taken amount of `0.001 BTC` represents a fraction worth of `98 USD` of
its purchase price in fiat currency—the data in `xfer`.
"""
-(x::STB, y::SUB, ref::Union{STB,Nothing} = nothing)::Tuple{STB,STB} = begin
    @assert(symb(x)[1] == symb(y), "Can't sub different tracking pair balances!")
    if x.cryp == zero(x.cryp)
        if ref isa STB
            @assert(symb(x) == symb(ref), "Can't reference sub different tracking pair balances!")
            x_r = bare(ref.fiat) / bare(ref.cryp)
            Y   = STB(y, SUB(symb(ref.fiat), x_r * bare(y)))
            return -Y, Y
        else
            Y   = STB(y, SUB(symb(x.fiat), bare(y)))
            return -Y, Y
        end
    else
        dif = x.cryp - y                    # the difference
        r_d = bare(dif) / bare(x.cryp)      # the 0 <= difference ratio <= 1
        trk = r_d * x.fiat                  # the tracked remaining fiat
        RES = STB(dif, trk)                 # the tracked subtraction result
        TKN = STB(  y, x.fiat - trk)        # the tracked taken value
        return (RES, TKN)
    end
end

# show/display
function Base.show(io::IO, ::MIME"text/plain", x::STB)
    print(pretty(x))
end


#--------------------------------------------------------------------------------------------------#
#                                    Multiple, Tracked Balance.                                    #
#--------------------------------------------------------------------------------------------------#

"""
`struct MTB <: MulTracked`\n
Multiple, Tracked Balance.
"""
struct MTB <: MulTracked
    Mult::Dict{NTuple{2,Symbol},STB}
    function MTB(x::STB...)
        𝑐 = Set([symb(i)[1] for i in x])
        𝑓 = Set([symb(i)[2] for i in x])
        @assert(length([𝑓...]) == 1, "Multiple tracking fiats!")
        f = [𝑓...][1]
        if !(f ∈ 𝑐)
            return MTB(STB(SUB(f, 0), SUB(f, 0)), x...)
        else
            return new(Dict([symb(i) => i for i in x]))
        end
    end
    function MTB(x::STB)
        if !isFiat(x)
            return MTB(STB(SUB(RFBFiat, 0), SUB(RFBFiat, 0)), x)
        else
            return new(Dict(symb(x) => x))
        end
    end
end

# outer constructors
function MTB(s::Vector{<:NTuple{2,Symbol}}, b::Vector{<:NTuple{2,Real}})
    @assert(length(s) == length(b), "Mismatching argument lengths!")
    𝑠 = tuple([STB(s[i], b[i]) for i in 1:length(s)]...)
    MTB(𝑠...)
end

# Functor output's outer (copy) constructor
MTB(𝑝::Pair{<:Vector{<:NTuple{2,Symbol}}, <:Vector{<:NTuple{2,Real}}}) = MTB(𝑝...)

MTB(𝑑::Dict{NTuple{2,Symbol},Real}) = MTB([keys(𝑑)...] => [values(𝑑)...])

# export
export MTB

# bare function to return the "bare" balance
bare(x::MTB) = collect(bare(x.Mult[i]) for i in keys(x))

# symb function to return the currency symbol
symb(x::MTB) = collect(symb(x.Mult[i]) for i in keys(x))

# Functor returns currency => balance Pair
(x::MTB)() = symb(x) => bare(x)

# fiat
fiat(x::MTB) = [keys(x.Mult)...][1][2]

# keys - return the keys of `x` as a sorted vector of keys, the first always being the fiat one
function keys(x::MTB)
    myFind(item, iter) = begin
        for i in 1:length(iter)
            if iter[i] == item
                return i
            end
        end
    end
    f = fiat(x)
    k = [keys(x.Mult)...]
    fid = myFind((f, f), k)
    ret = [popat!(k,fid),]
    return append!(ret, sort(k))
end

export fiat

# Pretty string function
pretty(x::MTB) = begin
    ret = String[]
    for 𝑘 in keys(x)
        append!(ret, [ pretty(x.Mult[𝑘])] )
    end
    return join(ret, "\n")
end

# Addition
+(x::MTB, y::STB) = begin
    @assert(fiat(x) == symb(y.fiat), "Can't operate on different fiat trackings!")
    𝑥 = MTB(x())
    if symb(y) in keys(x)
        𝑥.Mult[symb(y)] += y
    else
        𝑥.Mult[symb(y)] = y
    end
    return 𝑥
end

+(x::MTB, y::MTB) = begin
    sum = MTB(x())
    for k in keys(y)
        sum += y.Mult[k]
    end
    return sum
end

# Subtraction
-(x::MTB, y::SUB) = begin
    #@assert((symb(y), fiat(x)) in keys(x), "Can't take unowned currency from balance!")
    𝑥 = MTB(x())
    if symb(y) == fiat(𝑥)
        ref = one(STB, symb(y), fiat(𝑥))
        𝑥.Mult[(symb(y), fiat(𝑥))], taken = -(𝑥.Mult[(symb(y), fiat(𝑥))], y, ref)
    else
        𝑥.Mult[(symb(y), fiat(𝑥))], taken = -(𝑥.Mult[(symb(y), fiat(𝑥))], y)
    end
    return 𝑥, taken
end

# STB Subtraction
-(x::MTB, y::STB) = begin
    @assert(fiat(x) == symb(y.fiat), "Can't operate on different fiat trackings!")
    𝑥 = MTB(x())
    if symb(y) in keys(𝑥)
        𝑥.Mult[symb(y)], taken = -(𝑥.Mult[symb(y)], y)
    else
        𝑥.Mult[symb(y)], taken = -y, y
    end
    return 𝑥, taken
end

# show/display
function Base.show(io::IO, ::MIME"text/plain", x::MTB)
    print(pretty(x))
end


