#!/bin/zsh

# -z 1m: duration
# -c 2000: number of concurrent requests.

hey -z 1m -c 2000 https://currency.local/currency-exchange/from/USD/to/PLN