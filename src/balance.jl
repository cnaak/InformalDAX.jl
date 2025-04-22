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

struct MultiBalance <: AbstractMultiBalance
    REF::Symbol
    BAL::Dict{Symbol,Tuple{SFD, SFD}}
    function MultiBalance(ref::Symbol)
        new(ref, Dict{Symbol,Tuple{SFD, SFD}}(ref => (zero(SFD), zero(SFD))))
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


