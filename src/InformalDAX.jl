#--------------------------------------------------------------------------------------------------#
#                          InformalDAX.jl - Top-level InformalDAX Module                           #
#--------------------------------------------------------------------------------------------------#

# Module
module InformalDAX

# Imports
using Printf
using FixedPointDecimals
using Currencies
using Dates

# Includes - abstract supertypes
include("abstract.jl")

# finance numerical types
include("finance.jl")

# statement utils
include("statement.jl")

# rolling, fiat-tracking single/multi-currency balances
include("balances.jl")

# Operations
include("operations.jl")

# User functions
# include("user.jl")

# Module
end
