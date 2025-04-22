import Base: show

#--------------------------------------------------------------------------------------------------#
#                                  FixedPoint number for finances                                  #
#--------------------------------------------------------------------------------------------------#


UFD = FixedDecimal{UInt64,10} # from          0.0000000000 to 0.0000000001 upto 1844674407.3709551615
SFD = FixedDecimal{ Int64,10} # from -922337203.6854775808 to 0.0000000001 upto  922337203.6854775807

export UFD, SFD

#--------------------------------------------------------------------------------------------------#
#                                 Rolling, Multi-Currency Balance                                  #
#--------------------------------------------------------------------------------------------------#

"""
`struct MultiBalance <: AbstractMultiBalance`\n
Rolling, multi-currency balance.
"""
struct MultiBalance <: AbstractMultiBalance
    REF::Symbol
    BAL::Dict{Symbol,Tuple{SFD, SFD}}
    function MultiBalance(ref::Symbol)
        new(ref, Dict{Symbol,Tuple{SFD, SFD}}(ref => (zero(SFD), zero(SFD))))
    end
    function MultiBalance(ref::Symbol, iBAL::Tuple{SFD, SFD})
        @assert(iBAL[1] >= zero(SFD), "Negative balances are prohibited!")
        @assert(iBAL[2] >= zero(SFD), "Negative balances are prohibited!")
        new(ref, Dict{Symbol,Tuple{SFD, SFD}}(ref => iBAL))
    end
    function MultiBalance(ref::Symbol, iBAL::Dict{Symbol,Tuple{SFD, SFD}})
        for CUR in keys(iBAL)
            @assert(iBAL[CUR][1] >= zero(SFD), "Negative balances are prohibited!")
            @assert(iBAL[CUR][2] >= zero(SFD), "Negative balances are prohibited!")
        end
        new(ref, Dict{Symbol,Tuple{SFD, SFD}}(ref => iBAL))
    end
end

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

import Base: +, -

"""
``\n
"""
function Base.+(this::Tuple{SFD,SFD}, that::Tuple{SFD,SFD})
    for item in (this, that)
        for indx in (1, 2)
            @assert(item[indx] >= zero(SFD), "Negative amounts are prohibited on Tuple{SFD,SFD}!")
        end
    end
end


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
function +(x::MultiBalance, y::Pair{Symbol,Tuple{SFD, SFD}})



