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

export UFD, SFD


#--------------------------------------------------------------------------------------------------#
#                                Auxiliar, Single-Currency Balance                                 #
#--------------------------------------------------------------------------------------------------#

"""
`struct SingleBalance <: AbstractBalance`\n
Rolling, single-currency balance.
"""
struct SingleBalance <: AbstractBalance
    BAL::Pair{NTuple{2, Symbol}, NTuple{2, UFD}}
    # Inner (validating) constructors
    function SingleBalance(cur::Symbol, fia::Symbol)
        @assert(fia in Currencies.allsymbols(), "Invalid fiat: \"$(fia)\"")
        new((cur, fia) => (zero(UFD), zero(UFD)))
    end
    function SingleBalance(
        cur::Symbol, fia::Symbol
        bal::NTuple{2, Union{UFD,SFD,Rational{<:Unsigned},Rational{<:Signed}}})
        @assert(fia in Currencies.allsymbols(), "Invalid fiat: \"$(fia)\"")
        new((cur, fia) => (UFD(SFD(bal[1])), UFD(SFD(bal[2]))))
    end
end

# Outer constructors
SingleBalance(that::SingleBalance) = SingleBalance(that.BAL[1][1], that.BAL[1][2], that.BAL[2])

export SingleBalance

function Base.show(io::IO, ::MIME"text/plain", x::SingleBalance)
    if x.BAL[1][1] in Currencies.allsymbols()
        print(@sprintf("%20.2f %s (%20.2f %s)",  x.BAL[2][1], x.BAL[1][1], x.BAL[2][2], x.BAL[1][2]))
    else
        print(@sprintf("%20.10f %s (%20.2f %s)", x.BAL[2][1], x.BAL[1][1], x.BAL[2][2], x.BAL[1][2]))
    end
end

# Addition merges both CRYPTO and FIAT balances, thus, it
#  (i) preserves FIAT spent on the partial purchases
# (ii) most likely changes the effective exchange rate
function +(x::SingleBalance, y::SingleBalance)
    @assert(x.BAL[1] == y.BAL[1], "Can't add different currency pairs!")
    SingleBalance(
        x.BAL[1]...,
        (x.BAL[2][1] + y.BAL[2][1], x.BAL[2][2] + y.BAL[2][2])
    )
end

# Subtractions must ignore the subtracting operand's FIAT value, that is meaningless, thus, it
#  (i) must make additional checks;
# (ii) must preserve the first operand's FIAT-to-CRYPTO ratio!
function -(x::SingleBalance, y::SingleBalance)
    @assert(x.BAL[1][1] == y.BAL[1][1], "Can't sub different currencies!")
    @assert(x.BAL[2][1] >= y.BAL[2][1], "Can't take more than it has!")
    nwBal = x.BAL[2][1] - y.BAL[2][1]
    ratio = nwBAL / x.BAL[2][1]
    SingleBalance(
        x.BAL[1]...,
        (nwBal, ratio * x.BAL[2][2])
    )
end

function -(x::SingleBalance, y::Union{UFD,SFD,Rational{<:Unsigned},Rational{<:Signed}})
    x - SingleBalance( x.BAL[1]..., (y, Zero(UFD)) )
end


#--------------------------------------------------------------------------------------------------#
#                                 Rolling, Multi-Currency Balance                                  #
#--------------------------------------------------------------------------------------------------#

"""
`struct MultiBalance <: AbstractMultiBalance`\n
Rolling, multi-currency balance.
"""
struct MultiBalance <: AbstractMultiBalance
    REF::Symbol
    BAL::Dict{Symbol,Tuple{UFD, UFD}}
    function MultiBalance(ref::Symbol)
        new(ref, Dict{Symbol,Tuple{UFD, UFD}}(ref => (zero(UFD), zero(UFD))))
    end
    function MultiBalance(ref::Symbol, iBAL::Tuple{UFD, UFD})
        for indx in 1:2
            @assert(iBAL[indx] < typemax(FixedDecimal{Int64,10}), "Overflow")
        end
        new(ref, Dict(ref => iBAL))
    end
    function MultiBalance(ref::Symbol, iBAL::Dict{Symbol,Tuple{UFD, UFD}})
        @assert(ref in keys(iBAL), "Orphaned reference currency!")
        for CUR in keys(iBAL)
            for indx in 1:2
                @assert(iBAL[CUR][indx] < typemax(FixedDecimal{Int64,10}), "Overflow")
            end
        end
        new(ref, iBAL)
    end
end

MultiBalance(that::MultiBalance) = MultiBalance(that.REF, that.BAL)

export MultiBalance

function Base.show(io::IO, ::MIME"text/plain", mb::MultiBalance)
    WBOLD = Crayon(foreground = :white, bold = true, background = :dark_gray)
    FAINT = Crayon(foreground = :light_gray, bold = false, background = :default)
    RESET = Crayon(reset = true)
    for CUR in keys(mb.BAL)
        print(WBOLD, string(CUR) * ":")
        if CUR == mb.REF
            print(FAINT, @sprintf(" %20.2f %s", mb.BAL[CUR][1], string(CUR)))
        else
            print(FAINT, @sprintf(" %20.10f %s", mb.BAL[CUR][1], string(CUR)))
        end
        print(@sprintf(" (%12.2f %s)", mb.BAL[CUR][2], string(mb.REF)), RESET)
    end
end


#--------------------------------------------------------------------------------------------------#
#                                      MultiBalance Functions                                      #
#--------------------------------------------------------------------------------------------------#

#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#
#                                            Primitives                                            #
#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#

#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#
#                                        MultiBalance-Level                                        #
#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#

"""
`hasSameRef(x::MultiBalance, y::MultiBalance)::Bool`\n
Tests whether `x` and `y` `MultiBalance` have the same reference, i.e., the same `.REF` data member.\n
For `MultiBalance`s, the `.REF` data member is meant to be a reference FIAT currency. Usually `:BRL`.
Every balance for every coin type is simultaneously tracked for its equivalent `.REF` (average purchase
price); which is different, in general, than it's current market value.
"""
hasSameRef(x::MultiBalance, y::MultiBalance) = x.REF == y.REF

"""
"""
function +(x::MultiBalance, y::Pair{Symbol,Tuple{UFD, UFD}})



