#--------------------------------------------------------------------------------------------------#
#         balances.jl - crypto assets balances with fiat/on-ramp tracking (purchase price)         #
#--------------------------------------------------------------------------------------------------#

import Base: show, +, -, *, abs
import Base: keys


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
        @assert(BAL >= zero(SFD), "InformalDAX does not operate with negative balances!")
        new(CUR, BAL)
    end
end

# Outer constructors
SUB(CUR::Symbol, BAL::DECIM) = SUB(CUR, SFD(BAL))

# bare function to return the "bare" balance
bare(x::SUB) = x.bal

# symb function to return the currency symbol
symb(x::SUB) = x.cur

# Functor returns currency => balance Pair
(x::SUB)() = symb(x) => bare(x)

# name function to return the currency "name"
name(x::SUB) = string(symb(x))

# decs function to return the currency number of decimal places
decs(x::SUB) = isFiat(x) ? Currencies.unit(x.cur) : 10

# Returns true if x.cur is a fiat currency
isFiat(x::SUB) = x.cur in Currencies.allsymbols()

# Returns true if x.cur is not a fiat currency
isCryp(x::SUB) = !isFiat(x)

# Pretty string function
pretty(x::SUB) = begin
    isCryp(x) ?
        @sprintf("%+*.*f %6s", 11 + decs(x), decs(x), bare(x), name(x)) :
        @sprintf("%+*.*f %3s", 11 + decs(x), decs(x), bare(x), name(x))
end

# Uniformly pretty
unipre(x::SUB) = @sprintf("%+21.10f %6s", bare(x), name(x))

# export
export SUB, bare, symb, name, decs, isFiat, isCryp

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
*(x::SUB, y::DECIM) = SUB(x.cur, x.bal * y)
*(y::DECIM, x::SUB) = x * y

# Abs
abs(x::SUB) = SUB(symb(x), abs(bare(x)))

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
        @assert(bothNonZero() || bothAreZero(), "Exchange ratio must be finite!")
        new(CRYP, FIAT)
    end
end

# outer constructors
STB(symb::NTuple{2,Symbol},
    bare::NTuple{2,Union{SFD,DECIM}} = (zero(SFD), zero(SFD))) = begin
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

# Addition
+(x::STB, y::STB) = begin
    @assert(symb(x) == symb(y), "Can't add different tracking pair balances!")
    STB(x.cryp + y.cryp, x.fiat + y.fiat)
end

# Subtraction
"""
# InformalDAX's "tracked" subtraction of crypto assets

`-(x::STB, y::SUB)::Tuple{STB,STB}`\n
Tracked subtraction \$x - y\$ that returns a `(result, taken)` tuple, where `result` is the
resulting tracked subtraction, and `taken` is the tracked taken amount based on `y` (an
untracked balance), such that `taken.cryp == y`, and `taken.fiat` is adjusted to the proper
ratio of purchasing fiat currency.

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
-(x::STB, y::SUB)::Tuple{STB,STB} = begin
    @assert(symb(x)[1] == symb(y), "Can't sub different tracking pair balances!")
    dif = x.cryp - y                    # the difference
    r_d = bare(dif) / bare(x.cryp)      # the 0 <= difference ratio <= 1
    trk = r_d * x.fiat                  # the tracked remaining fiat
    RES = STB(dif, trk)                 # the tracked subtraction result
    TKN = STB(  y, x.fiat - trk)        # the tracked taken value
    return (RES, TKN)
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
    function MTB(x::STB)
        @assert(isFiat(x), "Missing Fiat:Fiat balance!")
        new(Dict(symb(x) => x))
    end
    function MTB(x::STB...)
        𝑐 = Set([symb(i)[1] for i in x])
        𝑓 = Set([symb(i)[2] for i in x])
        @assert(length([𝑓...]) == 1, "Multiple tracking fiats!")
        f = [𝑓...][1]
        @assert(f ∈ 𝑐, "Missing Fiat:Fiat balance!")
        new(Dict([symb(i) => i for i in x]))
    end
end

# export
export MTB

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
    # TODO: FIX: Work in copy!!
    if symb(y) in keys(x)
        x.Mult[symb(y)] += y
    else
        x.Mult[symb(y)] = y
    end
    return x
end

# Subtraction
-(x::MTB, y::SUB) = begin
    # TODO: FIX: Work in copy!!
    if (symb(y), fiat(x)) in keys(x) 
        x.Mult[(symb(y), fiat(x))], taken = x.Mult[(symb(y), fiat(x))] - y
    end
    return x, taken
end

# show/display
function Base.show(io::IO, ::MIME"text/plain", x::MTB)
    print(pretty(x))
end


#==================================================================================================#
#                         Rolling, Fiat-Tracking, Single-Currency Balance                          #
#==================================================================================================#

"""
`struct SingleFTBalance <: AbstractBalance`\n
Rolling, fiat-tracking, single-currency balance.
"""
struct SingleFTBalance <: AbstractBalance
    DAT::Pair{NTuple{2, Symbol}, NTuple{2, SFD}}
    # Inner (validating) constructors
    function SingleFTBalance(fia::Symbol)
        @assert(fia in Currencies.allsymbols(), "Invalid fiat: \"$(fia)\"")
        new((fia, fia) => (zero(SFD), zero(SFD)))
    end
    function SingleFTBalance(cur::Symbol, fia::Symbol)
        @assert(fia in Currencies.allsymbols(), "Invalid fiat: \"$(fia)\"")
        new((cur, fia) => (zero(SFD), zero(SFD)))
    end
    function SingleFTBalance(fia::Symbol, bal::DECIM)
        @assert(fia in Currencies.allsymbols(), "Invalid fiat: \"$(fia)\"")
        new((fia, fia) => (SFD(SFD(bal)), SFD(SFD(bal))))
    end
    function SingleFTBalance(cur::Symbol, fia::Symbol, bal::NTuple{2,DECIM})
        @assert(fia in Currencies.allsymbols(), "Invalid fiat: \"$(fia)\"")
        new((cur, fia) => (SFD(SFD(bal[1])), SFD(SFD(bal[2]))))
    end
end

# Outer constructors
function SingleFTBalance(dat::Pair{NTuple{2, Symbol}, NTuple{2, SFD}})
    SingleFTBalance(dat[1][1], dat[1][2], dat[2])
end
SingleFTBalance(that::SingleFTBalance) = SingleFTBalance(that.DAT)

# export
export SingleFTBalance

function Base.show(io::IO, ::MIME"text/plain", x::SingleFTBalance)
    if x.DAT[1][1] in Currencies.allsymbols()
        print(@sprintf("%20.*f %s ", Currencies.unit(x.DAT[1][1]), x.DAT[2][1], x.DAT[1][1]))
    else
        print(@sprintf("%20.10f %s ", x.DAT[2][1], x.DAT[1][1]))
    end
    print(@sprintf("(%20.*f %s)", Currencies.unit(x.DAT[1][2]), x.DAT[2][2], x.DAT[1][2]))
end

# Addition merges both CRYPTO and FIAT balances, thus, it
#  (i) preserves FIAT spent on the partial purchases
# (ii) most likely changes the effective exchange rate
function +(x::SingleFTBalance, y::SingleFTBalance)
    @assert(x.DAT[1] == y.DAT[1], "Can't add different currency pairs!")
    SingleFTBalance(
        x.DAT[1]...,
        (x.DAT[2][1] + y.DAT[2][1], x.DAT[2][2] + y.DAT[2][2])
    )
end

function +(x::SingleFTBalance, y::NTuple{2,DECIM})
    x + SingleFTBalance(x.DAT[1]..., y)
end

# Subtractions must ignore the subtracting operand's FIAT value, that is meaningless, thus, it
#  (i) must make additional checks;
# (ii) must preserve the first operand's FIAT-to-CRYPTO ratio!
function -(x::SingleFTBalance, y::SingleFTBalance)
    @assert(x.DAT[1][1] == y.DAT[1][1], "Can't sub different currencies!")
    @assert(x.DAT[2][1] >= y.DAT[2][1], "Can't take more than it has!")
    if x.DAT[2][1] == zero(SFD)
        return x
    else
        nwBal = x.DAT[2][1] - y.DAT[2][1]
        ratio = nwBal / x.DAT[2][1]
        return SingleFTBalance(
            x.DAT[1]...,
            (nwBal, ratio * x.DAT[2][2])
        )
    end
end

function -(x::SingleFTBalance, y::DECIM)
    x - SingleFTBalance(x.DAT[1]..., (y, x.DAT[2][2]))
end


#==================================================================================================#
#                          Rolling, Fiat-Tracking, Multi-Currency Balance                          #
#==================================================================================================#

"""
`struct MultiFTBalance <: AbstractBalance`\n
Rolling, fiat-tracking, multi-currency balance.
"""
struct MultiFTBalance <: AbstractBalance
    DAT::Dict{NTuple{2, Symbol}, NTuple{2, SFD}}
    # Inner (validating) constructors
    function MultiFTBalance(fia::Symbol)
        @assert(fia in Currencies.allsymbols(), "Invalid fiat: \"$(fia)\"")
        dat = Dict((fia, fia) => (zero(SFD), zero(SFD)))
        new(dat)
    end
    function MultiFTBalance(fia::Symbol, bal::DECIM)
        @assert(fia in Currencies.allsymbols(), "Invalid fiat: \"$(fia)\"")
        dat = Dict((fia, fia) => (SFD(SFD(bal)), SFD(SFD(bal))))
        new(dat)
    end
    function MultiFTBalance(cry::Symbol, fia::Symbol, crb::DECIM, fib::DECIM)
        @assert(!(cry in Currencies.allsymbols()), "Invalid crypto: \"$(cry)\"")
        @assert(  fia in Currencies.allsymbols(),  "Invalid fiat: \"$(fia)\"")
        dat = Dict((cry, fia) => (SFD(SFD(crb)), SFD(SFD(fib))))
        new(dat)
    end
    function MultiFTBalance(dat::Dict{NTuple{2, Symbol}, NTuple{2, SFD}})
        tSet = Set([ 𝑘[2] for 𝑘 in keys(dat) ])
        @assert(length(tSet) == 1, "Multiple tracking fiats!")
        tFia = [tSet...][1]
        @assert(tFia in Currencies.allsymbols(), "Invalid fiat: \"$(tFia)\"")
        cSet = Set([ 𝑘[1] for 𝑘 in keys(dat) if 𝑘[1] != 𝑘[2] ])
        for cry in cSet
            @assert(!(cry in Currencies.allsymbols()), "Invalid crypto: \"$(cry)\"")
        end
        for 𝑘 in keys(dat)
            # More implied assertions
            dat[𝑘] = Tuple([ SFD(SFD(i)) for i in dat[𝑘] ])
        end
        new(dat)
    end
    # SingleFTBalance-based constructors
    function MultiFTBalance(sgl::SingleFTBalance)
        new(Dict(sgl.DAT))
    end
    function MultiFTBalance(sgl::SingleFTBalance...)
        𝑝 = [ i.DAT for i in sgl ]
        𝑘 = [ i[1] for i in 𝑝 ]
        @assert(length(𝑘) == length(Set(𝑘)), "Repeated keys for constructor!")
        𝑓 = [ i[2] for i in 𝑘 ]
        @assert(length(Set(𝑓)) == 1, "Multiple tracking fiats!")
        new(Dict(𝑝))
    end
    # Mixed-type arguments
    function MultiFTBalance(mul::MultiFTBalance)
        new(mul.DAT)
    end
    function MultiFTBalance(mul::MultiFTBalance, sgl::SingleFTBalance)
        @assert(!(sgl.DAT[1] in keys(mul.DAT)), "Repeated keys for constructor!")
        𝑓 = [ i[2] for i in vcat(keys(mul.DAT)..., sgl.DAT[1]) ]
        @assert(length(Set(𝑓)) == 1, "Multiple tracking fiats!")
        new(Dict([mul.DAT..., sgl.DAT]))
    end
    function MultiFTBalance(mul::MultiFTBalance, sgl::SingleFTBalance...)
        𝑝 = vcat(mul.DAT..., [ i.DAT for i in sgl ]...)
        𝑘 = [ i[1] for i in 𝑝 ]
        @assert(length(𝑘) == length(Set(𝑘)), "Repeated keys for constructor!")
        𝑓 = [ i[2] for i in 𝑘 ]
        @assert(length(Set(𝑓)) == 1, "Multiple tracking fiats!")
        new(Dict(𝑝))
    end
end

# export
export MultiFTBalance

function Base.show(io::IO, ::MIME"text/plain", x::MultiFTBalance)
    𝑘 = sort([ keys(x.DAT)... ])
    𝑙 = length(𝑘)
    for i in 1:𝑙
        Base.show(io, "text/plain", SingleFTBalance(𝑘[i] => x.DAT[𝑘[i]]))
        if i < 𝑙; print("\n"); end
    end
end


#--------------------------------------------------------------------------------------------------#
#                                     MultiFTBalance Functions                                     #
#--------------------------------------------------------------------------------------------------#

function +(x::MultiFTBalance, y::SingleFTBalance)
    𝑘 = y.DAT[1]
    if 𝑘 in keys(x.DAT)
        singles = [ SingleFTBalance(i) for i in x.DAT ]
        for i in 1:length(singles)
            if 𝑘 == singles[i].DAT[1]
                singles[i] += y
                break
            end
        end
        MultiFTBalance(singles...)
    else
        MultiFTBalance(x, y)
    end
end

+(y::SingleFTBalance, x::MultiFTBalance) = +(x, y)

function +(x::MultiFTBalance, y::MultiFTBalance)
    reduce(+, vcat(x, [SingleFTBalance(i) for i in y.DAT]...))
end

function -(x::MultiFTBalance, y::SingleFTBalance)
    𝑘 = y.DAT[1]
    @assert(𝑘 in keys(x.DAT), "Can't sub different currencies!")
    singles = [ SingleFTBalance(i) for i in x.DAT ]
    for i in 1:length(singles)
        if 𝑘 == singles[i].DAT[1]
            singles[i] -= y
            break
        end
    end
    MultiFTBalance(singles...)
end

-(y::SingleFTBalance, x::MultiFTBalance) = begin
    @assert(length(keys(x.DAT)) == 1, "Can't sub different currencies!")
    @assert(y.DAT[1] in keys(x.DAT), "Can't sub different currencies!")
    𝑥 = [ SingleFTBalance(i) for i in x.DAT ][1]
    y - 𝑥
end

function -(x::MultiFTBalance, y::MultiFTBalance)
    reduce(-, vcat(x, [SingleFTBalance(i) for i in y.DAT]...))
end


