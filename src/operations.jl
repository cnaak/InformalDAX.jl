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
#                                              𝑜Init                                               #
#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#

"""
`𝑜Init(prev::MTB = emptyRFB())::MTB`\n
Initialization operation, for a new month's statement processing. Argument is previous month's
end balance. If ommitted, defaults to an emptyRFB() one. Returns a copied `MTB`.

When processing a month's statement, begin with

```julia
julia> sBal = 𝑜Init()
        +0.0000000000    BRL (        +0.00 BRL)
```

if it's the first month (no previous month's balance), or with

```julia
julia> pBal = MTB(STB((:BRL, :BRL), (SFD(123.48), SFD(123.48))),    # Previous month's
                  STB((:BTC, :BRL), (SFD(0.0011), SFD(624.40))))    # end balance
      +123.4800000000    BRL (      +123.48 BRL)
        +0.0011000000    BTC (      +624.40 BRL)

julia> sBal = 𝑜Init(pBal)
      +123.4800000000    BRL (      +123.48 BRL)
        +0.0011000000    BTC (      +624.40 BRL)
```
"""
function 𝑜Init(prev::MTB = emptyRFB())::MTB
    return MTB(prev())
end


#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#

# 𝒐𝒑Ini object
struct 𝒐𝒑Ini <: AbstractOP
    prev::MTB
    𝒐𝒑Ini(prev::MTB = emptyRFB()) = new(prev)
end

# Functor
(x::𝒐𝒑Ini)() = 𝑜Init(x.prev)

# Addition
+(x::𝒐𝒑Ini, y::𝒐𝒑Ini) = 𝒐𝒑Ini(x.prev + y.prev)

# show/display
function Base.show(io::IO, ::MIME"text/plain", x::𝒐𝒑Ini)
    print("Balance Initialization Operation with\n")
    print(pretty(x.prev))
end

# export
export 𝑜Init, 𝒐𝒑Ini


#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#
#                                             𝑜Deposit                                             #
#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#

"""
`𝑜Deposit(sBal::MTB, amt::SUB)::MTB`\n
Deposit operation, only implemented for tracked fiat amounts. `sBal` is the rolling statement
multi-tracked balance, and `amt` is the untracked deposited amount.

Returns the updated rolling tracked statement balance, as in the following:

```julia
julia> sBal = 𝑜Init()
        +0.0000000000    BRL (        +0.00 BRL)

julia> sBal = 𝑜Deposit(sBal, SUB(:BRL, 2000))
     +2000.0000000000    BRL (     +2000.00 BRL)
```

`𝑜Deposit` operations have the same effect as "Redeemed Bonus" transactions.

FOR THE MULTI-BALANCE TRANSACTION, SEE 𝑜WithDraw() with reversed multi-balance arguments.
"""
function 𝑜Deposit(sBal::MTB, amt::SUB)::MTB
    @assert(symb(amt) == fiat(sBal), "Deposits not in tracking fiat unimplemented!")
    dBal = STB(amt, amt)
    return sBal + dBal
end


#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#

# 𝒐𝒑Dep object
struct 𝒐𝒑Dep <: AbstractOP
    amt::SUB
    𝒐𝒑Dep(amt::SUB) = new(amt)
end

# Functor
(x::𝒐𝒑Dep)(sBal::MTB) = 𝑜Deposit(sBal, x.amt)

# Addition
+(x::𝒐𝒑Dep, y::𝒐𝒑Dep) = 𝒐𝒑Dep(x.amt + y.amt)

# show/display
function Base.show(io::IO, ::MIME"text/plain", x::𝒐𝒑Dep)
    print("Deposit Operation with\n")
    print(pretty(x.amt))
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

# export
export 𝑜Buy


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


