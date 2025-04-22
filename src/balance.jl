#==================================================================================================#
#                                      FIAT-Tracking Balances                                      #
#==================================================================================================#

import Base: show, +, -


#--------------------------------------------------------------------------------------------------#
#                                  FixedPoint number for finances                                  #
#--------------------------------------------------------------------------------------------------#


SFD =  FixedDecimal{Int64,10}   # from -922337203.6854775808
                                # upto          0.0000000000
                                # upto          0.0000000001
                                # upto  922337203.6854775807

UFD = FixedDecimal{UInt64,10}   # from          0.0000000000
                                # upto          0.0000000001
                                # upto  922337203.6854775807
                                # upto 1844674407.3709551615 (not meant to be used for compat)

INPUTS = Union{UFD, SFD, Rational, Integer}

export UFD, SFD, INPUTS


#==================================================================================================#
#                         Rolling, Fiat-Tracking, Single-Currency Balance                          #
#==================================================================================================#

"""
`struct SingleFTBalance <: AbstractBalance`\n
Rolling, fiat-tracking, single-currency balance.
"""
struct SingleFTBalance <: AbstractBalance
    DAT::Pair{NTuple{2, Symbol}, NTuple{2, UFD}}
    # Inner (validating) constructors
    function SingleFTBalance(fia::Symbol)
        @assert(fia in Currencies.allsymbols(), "Invalid fiat: \"$(fia)\"")
        new((fia, fia) => (zero(UFD), zero(UFD)))
    end
    function SingleFTBalance(cur::Symbol, fia::Symbol)
        @assert(fia in Currencies.allsymbols(), "Invalid fiat: \"$(fia)\"")
        new((cur, fia) => (zero(UFD), zero(UFD)))
    end
    function SingleFTBalance(fia::Symbol, bal::INPUTS)
        @assert(fia in Currencies.allsymbols(), "Invalid fiat: \"$(fia)\"")
        new((fia, fia) => (UFD(SFD(bal)), UFD(SFD(bal))))
    end
    function SingleFTBalance(cur::Symbol, fia::Symbol, bal::NTuple{2,INPUTS})
        @assert(fia in Currencies.allsymbols(), "Invalid fiat: \"$(fia)\"")
        new((cur, fia) => (UFD(SFD(bal[1])), UFD(SFD(bal[2]))))
    end
end

# Outer constructors
function SingleFTBalance(dat::Pair{NTuple{2, Symbol}, NTuple{2, UFD}})
    SingleFTBalance(dat[1][1], dat[1][2], dat[2])
end
SingleFTBalance(that::SingleFTBalance) = SingleFTBalance(that.DAT)

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

function +(x::SingleFTBalance, y::NTuple{2,INPUTS})
    x + SingleFTBalance(x.DAT[1]..., y)
end

# Subtractions must ignore the subtracting operand's FIAT value, that is meaningless, thus, it
#  (i) must make additional checks;
# (ii) must preserve the first operand's FIAT-to-CRYPTO ratio!
function -(x::SingleFTBalance, y::SingleFTBalance)
    @assert(x.DAT[1][1] == y.DAT[1][1], "Can't sub different currencies!")
    @assert(x.DAT[2][1] >= y.DAT[2][1], "Can't take more than it has!")
    nwBal = x.DAT[2][1] - y.DAT[2][1]
    ratio = nwBal / x.DAT[2][1]
    SingleFTBalance(
        x.DAT[1]...,
        (nwBal, ratio * x.DAT[2][2])
    )
end

function -(x::SingleFTBalance, y::INPUTS)
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
    DAT::Dict{NTuple{2, Symbol}, NTuple{2, UFD}}
    # Inner (validating) constructors
    function MultiFTBalance(fia::Symbol)
        @assert(fia in Currencies.allsymbols(), "Invalid fiat: \"$(fia)\"")
        dat = Dict((fia, fia) => (zero(UFD), zero(UFD)))
        new(dat)
    end
    function MultiFTBalance(fia::Symbol, bal::INPUTS)
        @assert(fia in Currencies.allsymbols(), "Invalid fiat: \"$(fia)\"")
        dat = Dict((fia, fia) => (UFD(SFD(bal)), UFD(SFD(bal))))
        new(dat)
    end
    function MultiFTBalance(dat::Dict{NTuple{2, Symbol}, NTuple{2, UFD}})
        tSet = Set([ 𝑘[2] for 𝑘 in keys(dat) ])
        @assert(length(tSet) == 1, "Multiple tracking fiats!")
        tFia = [tSet...][1]
        @assert(tFia in Currencies.allsymbols(), "Invalid fiat: \"$(tFia)\"")
        for 𝑘 in keys(dat)
            # More implied assertions
            dat[𝑘] = Tuple([ UFD(SFD(i)) for i in dat[𝑘] ])
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

export MultiFTBalance

function Base.show(io::IO, ::MIME"text/plain", x::MultiFTBalance)
    for i in sort([ keys(x.DAT)... ])
        Base.show(io, "text/plain", SingleFTBalance(i => x.DAT[i]))
        print("\n")
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




