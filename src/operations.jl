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
#                                       Operation Functions                                        #
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

# export
export 𝑜Init


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
"""
function 𝑜Deposit(sBal::MTB, amt::SUB)::MTB
    @assert(symb(amt) == fiat(sBal), "Deposits not in tracking fiat unimplemented!")
    dBal = STB(amt, amt)
    return sBal + dBal
end

# export
export 𝑜Deposit


#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#
#                                               𝑜Buy                                               #
#⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅#

"""
`𝑜Buy(sBal::MTB; pay::SUB, rec::SUB, fee::SUB)::MTB`\n
On-Ramp purchase with fee.

Keyword args are:
- `pay::SUB` is the (positive) fiat amount payed as a Single Untracked Balance;
- `rec::SUB` is the (positive) crypto amount received as a Single Untracked Balance;
- `fee::SUB` is the (positive) crypto or fiat amount charged as a Single Untracked Balance.

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
"""
function 𝑜Buy(sBal::MTB; pay::SUB, rec::SUB, fee::SUB)::MTB
    if isCryp(fee)
        REC = STB(rec - fee, pay)
    else
        REC = STB(rec, pay + fee)
    end
    return (sBal + REC - pay)[1]
end

# export
export 𝑜Buy



