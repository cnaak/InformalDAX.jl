# InformalDAX

Unofficial module to process `NovaDAX`'s crypto exchange statements in Julia.

The author has no employment nor representative arrangement with the aforementioned exchange.

## Description

Personal use module written in Julia for performing custom calculations based on `NovaDAX`'s
crypto exchange statements, made available under the MIT license: WITHOUT WARRANTY OF ANY KIND
(see full LICENSE for terms), and PROVIDED "AS IS", so don't expect fixes or features to be
implemented upon request or issue opening.

It is author's first financial package, that serves custom purposes, including getting
acquainted with financial programming and it's specialized binary quantity types in Julia, by
means of `FixedPointDecimals.jl`.

## Selected Features

Among it's features the so-called "tracked" balance objects, which are herein used to keep track
of average (effective) purchase price of the various cripto assets on a given fiat currency,
based on various statement recordings, i.e., based on the transactions.

### Example:

Suppose initially one buys `0.01 BTC` for `980 USD`; one's tracked balance is therefore:

```julia
julia> using InformalDAX

julia> myBTCBal = STB(SUB(:BTC, 1//100), SUB(:USD, 980))
        +0.0100000000    BTC
              +980.00    USD
```

Then, out of this balance, `0.001 BTC` gets transfered away. The remaining tracked (adjusted)
and tracked taken balances are:

```julia
julia> transfer = SUB(:BTC, 1//1000)
        +0.0010000000    BTC

julia> df, tk = myBTCBal - transfer;

julia> [ display(i) for i in (df, tk) ];
        +0.0090000000    BTC
              +882.00    USD

        +0.0010000000    BTC
               +98.00    USD
```

Meaning the retained balance of `0.009 BTC` retained `882 USD` in fiat purchase price—the data
in `df`; and the taken amount of `0.001 BTC` represents a fraction worth of `98 USD` of its
purchase price in fiat currency—the data in `tk`.

Suppose the taken amout is sold back to the tracked fiat currency, `USD` in the example, then
realized losses or profits are easily identifiable from the fiat tracked amount in `tk`.

Moreover, as exchanges usually display crypto balances in market-price fiats, having knowledge
of the corresponding tracked amount of one's cripto currency balances, aids in trade
decision-making, since eventual losses or profits become far more evident.


## Author

C. Naaktgeboren

`NaaktgeborenC <dot!> PhD {at!} gmail [dot!] com`


## License

This project is [licensed](https://github.com/cnaak/InformalDAX.jl/blob/main/LICENSE)
under the MIT license.


