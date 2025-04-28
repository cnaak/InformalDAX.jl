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

# 𝒐𝒑Ini object
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

# 𝒐𝒑Dep object
struct 𝒐𝒑Dep <: AbstractOP
    amt::SUB
    date::DateTime
    𝒐𝒑Dep(amt::SUB; date::DateTime = now()) = new(amt, date)
end

# Functor with functionality
function (x::𝒐𝒑Dep)(sBal::MTB)::MTB
    @assert(symb(x.amt) == fiat(sBal), "Deposits not in tracking fiat unimplemented!")
    dBal = STB(x.amt, x.amt)
    return sBal + dBal
end

# Addition
+(x::𝒐𝒑Dep, y::𝒐𝒑Dep) = 𝒐𝒑Dep(x.amt + y.amt; date = x.date < y.date ? x.date : y.date)

# show/display
function Base.show(io::IO, ::MIME"text/plain", x::𝒐𝒑Dep)
    println("Deposit Operation with")
    println("   - Earliest order date ..: ", x.date)
    println("   - Deposit amount .......: ", pretty(x.amt))
end

# export
export 𝒐𝒑Dep


#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#
#                                           𝒐𝒑Buy object                                           #
#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#

# 𝒐𝒑Buy object
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

# 𝒐𝒑Sell object
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
    loss, prof = REC > PAY.fiat ? (SUB(symb(fee)), REC - PAY.fiat) : (PAY.fiat - REC, SUB(symb(fee)))
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


# export
export 𝑜Sell


#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#
#                                            𝑜Withdraw                                             #
#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#

"""
`𝑜Withdraw(sBal::MTB, amt::SUB, oBal::Union{MTB,Nothing} = nothing)::NTuple{2,MTB}`\n
Withdraw operation, only implemented for tracked fiat amounts. `sBal` is the rolling statement
multi-tracked balance; `amt` is the untracked withdrawal amount, and `oBal` is an optional
"other" multi-tracked balance.

Returns a 2-tuple with the updated rolling tracked statement balances, as in the following:

```julia
julia> sBal, oBal = 𝑜Init(), 𝑜Init(MTB(STB((:BRL, :BRL), (1200, 1200))));

julia> sBal = 𝑜Deposit(sBal, SUB(:BRL, 2000))
     +2000.0000000000    BRL (     +2000.00 BRL)

julia> sBal, oBal = 𝑜Withdraw(sBal, SUB(:BRL, 2000), oBal);

julia> sBal
        +0.0000000000    BRL (        +0.00 BRL)

julia> oBal
     +3200.0000000000    BRL (     +3200.00 BRL)
```
"""
function 𝑜Withdraw(sBal::MTB, amt::SUB, oBal::Union{MTB,Nothing} = nothing)::NTuple{2,MTB}
    @assert(symb(amt) == fiat(sBal), "Withdrawals not in tracking fiat unimplemented!")
    𝑎, 𝑏 = sBal - amt
    if oBal isa Nothing
        return 𝑎, MTB(𝑏)
    else
        return 𝑎, oBal + 𝑏
    end
end

# export
export 𝑜Withdraw


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


