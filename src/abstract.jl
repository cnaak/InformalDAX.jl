# Top-Level Informal_DAX supertype
# -------------------------------

"""
`abstract type Informal_DAX <: Any end`\n
Top-level Informal_DAX supertype.
"""
abstract type Informal_DAX <: Any end


# Second-level abstract types
# ---------------------------

"""
`abstract type AbstractStatement <: Informal_DAX end`\n
Second-level Statement abstract supertype.
"""
abstract type AbstractStatement <: Informal_DAX end

"""
`abstract type AbstractOperation <: Informal_DAX end`\n
Second-level Operation abstract supertype.
"""
abstract type AbstractOperation <: Informal_DAX end

"""
`abstract type AbstractBalance <: Informal_DAX end`\n
Second-level Balance abstract supertype.
"""
abstract type AbstractBalance <: Informal_DAX end


# Third-level abstract types
# --------------------------

"""
`abstract type AbstractStatementLine <: AbstractStatement end`\n
Third-level StatementLine abstract supertype.
"""
abstract type AbstractStatementLine <: AbstractStatement end


