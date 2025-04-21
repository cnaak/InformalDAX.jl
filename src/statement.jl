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
        s = split(RawStatementLine, ',')
        return length(s) == 6 ?
            new(s[1], s[2], s[3], join(s[4:5], ','), s[6]) :
            new(s...)
    end
end

export GenericStatementLine

