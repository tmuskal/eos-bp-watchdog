# eos-bp-watchdog
Script for automatically unregistering a block producer when it stops producing


## Requirements:

- cleos
- jq

## First time setup
1. create key for the watchdog permissions:

```
cleos create key
```


> Private key: YOUR_PRIVATE_KEY

> Public key: YOUR_PUBLIC_KEY

2. Grant watchdog permissions
  
```
PRODUCERACCT=yourbp

cleos set account permission $PRODUCERACCT watchdog '{"threshold":1,"keys":[{"key":"YOUR_PUBLIC_KEY","weight":1}]}' "active" -p $PRODUCERACCT@active

cleos set action permission $PRODUCERACCT eosio unregprod watchdog

```

3. Create wallet for watchdog

```
cleos wallet create -n watchdog
```

> Save password to use in the future to unlock this wallet.

> Without password imported keys will not be retrievable.

> "PWyourpasswordyourpasswordyourpasswordyourpassword"

3. Import key for watchdog

```
cleos wallet import YOUR_PRIVATE_KEY -n watchdog
```
4. edit the PRODUCERACCT and PASS variables in watchdog.sh
## Run

```
./watchdog.sh yourbp PWyourpasswordyourpasswordyourpasswordyourpassword
```


## Contributors

- [LiquidEOS](https://liquideos.com/)

