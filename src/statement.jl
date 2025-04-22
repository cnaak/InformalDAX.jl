import Base: show

"""
`struct GenericStatementLine <: AbstractStatementLine`\n
A data structure representing a generic (any operation type) statement line.
"""
struct GenericStatementLine <: AbstractStatementLine
    HistoryTradesWsData::String
    TransactionType::String
    TransactionCoin::String
    TransactionAmount::String
    TransactionOutcome::String
    GenericStatementLine(RawStatementLine::String) = begin
        noCGr(lab::String) = raw"(?<" * lab * raw">[^,]+)"
        noQGr(lab::String) = raw""""?(?<""" * lab * raw""">[^"]+)"?"""
        tmp = join([noCGr("dat"), noCGr("typ"), noCGr("coi"), noQGr("amt"), noCGr("out")], ",")
        rex = Regex(join(["^", tmp, "\$"]))
        m = match(rex, RawStatementLine)
        new(m[:dat], m[:typ], m[:coi], m[:amt], m[:out])
    end
end

export GenericStatementLine

function Base.show(io::IO, ::MIME"text/plain", gl::GenericStatementLine)
    msg = join([
        @sprintf("Date: %20s, ", gl.HistoryTradesWsData),
        @sprintf("Type: %22s, ", gl.TransactionType),
        @sprintf("Coin: %10s, ", gl.TransactionCoin),
        @sprintf("Amnt: %24s, ", gl.TransactionAmount),
        @sprintf("Outc: %08s.", gl.TransactionOutcome),
    ])
    print(io, msg)
end

