#--------------------------------------------------------------------------------------------------#
#                          InformalDAX.jl - Top-level InformalDAX Module                           #
#--------------------------------------------------------------------------------------------------#

# Module
module InformalDAX

# Imports
using Reexport
@reexport using Printf
@reexport using FixedPointDecimals
@reexport using Dates
using Currencies

# Includes - abstract supertypes
include("abstract.jl")

# finance numerical types
include("finance.jl")

# rolling, fiat-tracking single/multi-currency balances
include("balances.jl")

# statement utils
include("statement.jl")

# Operations
include("operations.jl")

# User functions
# include("user.jl")

# Module
end
