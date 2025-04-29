#--------------------------------------------------------------------------------------------------#
#                      operations.jl - balance-changing statement operations                       #
#--------------------------------------------------------------------------------------------------#

# RFB's fiat currency
RFBFiat = :BRL

# export
export RFBFiat

# Empty balance initializer with :BRL as tracking fiat
emptyRFB() = MTB(STB((RFBFiat, RFBFiat)))

# export
export emptyRFB


#--------------------------------------------------------------------------------------------------#
#                                 Operation Functions and Objects                                  #
#--------------------------------------------------------------------------------------------------#


#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#
#                                            AbstractOP                                            #
#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#

# Isless
isless(x::𝕆, y::ℙ) where {𝕆 <: AbstractOP, ℙ <: AbstractOP} = isless(x.date, y.date)


#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#
#                                           𝒐𝒑Ini object                                           #
#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#

"""
`struct 𝒐𝒑Ini <: AbstractOP`\n
Initialization operation object, that can be used as a functor for balance initializations.

Suppose at the very beginning, one opens a NovaDAX account (and therefore it's statement) with
empty balance (the default) when having 3000 fiat units in a "BANK". This scenario can be setup
as follows:

```julia
julia> using InformalDAX

julia> a = SUB(:BRL, 3000)
     +3000.00 BRL

julia> A = MTB(STB(a, a))
     +3000.0000000000    BRL (     +3000.00 BRL)

julia> NDAX, BANK = [𝒐𝒑Ini()(), 𝒐𝒑Ini(A)()]
2-element Vector{MTB}:
         +0.0000000000    BRL (        +0.00 BRL)
      +3000.0000000000    BRL (     +3000.00 BRL)
```
"""
struct 𝒐𝒑Ini <: AbstractOP
    prev::MTB
    date::DateTime
    𝒐𝒑Ini(prev::MTB = emptyRFB(); date::DateTime = now()) = new(prev, date)
end

# Functor with functionality
function (x::𝒐𝒑Ini)()::MTB
    return MTB(x.prev())
end

# Addition
+(x::𝒐𝒑Ini, y::𝒐𝒑Ini) = 𝒐𝒑Ini(x.prev + y.prev; date = x.date < y.date ? x.date : y.date)

# show/display
function Base.show(io::IO, ::MIME"text/plain", x::𝒐𝒑Ini)
    println("Balance Initialization Operation with")
    println("   - Earliest order date ..: ", x.date)
    println("   - Previous balance .....: ", pretty(x.prev))
end

# export
export 𝒐𝒑Ini


#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#
#                                           𝒐𝒑Dep object                                           #
#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#

"""
`struct 𝒐𝒑Dep <: AbstractOP`\n
Deposit operation object, that can be used as a functor for fiat deposits:

Suppose `NDAX` and `BANK` hold the tracked balances of one's NovaDAX and "BANK" accounts, like so:

```julia
julia> NDAX, BANK = [𝒐𝒑Ini()(), 𝒐𝒑Ini(A)()]
2-element Vector{MTB}:
         +0.0000000000    BRL (        +0.00 BRL)
      +3000.0000000000    BRL (     +3000.00 BRL)
```

A deposit object in the amount of 1200 BRL can be created and execute the transaction as follows:

```julia
julia> NDAX, BANK = [𝒐𝒑Dep(SUB(:BRL, 1200))(NDAX, BANK)...]
2-element Vector{MTB}:
      +1200.0000000000    BRL (     +1200.00 BRL)
      +1800.0000000000    BRL (     +1800.00 BRL)
```

So that balances update to 1200 BRL and 1800 BRL, respectively.
"""
struct 𝒐𝒑Dep <: AbstractOP
    amt::SUB
    date::DateTime
    𝒐𝒑Dep(amt::SUB; date::DateTime = now()) = begin
        @assert(isFiat(amt), "Deposit operations must, by definition, be in fiat currency!")
        new(amt, date)
    end
end

# Functor with functionality
function (x::𝒐𝒑Dep)(sBal::MTB, oBal::Union{MTB,Nothing} = nothing)::NTuple{2,MTB}
    dBal = STB(x.amt, x.amt)
    if oBal isa Nothing
        return sBal + dBal, MTB(dBal)
    else
        return sBal + dBal, (oBal - x.amt)[1]
    end
end

# Addition
+(x::𝒐𝒑Dep, y::𝒐𝒑Dep) = 𝒐𝒑Dep(x.amt + y.amt; date = x.date < y.date ? x.date : y.date)

# show/display
function Base.show(io::IO, ::MIME"text/plain", x::𝒐𝒑Dep)
    println("Fiat Deposit Operation with")
    println("   - Earliest order date ..: ", x.date)
    println("   - Deposit amount .......: ", pretty(x.amt))
end

# export
export 𝒐𝒑Dep


#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#
#                                          𝒐𝒑Draw object                                           #
#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#

"""
`struct 𝒐𝒑Draw <: AbstractOP`\n
Draw (Withdraw) operation object, that can be used as a functor for fiat withdrawals:

Suppose `NDAX` and `BANK` hold the tracked balances of one's NovaDAX and "BANK" accounts, like so:

```julia
julia> NDAX, BANK
2-element Vector{MTB}:
      +1200.0000000000    BRL (     +1200.00 BRL)
      +1800.0000000000    BRL (     +1800.00 BRL)
```

A withdraw object in the amount of 1200 BRL can be created and execute the transaction as follows:

```julia
julia> NDAX, BANK = [𝒐𝒑Draw(SUB(:BRL, 1200))(NDAX, BANK)...]
2-element Vector{MTB}:
         +0.0000000000    BRL (        +0.00 BRL)
      +3000.0000000000    BRL (     +3000.00 BRL)
```

So that balances update to 0 BRL and 3000 BRL, respectively.
"""
struct 𝒐𝒑Draw <: AbstractOP
    amt::SUB
    date::DateTime
    𝒐𝒑Draw(amt::SUB; date::DateTime = now()) = begin
        @assert(isFiat(amt), "Draw operations must, by definition, be in fiat currency!")
        new(amt, date)
    end
end

# Functor with fuctionality
function (x::𝒐𝒑Draw)(sBal::MTB, oBal::Union{MTB,Nothing} = nothing)::NTuple{2,MTB}
    a, b = sBal - x.amt
    if oBal isa Nothing
        return a, MTB(b)
    else
        return a, oBal + b
    end
end

# Addition
+(x::𝒐𝒑Draw, y::𝒐𝒑Draw) = 𝒐𝒑Draw(x.amt + y.amt; date = x.date < y.date ? x.date : y.date)

# show/display
function Base.show(io::IO, ::MIME"text/plain", x::𝒐𝒑Draw)
    println("Fiat Withdraw Operation with")
    println("   - Earliest order date ..: ", x.date)
    println("   - Withdrawal amount ....: ", pretty(x.amt))
end

# export
export 𝒐𝒑Draw


#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#
#                                           𝒐𝒑Buy object                                           #
#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#

"""
`struct 𝒐𝒑Buy <: AbstractOP`\n
Buy operation object, that can be used as a functor for crypto purchases:

Suppose `NDAX` holds the following balance in one's account:

```julia
julia> NDAX
      +1200.0000000000    BRL (     +1200.00 BRL)
```

One then purchases 0.05 ETH by paying 500 BRL, with a 0.005 ETH fee. This transaction can be
executed as follows, as to update one's `NDAX` balance to:

```julia
julia> NDAX = 𝒐𝒑Buy(SUB(:BRL, 500), SUB(:ETH, 5//100), SUB(:ETH, 5//1000), SUB(:BRL, 0))(NDAX)
      +700.0000000000    BRL (      +700.00 BRL)
        +0.0450000000    ETH (      +500.00 BRL)
```

Note that the total BRL amount was conserved (since there were no fees in BRL); however the
incidence of fee upon the ETH amount has caused it's balance to drop from the purchased 0.05 ETH
to 0.045 ETH.

Also, it is worth noting the effect of tracking: the balance of 0.045 ETH costed the account
owner 500 BRL, which is easily read in the accompanying data to the principal ETH balance.
"""
struct 𝒐𝒑Buy <: AbstractOP
    pay::SUB
    rec::SUB
    fee::SUB
    eef::SUB
    date::DateTime
    𝒐𝒑Buy(pay::SUB, rec::SUB, fee::SUB, eef::SUB; date::DateTime = now()) = begin
        @assert(isFiat(pay), "Buy operations must, by definition, be in fiat currency!")
        @assert(isCryp(rec), "Buy operations must, by definition, aquire crypto currency!")
        @assert(isCryp(fee), "First purchase fee must be in crypto currency!")
        @assert(isFiat(eef), "Secnd purchase fee must be in fiat currency!")
        @assert(rec.cur == fee.cur, "Receiving and 1st fee must be in the same currency!")
        @assert(pay.cur == eef.cur, "Payment and 2nd fee must be in the same currency!")
        new(pay, rec, fee, eef, date)
    end
end

# Functor with fuctionality
function (x::𝒐𝒑Buy)(sBal::MTB)::MTB
    REC = STB(x.rec - x.fee, x.pay + x.eef)     # Register total purchase price in tracking object
    return ((sBal + REC) - (x.pay + x.eef))[1]  # Credits receivings and discounts payment
end

# Addition
+(x::𝒐𝒑Buy, y::𝒐𝒑Buy) = 𝒐𝒑Buy(x.pay + y.pay,
                              x.rec + y.rec,
                              x.fee + y.fee,
                              x.eef + y.eef; date = x.date < y.date ? x.date : y.date)

# show/display
function Base.show(io::IO, ::MIME"text/plain", x::𝒐𝒑Buy)
    println("Crypto Purchase Operation with Fiat currency with")
    println("   - Earliest order date ..: ", x.date)
    println("   - Payment amount .......: ", unipre(x.pay))
    println("   - Purchase amount ......: ", pretty(x.rec))
    println("   - Cryp fee amount ......: ", pretty(x.fee))
    println("   - Fiat Fee amount ......: ", pretty(x.eef))
end

# export
export 𝒐𝒑Buy


#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#
#                                          𝒐𝒑Sell object                                           #
#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#

"""
`struct 𝒐𝒑Sell <: AbstractOP`\n
Sell operation object, that can be used as a functor for crypto sales:

Suppose `NDAX` holds the following balance in one's account:

```julia
julia> NDAX
      +700.0000000000    BRL (      +700.00 BRL)
        +0.0450000000    ETH (      +500.00 BRL)
```

One then sells 0.04 ETH for 500 BRL, with a 10 BRL fee. This transaction can be executed as
follows, as to update one's `NDAX` balance (as well as computing the transaction's loss or
profit) to:

```julia
julia> x = 𝒐𝒑Sell(SUB(:ETH, 0.04), SUB(:BRL, 500), SUB(:BRL, 10))
Crypto Sale Operation resulting on Fiat currency with
   - Earliest order date ..: 2025-04-28T22:24:39.066
   - Payment amount .......:         +0.0400000000    ETH
   - Purchase amount ......:       +500.00 BRL
   - Fee amount ...........:        +10.00 BRL

julia> NDAX, loss, profit = [x(NDAX)...]
3-element Vector{AbstractBL}:
      +1190.0000000000    BRL (     +1190.00 BRL)   # NDAX
        +0.0050000000    ETH (       +55.56 BRL)    # NDAX
         +0.00 BRL                                  # loss
        +45.56 BRL                                  # profit
```

One can compare the old total balance in fiat currency plus the profit:

```julia
julia> SUB(:BRL, 1200) + profit
     +1245.56 BRL
```

with the updated total fiat amount in `NDAX`:

```julia
julia> sum([i[2].fiat for i in NDAX.Mult])
     +1245.56 BRL
```
"""
struct 𝒐𝒑Sell <: AbstractOP
    pay::SUB
    rec::SUB
    fee::SUB
    date::DateTime
    𝒐𝒑Sell(pay::SUB, rec::SUB, fee::SUB; date::DateTime = now()) = begin
        @assert(isCryp(pay), "Sell operations must, by definition, be payed in crypto currency!")
        @assert(isFiat(rec), "Sell operations must, by definition, aquire fiat currency!")
        @assert(isFiat(fee), "Purchase fee must be in crypto currency!")
        @assert(rec.cur == fee.cur, "Receiving and fee must be in the same currency!")
        new(pay, rec, fee, date)
    end
end

# Functor with fuctionality
function (x::𝒐𝒑Sell)(sBal::MTB)::Tuple{MTB,SUB,SUB}
    sBal, PAY = sBal - x.pay            # Computes payment tracking / discounts payment
    REC = x.rec - x.fee                 # Mundane (untracked) fiat subtraction
    # Calculates loss and profit
    loss, prof = REC > PAY.fiat ? (SUB(symb(x.fee)), REC - PAY.fiat) : (PAY.fiat - REC, SUB(symb(x.fee)))
    # Credits receivings to already discounted payment / returns results
    return (sBal + STB(REC, REC), loss, prof)
end

# Addition
+(x::𝒐𝒑Sell, y::𝒐𝒑Sell) = 𝒐𝒑Sell(x.pay + y.pay,
                                 x.rec + y.rec,
                                 x.fee + y.fee; date = x.date < y.date ? x.date : y.date)

# show/display
function Base.show(io::IO, ::MIME"text/plain", x::𝒐𝒑Sell)
    println("Crypto Sale Operation resulting on Fiat currency with")
    println("   - Earliest order date ..: ", x.date)
    println("   - Payment amount .......: ", unipre(x.pay))
    println("   - Purchase amount ......: ", pretty(x.rec))
    println("   - Fee amount ...........: ", pretty(x.fee))
end

# export
export 𝒐𝒑Sell


#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#
#                                          𝒐𝒑Send object                                           #
#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#

"""
`struct 𝒐𝒑Send <: AbstractOP`\n
Send operation object, that can be used as a functor for outbound crypto transfers:

Suppose `NDAX` holds the following balance in one's account:

```julia
julia> NDAX
     +1200.0000000000    BRL (     +1200.00 BRL)
        +0.0450000000    ETH (      +500.00 BRL)
```

One then sends 0.04 ETH, with a fee of 0.004 ETH to a private wallet (say, Phantom) with the
folowing balance:

```julia
julia> PHAN
        +0.0000000000    BRL (        +0.00 BRL)    # This Fiat balance is forced by the `MTB`
        +0.0120000000    BTC (     +7196.00 BRL)
        +0.3000000000    ETH (     +1250.00 BRL)
```

This transaction can be executed as follows, as to update one's `NDAX` (and `PHAN`) balance(s):

```julia
julia> x = 𝒐𝒑Send(SUB(:ETH, 0.04), SUB(:ETH, 0.004))
Crypto Sale Operation resulting on Fiat currency with
   - Earliest order date ..: 2025-04-28T23:23:40.292
   - Send amount ..........:         +0.0400000000    ETH
   - Fee amount ...........:         +0.0040000000    ETH

julia> NDAX, PHAN = [x(NDAX, PHAN)...]
2-element Vector{MTB}:
      +1200.0000000000    BRL (     +1200.00 BRL)   # NDAX ⇩
        +0.0010000000    ETH (       +11.11 BRL)
         +0.0000000000    BRL (        +0.00 BRL)   # PHAN ⇩
        +0.0120000000    BTC (     +7196.00 BRL)
        +0.3400000000    ETH (     +1694.44 BRL)
```
"""
struct 𝒐𝒑Send <: AbstractOP
    snd::SUB
    fee::SUB
    date::DateTime
    𝒐𝒑Send(snd::SUB, fee::SUB; date::DateTime = now()) = begin
        @assert(isCryp(snd), "Send operations must, by definition, be sending crypto currency!")
        @assert(snd.cur == fee.cur, "Sending fee must be in the same currency of what's being send!")
        new(snd, fee, date)
    end
end

# Functor with fuctionality
function (x::𝒐𝒑Send)(sBal::MTB, oBal::Union{MTB,Nothing} = nothing)::Tuple{MTB,MTB}
    𝑎, 𝑏 = sBal - x.snd     # 𝑏 is sent balance, with tracking; 𝑎 is temporary
    𝑎    = (𝑎 - x.fee)[1]   # 𝑎 is the (already) tracked balance without the taken fee
    if oBal isa Nothing
        return 𝑎, MTB(𝑏)
    else
        return 𝑎, oBal + 𝑏
    end
end

# Addition
+(x::𝒐𝒑Send, y::𝒐𝒑Send) = 𝒐𝒑Send(x.snd + y.snd,
                                 x.fee + y.fee; date = x.date < y.date ? x.date : y.date)

# show/display
function Base.show(io::IO, ::MIME"text/plain", x::𝒐𝒑Send)
    println("Crypto Outbound Transfer Operation with")
    println("   - Earliest order date ..: ", x.date)
    println("   - Send amount ..........: ", pretty(x.snd))
    println("   - Fee amount ...........: ", pretty(x.fee))
end

# export
export 𝒐𝒑Send


#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#
#                                          𝒐𝒑Recv object                                           #
#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#

"""
`struct 𝒐𝒑Recv <: AbstractOP`\n
Recv operation object, that can be used as a functor for inbound crypto transfers.

Depending on available / provided arguments, the inbound fiat tracking can be based either (i)
on another multi-tracking balance, or (ii) on an approximation (by market price at transaction
time) provided in the NovaDAX statements, which is what NovaDAX 𝑐𝑎𝑛 have, and therefore likely
what's they use with RFB.

Suppose one's `NDAX` and `PHAN` multi-tracked statements hold the following balances:

```julia
julia> [NDAX, PHAN]
2-element Vector{MTB}:
      +1200.0000000000    BRL (     +1200.00 BRL)   # NDAX ⇩
        +0.0010000000    ETH (       +11.11 BRL)
         +0.0000000000    BRL (        +0.00 BRL)   # PHAN ⇩
        +0.0120000000    BTC (     +7196.00 BRL)
        +0.3400000000    ETH (     +1694.44 BRL)
```

One then sends from one's private wallet (say, Phantom), at a moment in which the price of
ETH/BRL is high, of 628.12 BRL per 0.044 ETH, which is the receiving amount. Recall in the
"send" example, o.045 ETH was purchased by 500 BRL.

This transaction can be executed as follows, as to update one's `NDAX` (and `PHAN`) balance(s):

```julia
julia> x = 𝒐𝒑Recv(SUB(:ETH, 0.044), SUB(:ETH, 0.001), SUB(:BRL, 628.12))
Crypto Receiving Operation with
   - Earliest order date ..: 2025-04-29T00:11:14.382
   - Recv amount ..........:         +0.0440000000    ETH
   - Approximate tracking..:       +628.1200000000    BRL
   - Fee amount ...........:         +0.0010000000    ETH

julia> 𝐍, 𝐏 = [x(NDAX, PHAN)...]    # This uses actually calculated trackings
2-element Vector{MTB}:
      +1200.0000000000    BRL (     +1200.00 BRL)   # 𝐍 ⇩
        +0.0120000000    BTC (     +7196.00 BRL)
        +0.0450000000    ETH (      +230.39 BRL)
         +0.0000000000    BRL (        +0.00 BRL)   # 𝐏 ⇩
        +0.0120000000    BTC (     +7196.00 BRL)
        +0.2950000000    ETH (     +1470.18 BRL)

julia> 𝐍, 𝐏 = [x(NDAX)...]          # This uses approximate (market price) trackings
2-element Vector{Union{Nothing, MTB}}:
      +1200.0000000000    BRL (     +1200.00 BRL)
        +0.0120000000    BTC (     +7196.00 BRL)
        +0.0450000000    ETH (      +639.23 BRL)
 nothing
```
"""
struct 𝒐𝒑Recv <: AbstractOP
    rcv::SUB
    fee::SUB
    apr::SUB
    date::DateTime
    𝒐𝒑Recv(rcv::SUB, fee::SUB, apr::SUB; date::DateTime = now()) = begin
        @assert(isCryp(rcv), "Recv operations must, by definition, be receiving crypto currency!")
        @assert(isCryp(fee), "Receiving fee must be in crypto currency!")
        @assert(isFiat(apr), "Approximate statement tracking must be fiat!")
        new(rcv, fee, apr, date)
    end
end

# Functor with fuctionality
function (x::𝒐𝒑Recv)(sBal::MTB, oBal::Union{MTB,Nothing} = nothing)::Tuple{MTB,Union{MTB,Nothing}}
    if oBal isa Nothing
        # Don't have to update oBal
        # But no tracking info either (use approximation)
        sBal += STB(x.rcv, x.apr)   # Aggregates aproximate tracking into received amount
        return sBal, nothing
    else
        𝑎, 𝑏 = oBal - x.rcv     # This makes 𝑏 as the transfered amount (with tracking)
        𝑎    = (𝑎 - x.fee)[1]   # This makes 𝑎 as the tracked balance for oBal
        sBal += 𝑏
        return sBal, 𝑎
    end
end

# Addition
+(x::𝒐𝒑Recv, y::𝒐𝒑Recv) = 𝒐𝒑Sell(x.rcv + y.rcv,
                                 x.fee + y.fee,
                                 x.apr + y.apr; date = x.date < y.date ? x.date : y.date)

# show/display
function Base.show(io::IO, ::MIME"text/plain", x::𝒐𝒑Recv)
    println("Crypto Inbound Transfer Operation with")
    println("   - Earliest order date ..: ", x.date)
    println("   - Recv amount ..........: ", pretty(x.rcv))
    println("   - Approximate tracking..: ", unipre(x.apr))
    println("   - Fee amount ...........: ", pretty(x.fee))
end

# export
export 𝒐𝒑Recv


#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#
#                                           𝒐𝒑Xch object                                           #
#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#

"""
`struct 𝒐𝒑Xch <: AbstractOP`\n
Exchange operation object, that can be used as a functor for crypto-crypto swaps, with fees in
either crypto currency.
"""
struct 𝒐𝒑Xch <: AbstractOP
    pay::SUB
    rec::SUB
    fee::SUB
    eef::SUB
    date::DateTime
    𝒐𝒑Xch(pay::SUB, rec::SUB, fee::SUB, eef::SUB; date::DateTime = now()) = begin
        @assert(isCryp(pay), "Xch operations must, by definition, be a crypto swap!")
        @assert(isCryp(rec), "Xch operations must, by definition, be a crypto swap!")
        @assert(rec.cur == fee.cur, "Receiving and primary fee must be in the same currency!")
        @assert(pay.cur == eef.cur, "Paying and secondary fee must be in the same currency!")
        new(pay, rec, fee, eef, date)
    end
end

# Functor with fuctionality
function (x::𝒐𝒑Xch)(sBal::MTB)::MTB
    dwn, pmt = sBal - (x.pay + x.eef)   # dwm, pmt: tracked (balance, pay) after payment & fee
    cre = STB(x.rec - x.fee, pmt.fiat)  # Tracked swap/exchange credit
    return dwn + cre                    # Tracked balance after the exchange
end

# Addition
+(x::𝒐𝒑Xch, y::𝒐𝒑Xch) = 𝒐𝒑Xch(x.pay + y.pay,
                              x.rec + y.rec,
                              x.fee + y.fee,
                              x.eef + y.eef; date = x.date < y.date ? x.date : y.date)

# show/display
function Base.show(io::IO, ::MIME"text/plain", x::𝒐𝒑Xch)
    println("Crypto Exchange Operation with")
    println("   - Earliest order date ..: ", x.date)
    println("   - Payment amount .......: ", pretty(x.pay))
    println("   - Purchase amount ......: ", pretty(x.rec))
    println("   - Rcving crypt fee amt .: ", pretty(x.fee))
    println("   - Paying crypt fee amt .: ", pretty(x.eef))
end

# export
export 𝒐𝒑Xch


