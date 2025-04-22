import Base: show

#--------------------------------------------------------------------------------------------------#
#                                 Rolling, Multi-Currency Balance                                  #
#--------------------------------------------------------------------------------------------------#

struct MultiBalance <: AbstractMultiBalance
    BAL::Dict{Symbol,Tuple{}}
end

