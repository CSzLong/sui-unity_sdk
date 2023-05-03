# Sui SDK for Unity

## Code Structure
    .
    ├── smartunity
    ├    └── interface
    ├            ├── init_coin
    ├            ├── buy_coin
    ├            ├── gain_coin
    ├            ├── increase_score
    ├            ├── decrease_score
    ├            ├── increase_begin_score
    ├            ├── generate_pool
    ├            ├── create_pocket
    ├            ├── deposit_totally
    ├            ├── deposit_partly
    ├            ├── remove_liquidity_totally
    ├            ├── withdraw_out
    ├            ├── swap_x_to_y
    ├            └── swap_y_to_x 
    └── testcoin
           ├── cnya
           ├     └── mint_coin
           └── cnyw
                 └── mint_coin

## Function parameters
### init_coin
| parameters | type             | Comment   |
|:-----------|:-----------------|:----------|
 | flag       | &mut flag        | flag ID   |
| ctx        | &mut TxContext   | signature |

### buy_coin
| parameters | type                    | Comment                  |
|:-----------|:------------------------|:-------------------------|
| coin       | &mut Coin<GCOIN>        | Coin ID                  |
| payment    | &mut Coin<SUI>          | SUI coin ID              |
| amount     | u64                     | integer number           |
| cap        | &mut TreasuryCap<GCOIN> | the cap ID of GCOIN      |
| ctx        | &mut TxContext          | signature                |

### gain_coin
| parameters | type                    | Comment                |
|:-----------|:------------------------|:-----------------------|
| coin       | &mut Coin<GCOIN>        | Coin ID                |
| cap        | &mut TreasuryCap<GCOIN> | cap ID of GCOIN        |
| value      | u64                     | integer number         |
| ctx        | &mut TxContext          | signature              |

### increase_score
| parameters | type                    | Comment         |
|:-----------|:------------------------|:----------------|
| record     | &mut Record             | Record ID       |
| value      | u64                     | integer number  |

### decrease_score
| parameters | type                    | Comment         |
|:-----------|:------------------------|:----------------|
| record     | &mut Record             | Record ID       |
| value      | u64                     | integer number  |

### increase_begin_score
| parameters | type                    | Comment         |
|:-----------|:------------------------|:----------------|
| record     | &mut Record             | Record ID       |
| value      | u64                     | integer number  |

### generate_pool
| parameters | type                    | Comment                 |
|:-----------|:------------------------|:------------------------|
| ctx        | &mut TxContext          | signature               |

### create_pocket
| parameters | type                    | Comment                 |
|:-----------|:------------------------|:------------------------|
| ctx        | &mut TxContext          | signature               |

### deposit_totally
| parameters | type            | Comment                                      |
|:-----------|:----------------|:---------------------------------------------|
| pool       | &mut Pool<X, Y> | Pool ID, need include the Coin Types(X, Y)   |
| coin_x     | Coin<X>         | Coin ID of X                                 |
| coin_y     | Coin<Y>         | Coin ID of Y                                 |
| pocket     | $mut Pocket     | Pocket ID                                    |
| ctx        | &mut TxContext  | signature                                    |

### deposit_partly
| parameters | type            | Comment                                                                       |
|:-----------|:----------------|:------------------------------------------------------------------------------|
| pool       | &mut Pool<X, Y> | Pool ID that keep the Coin X, Y                                               |
| coin_x_vec | vector<Coin<X>> | A vector with multiple Coin IDs of X, format is '[\"coinxid1\",\"coinxid2\"]' |
| coin_y_vec | vector<Coin<X>> | A vector with multiple Coin IDs of Y, format is '[\"coinyid1\",\"coinyid2\"]' |   
| coin_x_amt | u64             | integer number, amount of Coin X to deposit                                   |
| coin_y_amt | u64             | integer number, amount of Coin Y to deposit                                   |
| pocket     | $mut Pocket     | Pocket ID                                                                     |
| ctx        | &mut TxContext  | signature                                                                     |

### withdraw_totally
| parameters | type            | Comment                         |
|:-----------|:----------------|:--------------------------------|
| pool       | &mut Pool<X, Y> | Pool ID that keep the Coin X, Y |
| lp         | Coin<LP<X,Y>>   | LP ID                           |
| pocket     | $mut Pocket     | Pocket ID                       |
| ctx        | &mut TxContext  | signature                       |

### withdraw_out
| parameters | type                   | Comment                                                                 |
|:-----------|:-----------------------|:------------------------------------------------------------------------|
| pool       | &mut Pool<X, Y>        | Pool ID that keep the Coin X, Y                                         |
| lp_vec     | vector<Coin<LP<X, Y>>> | A vector with multiple LP IDs of X/Y, format is '[\"lpid1\",\"lpid2\"]' |  
| coin_x_amt | u64                    | integer number, amount of Coin X to withdraw                            |
| coin_y_amt | u64                    | integer number, amount of Coin Y to withdraw                            |
| pocket     | $mut Pocket            | Pocket ID                                                               |
| ctx        | &mut TxContext         | signature                                                               |

### swap_x_to_y
| parameters | type             | Comment                                                                       |
|:-----------|:-----------------|:------------------------------------------------------------------------------|
| pool       | &mut Pool<X, Y>  | Pool ID that keep the Coin X, Y                                               |
| coin_x_vec | vector<Coin<X>>  | A vector with multiple Coin IDs of X, format is '[\"coinxid1\",\"coinxid2\"]' |
| amount     | u64              | integer number, amount of Coin Y to swap                                      |
| ctx        | &mut TxContext   | signature                                                                     |

### swap_y_to_x
| parameters | type            | Comment                                                                       |
|:-----------|:----------------|:------------------------------------------------------------------------------|
| pool       | &mut Pool<X, Y> | Pool ID that keep the Coin X, Y                                               |
| coin_y_vec | vector<Coin<Y>> | A vector with multiple Coin IDs of X, format is '[\"coinyid1\",\"coinyid2\"]' |
| amount     | u64             | integer number, amount of Coin X to swap                                      |
| ctx        | &mut TxContext  | signature                                                                     |

### mint_coin (CNYA/CNYW)
| parameters | type                                               | Comment                        |
|:-----------|:---------------------------------------------------|:-------------------------------|
| cap        | &mut TreasuryCap<CNYA>/<br/>&mut TreasuryCap<CNYW> | the cap ID of CNYA/CNYW        |
| amount     | u64                                                | integer number, amount to mint |
| ctx        | &mut TxContext                                     | signature                      |

## Command: Publish the smart contractors
### Publish
```bash
$ sui client publish --gas-budget 3000000000
```

### Define the variables
```bash
$ COINPKG="0xa86234649f92eef9d463689fc5c4b47abebbba252a812d5bd40294d83685aecb"
  CNYA="0xa86234649f92eef9d463689fc5c4b47abebbba252a812d5bd40294d83685aecb::cnya::CNYA"
  CNYW="0xa86234649f92eef9d463689fc5c4b47abebbba252a812d5bd40294d83685aecb::cnyw::CNYW"
  CNYACAP="0x628641f5b085ced2daaf371c87dfe52370236381310b14cab7c0c2440423b495"
  CNYWCAP="0xe6fa78186075f9819d637af85ebf9f0aac487df72dbe91e144bcd7b70b472969"
  AMMPKG="0x569e10cd777f70e6914b999c2e8577bac01c0d778b38503a74c67014985efd73"
  FLAGID="0x8cf64907102dec7c7faa566e0c04ff8dc80d7c8e401a43cee6133f0f63b4681b"
  GCOINCAP="0xb0e3e114f78ddccffe6371e8a67c54829fa51ed729cfeda9979bc68e0b505537"
```

## Command: Game Coin/Record Manipulation
### Initialize players' Coin and Record
```bash
$ sui client call --package $AMMPKG \
                  --module interface \
                  --function init_coin \
                  --gas-budget 1000000000 \
                  --args $FLAGID
```

```bash
$ GCOINID="0x73c4ecc5832971a09ff4b8cab725aa0ced34d7ac691258f77ce1d2ce1e59f33b"
  RECID="0x7bbe4e966b6f077261742d1a26b1204b9f6de43008449c37f159f015369c8a12"
  
```

### Buy Coin by pay SUI coins
```bash
$ sui client call --package $AMMPKG \
                  --module interface \
                  --function buy_coin \
                  --gas-budget 1000000000 \
                  --args $GCOINID 0x061eb221f3127dbb844fc5a6e7028befe0b159b2e2897fbadf3e7c6401284042 100000000 $GCOINCAP
```

### Gain the Coins
```bash
$ sui client call --package $AMMPKG \
                  --module interface \
                  --function gain_coin \
                  --gas-budget 1000000000 \
                  --args $GCOINID $GCOINCAP 10000000000
```

### Increase the score in record
```bash
$ sui client call --package $AMMPKG \
                  --module interface \
                  --function increase_score \
                  --gas-budget 1000000000 \
                  --args $RECID 1000000
```

### Decrease the score in record
```bash
$ sui client call --package $AMMPKG \
                  --module interface \
                  --function decrease_score \
                  --gas-budget 1000000000 \
                  --args $RECID 500000
```

### Decrease the score in record
```bash
$ sui client call --package $AMMPKG \
                  --module interface \
                  --function increase_begin_score \
                  --gas-budget 1000000000 \
                  --args $RECID 500000
```

## Command:: SWAP

### Mint the Test Coins: CNYW and CNYA
Suggest to mint the test coins more than 3 times to get multiple objects.
```bash
$ sui client call --package $COINPKG \
                  --module cnya \
                  --function mint_coin \
                  --gas-budget 1000000000 \
                  --args $CNYACAP 100000000000
```
```bash
$ sui client call --package $COINPKG \
                  --module cnyw \
                  --function mint_coin \
                  --gas-budget 1000000000 \
                  --args $CNYWCAP 100000000000
```

### Create SWAP pool
```bash
$ sui client call --package $AMMPKG \
                  --module interface \
                  --function generate_pool \
                  --gas-budget 1000000000 \
                  --type-args $CNYA $CNYW
```

### Generate pocket of Liquidity Providers
```bash
$ sui client call --package $AMMPKG \
                  --module interface \
                  --function create_pocket \
                  --gas-budget 1000000000
```

### Define new variables
```bash
$ POCKETID="0x65cf05776f0aae43ef1e62e379f4ea2248b54d798be43c362641958727ec26bf"
  POOLID="0xa580d238cd29aa57349a9c854816a1cbfbd9d3b06343905b8cc71afc362f9feb"
```

### Deposit all balance of CNYA and CNYW into Pool and get the LP
```bash
$ sui client call --package $AMMPKG \
                  --module interface \
                  --function deposit_totally \
                  --gas-budget 1000000000 \
                  --type-args $CNYA $CNYW \
                  --args $POOLID \
                         0x4ed8ebb365d82203ab33c7b3768ae6cf6a0c93a80891995b9a3df130c14792cf \
                         0x4e85afa70e9c8b09b41fdd181c7bf0772e4185ad69c110eff2cbbf7dd6de4ba6 \
                         $POCKETID
```

### Deposit part of balance of CNYA and CNYW into Pool and get the LP
```bash
$ sui client call --package $AMMPKG \
                  --module interface \
                  --function deposit_partly \
                  --gas-budget 1000000000 \
                  --type-args $CNYA $CNYW \
                  --args $POOLID \
                         '["0x745a51f5ef3ac9e9145bda044175d1ec1101df5c","0xbf267e927fde098e948bdbd38f5cda51059e90f1"]' \
                         '["0x51ce85d6da1e582bbec29a9ad510c9d8777da4be","0x87f08438c6b92f2cb48a5e4f43f364d7dc7cd58d"]' \
                         140000000 150000000 $POCKETID
```

### Withdraw all the balance from LP
```bash
$ sui client call --package $AMMPKG \
                  --module interface \
                  --function withdraw_totally \
                  --gas-budget 1000000000 \
                  --type-args $CNYA $CNYW \
                  --args $POOLID \
                         0x5d09ba5a1cc3bea11c2e2e8eff89c42409fcc670 \
                         $POCKETID
```

### Withdraw part of balance from LP
```bash
$ sui client call --package $AMMPKG \
                  --module interface \
                  --function withdraw_out \
                  --gas-budget 1000000000 \
                  --type-args $CNYA $CNYW \
                  --args $POOLID \
                         '["0x8a130a1f9f1137a7bae329bf9861e7dcd9835bb3","0x9521753a2781194ab2e5bd4154904d4d75905eee"]' \
                         170000000 180000000 $POCKETID
```

### Swap Coin X to Coin Y
```bash
$ sui client call --package $AMMPKG \
                  --module interface \
                  --function swap_x_to_y \
                  --gas-budget 1000000000 \
                  --type-args $CNYA $CNYW \
                  --args $POOLID \
                         '["0xfcaed55cbb6a2f85815867c711d8c6bd2037f1cc","0x60dabbe408386294c54fcb0fa235735db1289227"]' \
                         100000000
```


### Swap Coin Y to Coin X
```bash
$ sui client call --package $AMMPKG \
                  --module interface \
                  --function swap_y_to_x \
                  --gas-budget 1000000000 \
                  --type-args $CNYA $CNYW \
                  --args $POOLID \
                         '["0xfcaed55cbb6a2f85815867c711d8c6bd2037f1cc","0x60dabbe408386294c54fcb0fa235735db1289227"]' \
                         100000000
```
