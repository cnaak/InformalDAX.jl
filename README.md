# InformalDAX

An unofficial Julia module for processing cryptocurrency exchange statements from NovaDAX.

The author has no affiliation, employment, or representative agreement with the aforementioned exchange.

## Description

This is a personal-use Julia module designed for custom calculations based on statements from
the NovaDAX cryptocurrency exchange. It is released under the MIT license **without any
warranty** (see the full LICENSE for terms), and is provided **"as is"**—so please don't expect
bug fixes or feature additions upon opening issues or making requests.

This is the author's first foray into financial programming, created for personal
experimentation and exploration. It serves to handle specific needs, such as learning about
financial data processing and working with specialized binary quantity types in Julia via
[`FixedPointDecimals.jl`](https://github.com/JuliaMath/FixedPointDecimals.jl).

## Selected Features

Among it's features the so-called "tracked" balance objects, which are herein used to keep track
of average (effective) purchase price of the various cripto assets on a given fiat currency,
based on various statement recordings, i.e., based on the transactions.

### Example:

Suppose initially one buys `0.01 BTC` for `980 USD`; one's tracked balance is therefore:

```julia
julia> using InformalDAX

julia> myBTCBal = STB((:BTC, :USD), (1//100, 980))  # STB is a Single Tracked Balance object
        +0.0100000000    BTC (      +980.00 USD)
```

Then, out of this balance, `0.001 BTC` gets transfered away. The remaining tracked (adjusted)
and tracked taken balances are:

```julia
julia> xfer = SUB(:BTC, 1//1000)                    # SUB is a Single Untracked Balance object
        +0.0010000000    BTC

julia> myBTCBal, xfer = myBTCBal - xfer;            # Updates `myBTCBal` and adds
                                                    # tracking info to `xfer`
julia> [ display(i) for i in (myBTCBal, xfer) ];
        +0.0090000000    BTC (      +882.00 USD)
        +0.0010000000    BTC (       +98.00 USD)
```

Meaning the retained balance of `0.009 BTC` retained `882 USD` in fiat purchase price—the data
in `myBTCBal`; and the taken amount of `0.001 BTC` represents a fraction worth of `98 USD` of
its purchase price in fiat currency—the data in `xfer`.

If the tracked crypto amount is later sold back into the fiat currency (USD in this example),
any realized gains or losses become immediately visible through the tracked fiat amount in the
`xfer::STB` object.

Additionally, since exchanges typically display crypto balances converted to fiat at market
prices, knowing the corresponding tracked fiat amount of your crypto holdings can support more
informed trading decisions—making potential profits or losses much more evident.

## Author

C. Naaktgeboren

`NaaktgeborenC <dot!> PhD {at!} gmail [dot!] com`

## License

This project is [licensed](https://github.com/cnaak/InformalDAX.jl/blob/main/LICENSE)
under the MIT license.


