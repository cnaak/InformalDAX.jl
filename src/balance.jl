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
#                                        Minimal Currencies                                        #
#--------------------------------------------------------------------------------------------------#


const validFiats = (:BRL, :USD, :EUR)

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
    function SingleBalance(cur::Symbol)
        new(cur => (zero(UFD), zero(UFD)), fia)
    end
    function SingleBalance(
        cur::Symbol,
        bal::NTuple{2, Union{UFD,SFD,Rational{<:Unsigned},Rational{<:Signed}}},
        fia::Bool = false)
        new(cur => (UFD(SFD(bal[1])), UFD(SFD(bal[2]))), fia)
    end
end

# Outer constructors
SingleBalance(that::SingleBalance) = SingleBalance(that.BAL, that.FIA)

export SingleBalance

function Base.show(io::IO, ::MIME"text/plain", x::SingleBalance)
    WBOLD = Crayon(foreground = :white, bold = true, background = :dark_gray)
    FAINT = Crayon(foreground = :light_gray, bold = false, background = :default)
    RESET = Crayon(reset = true)
    print(WBOLD, string(x.BAL[1]) * ":")
    if x.FIA
        print(FAINT, @sprintf(" %20.2f (%20.2f %s)",  x.BAL[2][1]))
    else
        print(FAINT, @sprintf(" %20.10f", x.BAL[2]), RESET)
    end
end

+(this::SingleBalance, that::Tuple{UFD,UFD}) = this[1] + that[1], this[2] + that[2]

function -(this::Tuple{UFD,UFD}, that::UFD)
    @assert(this[1] >= that, "Can't take more that one has!")
    ret = this[1] - that
    rat = ret / this[1]
    return ret, UFD(rat * this[2])
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



