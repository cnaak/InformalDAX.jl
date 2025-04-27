#--------------------------------------------------------------------------------------------------#
#                             abstract.jl - InformalDAX type hyerarchy                             #
#--------------------------------------------------------------------------------------------------#

#--------------------------------------------------------------------------------------------------#
#                                 Top-Level InformlDAX supertype                                 #
#--------------------------------------------------------------------------------------------------#

"""
`abstract type InformlDAX <: Any end`\n
Top-level InformlDAX supertype.
"""
abstract type InformlDAX <: Any end

# export
export InformlDAX


#--------------------------------------------------------------------------------------------------#
#                                   Second-level abstract types                                    #
#--------------------------------------------------------------------------------------------------#

"""
`abstract type AbstractST <: InformlDAX end`\n
Second-level Statement abstract supertype.
"""
abstract type AbstractST <: InformlDAX end

"""
`abstract type AbstractOP <: InformlDAX end`\n
Second-level Operation abstract supertype.
"""
abstract type AbstractOP <: InformlDAX end

"""
`abstract type AbstractBL <: InformlDAX end`\n
Second-level Balance abstract supertype.
"""
abstract type AbstractBL <: InformlDAX end

# export
export AbstractST, AbstractOP, AbstractBL


#--------------------------------------------------------------------------------------------------#
#                         Third-level abstract types <: AbstractST                          #
#--------------------------------------------------------------------------------------------------#

"""
`abstract type AbstractSTLn <: AbstractST end`\n
Third-level StatementLine abstract supertype.
"""
abstract type AbstractSTLn <: AbstractST end

# export
export AbstractSTLn


#--------------------------------------------------------------------------------------------------#
#                         Third+ -level abstract types <: AbstractBL                          #
#--------------------------------------------------------------------------------------------------#

"""
`abstract type Untrakd <: AbstractBL end`\n
Untracked single balances
"""
abstract type Untrakd <: AbstractBL end

"""
`abstract type Tracked <: AbstractBL end`\n
Fiat-Tracked balances.
"""
abstract type Tracked <: AbstractBL end

"""
`abstract type UniTracked <: Tracked end`\n
Fiat-Tracked, single balance.
"""
abstract type UniTracked <: Tracked end

"""
`abstract type MulTracked <: Tracked end`\n
Fiat-Tracked, multi balance.
"""
abstract type MulTracked <: Tracked end

# export
export Untrakd, Tracked, UniTracked, MulTracked


