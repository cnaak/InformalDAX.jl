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
julia> NDAX = 𝒐𝒑Buy(SUB(:BRL, 500), SUB(:ETH, 5//100), SUB(:ETH, 5//1000))(NDAX)
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
    date::DateTime
    𝒐𝒑Buy(pay::SUB, rec::SUB, fee::SUB; date::DateTime = now()) = begin
        @assert(isFiat(pay), "Buy operations must, by definition, be in fiat currency!")
        @assert(isCryp(rec), "Buy operations must, by definition, aquire crypto currency!")
        @assert(isCryp(fee), "Purchase fee must be in crypto currency!")
        @assert(rec.cur == fee.cur, "Receiving and fee must be in the same currency!")
        new(pay, rec, fee, date)
    end
end

# Functor with fuctionality
function (x::𝒐𝒑Buy)(sBal::MTB)::MTB
    REC = STB(x.rec - x.fee, x.pay)     # Register purchase price in tracking object
    return ((sBal + REC) - x.pay)[1]    # Credits receivings and discounts payment
end

# Addition
+(x::𝒐𝒑Buy, y::𝒐𝒑Buy) = 𝒐𝒑Buy(x.pay + y.pay,
                              x.rec + y.rec,
                              x.fee + y.fee; date = x.date < y.date ? x.date : y.date)

# show/display
function Base.show(io::IO, ::MIME"text/plain", x::𝒐𝒑Buy)
    println("Crypto Purchase Operation with Fiat currency with")
    println("   - Earliest order date ..: ", x.date)
    println("   - Payment amount .......: ", unipre(x.pay))
    println("   - Purchase amount ......: ", pretty(x.rec))
    println("   - Fee amount ...........: ", pretty(x.fee))
end

# export
export 𝒐𝒑Buy


#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#
#                                          𝒐𝒑Sell object                                           #
#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#

"""
`struct 𝒐𝒑Sell <: AbstractOP`\n
Sell operation object, that can be used as a functor for crypto purchases:

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
#                                              𝑜Send                                               #
#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#

"""
`𝑜Send(sBal::MTB, amt::SUB, fee::SUB, oBal::Union{MTB,Nothing} = nothing)::NTuple{2,MTB}`\n
Send cryptocurrency operation, with fee. `sBal` is the rolling statement multi-tracked balance;
`amt` is the sent crypto amount, `fee` is the crypto fee amount, and `oBal` is an optional
"other" multi-tracked balance.

```julia
julia> sBal, oBal = 𝑜Init(), 𝑜Init(MTB(STB((:BRL, :BRL), (1200, 1200))));

julia> sBal = 𝑜Deposit(sBal, SUB(:BRL, 2000))
     +2000.0000000000    BRL (     +2000.00 BRL)

julia> sBal = 𝑜Buy(sBal, pay=SUB(:BRL, 199997//100),
                         rec=SUB(:ETH, 234//1000),
                         fee=SUB(:ETH, 234//1000000))
        +0.0300000000    BRL (        +0.03 BRL)
        +0.2337660000    ETH (     +1999.97 BRL)
julia> sBal, oBal = 𝑜Send(sBal, SUB(:ETH, 1//5), SUB(:ETH, 1//200), oBal);

julia> sBal
        +0.0300000000    BRL (        +0.03 BRL)
        +0.0287660000    ETH (      +246.11 BRL)

julia> oBal
     +1200.0000000000    BRL (     +1200.00 BRL)
        +0.2050000000    ETH (     +1753.86 BRL)
```
"""
function 𝑜Send(sBal::MTB, amt::SUB, fee::SUB, oBal::Union{MTB,Nothing} = nothing)::NTuple{2,MTB}
    𝑎, 𝑏 = sBal - (amt + fee)
    if oBal isa Nothing
        return 𝑎, MTB(𝑏)
    else
        return 𝑎, oBal + 𝑏
    end
end

# export
export 𝑜Send


