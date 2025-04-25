#--------------------------------------------------------------------------------------------------#
#         balances.jl - crypto assets balances with fiat/on-ramp tracking (purchase price)         #
#--------------------------------------------------------------------------------------------------#

import Base: show, +, -, *


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
    SUB(CUR::Symbol, BAL::SFD = zero(SFD)) = new(CUR, BAL)
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
decs(x::SUB) = isFiat(x) ? Currencies.unit(x.cur) : 10

# Returns true if x.cur is a fiat currency
isFiat(x::SUB) = x.cur in Currencies.allsymbols()

# Returns true if x.cur is not a fiat currency
isCryp(x::SUB) = !isFiat(x)

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

# show/display
function Base.show(io::IO, ::MIME"text/plain", x::SUB)
    print(@sprintf("%+21.*f %6s", decs(x), bare(x), name(x)))
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
        @assert((bare(CRYP) != zero(SFD)) && (bare(FIAT) != zero(SFD)),
                "Exchange ratio must be finite!")
        new(CRYP, FIAT)
    end
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

# Addition
+(x::STB, y::STB) = begin
    @assert(symb(x) == symb(y), "Can't add different tracking pair balances!")
    return STB(x.cryp + y.cryp, x.fiat + y.fiat)
end

# Subtraction
-(x::STB, y::SUB) = begin
    @assert(symb(x)[1] == symb(y), "Can't sub different tracking pair balances!")
    @assert(bare(x)[1] >= bare(y), "Can't take more than it has with tracking!")
    diff = x.cryp - y
    rati = bare(diff) / bare(x.cryp)[1]
    rcmp = one(SFD) - rati
    resu = STB(diff, rati * x.fiat)
    takn = STB(   y, rcmp * x.fiat)
    return (resu, takn)
end

# show/display
function Base.show(io::IO, ::MIME"text/plain", x::STB)
    display(x.cryp)
    display(x.fiat)
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


