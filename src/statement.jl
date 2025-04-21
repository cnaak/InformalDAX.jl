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
        if length(s) == 6
            HistoryTradesWsData, \
            TransactionType, \
            TransactionCoin, \
            TransactionAmount \
            TransactionOutcome = s[1], s[2], s[3], join(s[4:5], ','), s[6]
        elseif length(s) == 5
            HistoryTradesWsData, \
            TransactionType, \
            TransactionCoin, \
            TransactionAmount \
            TransactionOutcome = s
        end
    end
end

