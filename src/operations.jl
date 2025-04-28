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
export 𝑜Init, 𝒐𝒑Ini


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
function (x::𝒐𝒑Dep)(sBal::MTB)
    @assert(symb(x.amt) == fiat(sBal), "Deposits not in tracking fiat unimplemented!")
    dBal = STB(x.amt, x.amt)
    return sBal + dBal
end

# Addition
+(x::𝒐𝒑Dep, y::𝒐𝒑Dep) = 𝒐𝒑Dep(x.amt + y.amt; date = x.date < y.date ? x.date : y.date)

# show/display
function Base.show(io::IO, ::MIME"text/plain", x::𝒐𝒑Dep)
    println("Deposit Operation with")
    println("   - Deposit amount .......: ", pretty(x.amt))
end

# export
export 𝑜Deposit, 𝒐𝒑Dep


#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#
#                                               𝑜Buy                                               #
#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#

"""
`𝑜Buy(sBal::MTB; pay::SUB, rec::SUB, fee::SUB)::MTB`\n
On-Ramp purchase with fee.

Keyword args are:
- `pay::SUB` is the (positive) fiat amount payed as a Single Untracked Balance;
- `rec::SUB` is the (positive) crypto amount received as a Single Untracked Balance;
- `fee::SUB` is the (positive) crypto amount charged as a Single Untracked Balance.

Returns the updated rolling tracked statement balance, as in the following:

```julia
julia> sBal = 𝑜Init()
        +0.0000000000    BRL (        +0.00 BRL)

julia> sBal = 𝑜Deposit(sBal, SUB(:BRL, 2000))
     +2000.0000000000    BRL (     +2000.00 BRL)

julia> sBal = 𝑜Buy(sBal, pay=SUB(:BRL, 199997//100),
                         rec=SUB(:ETH, 234//1000),
                         fee=SUB(:ETH, 234//1000000))
        +0.0300000000    BRL (        +0.03 BRL)
        +0.2337660000    ETH (     +1999.97 BRL)
```

`𝑜Buy` operations have the same effect as "Convert" transactions.
"""
function 𝑜Buy(sBal::MTB; pay::SUB, rec::SUB, fee::SUB)::MTB
    @assert(isCryp(fee), "Purchase with fiat fee is unimplemented!")
    REC = STB(rec - fee, pay)
    return (sBal + REC - pay)[1]
end


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

# Functor
(x::𝒐𝒑Buy)(sBal::MTB) = 𝑜Buy(sBal, x.pay, x.rec, x.fee)

# Addition
+(x::𝒐𝒑Buy, y::𝒐𝒑Buy) = 𝒐𝒑Buy(x.pay + y.pay,
                              x.rec + y.rec,
                              x.fee + y.fee; date = x.date < y.date ? x.date : y.date)

# show/display
function Base.show(io::IO, ::MIME"text/plain", x::𝒐𝒑Buy)
    println("Crypto Purchase Operation with Fiat currency with")
    println("   - Payment amount .......: ", unipre(x.pay))
    println("   - Purchase amount ......: ", pretty(x.rec))
    println("   - Fee amount ...........: ", pretty(x.fee))
end

# export
export 𝑜Buy, 𝒐𝒑Buy


#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#
#                                              𝑜Sell                                               #
#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#

"""
`𝑜Sell(sBal::MTB; pay::SUB, rec::SUB, fee::SUB)::Tuple{MTB,SUB}`\n
Off-Ramp sale with fee and loss/profit calculation.

Keyword args are:
- `pay::SUB` is the (positive) crypto amount payed as a Single Untracked Balance;
- `rec::SUB` is the (positive) fiat amount received as a Single Untracked Balance;
- `fee::SUB` is the (positive) fiat amount charged as a Single Untracked Balance.

Returns the updated rolling tracked statement balance, as in the following:

```julia
julia> sBal = 𝑜Init()
        +0.0000000000    BRL (        +0.00 BRL)

julia> sBal = 𝑜Deposit(sBal, SUB(:BRL, 2000))
     +2000.0000000000    BRL (     +2000.00 BRL)

julia> sBal = 𝑜Buy(sBal, pay=SUB(:BRL, 199997//100),
                         rec=SUB(:ETH, 234//1000),
                         fee=SUB(:ETH, 234//1000000))
        +0.0300000000    BRL (        +0.03 BRL)
        +0.2337660000    ETH (     +1999.97 BRL)

julia> sBal, 𝑙, 𝑝 = 𝑜Sell(sBal, pay=SUB(:ETH, 134//1000),
                                rec=SUB(:BRL, 5010),
                                fee=SUB(:BRL, 10));

julia> sBal
     +5000.0300000000    BRL (     +5000.03 BRL)	# New balance has now more :BRL's
        +0.0997660000    ETH (      +853.54 BRL)

julia> [𝑙, 𝑝]
2-element Vector{SUB}:
         +0.00 BRL			# Loss   =    +0.00 BRL
      +3853.57 BRL			# Profit = +3853.57 BRL
```

Therefore, the purchase of 0.234 ETH by 1999.97 BRL (with 0.00000234 ETH fee)
followed by the sale of 0.134 ETH by 5010 BRL (with 10 BRL fee) represented a
net PROFIT of +3853.57 BRL.
"""
function 𝑜Sell(sBal::MTB; pay::SUB, rec::SUB, fee::SUB)::Tuple{MTB,SUB,SUB}
    @assert(isFiat(fee), "Sale with crypto fee is unimplemented!")
    sBal, PAY = sBal - pay      # Computes payment tracking
    REC = rec - fee
    loss, prof = REC > PAY.fiat ? (SUB(symb(fee)), REC - PAY.fiat) : (PAY.fiat - REC, SUB(symb(fee)))
    return (sBal + STB(REC, REC), loss, prof)
end

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


