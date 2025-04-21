# Top-Level InformalDAX supertype
# -------------------------------

"""
`abstract type InformalDAX <: Any end`\n
Top-level InformalDAX supertype.
"""
abstract type InformalDAX <: Any end


# Second-level abstract types
# ---------------------------

"""
`abstract type AbstractStatement <: InformalDAX end`\n
Second-level Statement abstract supertype.
"""
abstract type AbstractStatement <: InformalDAX end

"""
`abstract type AbstractOperation <: InformalDAX end`\n
Second-level Operation abstract supertype.
"""
abstract type AbstractOperation <: InformalDAX end

"""
`abstract type AbstractMultiBalance <: InformalDAX end`\n
Second-level MultiBalance abstract supertype.
"""
abstract type AbstractMultiBalance <: InformalDAX end


# Third-level abstract types
# --------------------------

"""
`abstract type AbstractStatementLine <: AbstractStatement end`\n
Third-level StatementLine abstract supertype.
"""
abstract type AbstractStatementLine <: AbstractStatement end


