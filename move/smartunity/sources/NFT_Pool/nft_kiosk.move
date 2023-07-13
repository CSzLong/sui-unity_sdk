module smartunity::nft_kiosk {
    use std::type_name::{get, TypeName};

    use smartunity::trading;

    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::kiosk::Kiosk;
    use sui::object::{Self, UID, ID};
    use sui::transfer::{Self, public_transfer};
    use sui::tx_context::{TxContext, sender};

    /// Error code for Not Enough payment
    const ENotEnoughFeeToPay: u64 = 1001;
    /// Error code for Invalid Coin Type when swap
    const ETransactionCoinNotInPool: u64 = 1002;
    /// Error code for Not Enough Coin X
    const ENotEnoughCoinX: u64 = 1003;
    /// Error code for Not Enough Coin Y
    const ENotEnoughCoinY: u64 = 1004;
    /// Error code for Not Enough Coin Z
    const ENotEnoughCoinZ: u64 = 1005;
    /// Error code for Not Enough balance in pool to swap
    const ENotEnoughBalanceInPool: u64 = 1006;
    /// Error code for Invalid Transaction Coin Type to Pay
    const EInvalidTrasnactionCoinType: u64 = 1007;
    /// Kiosk not in Trading Pool
    const ECollectionNotInTradingPool: u64 = 1008;

    /// Trading Pool for swap
    /// account: the address to receive the fee paied by transaction maker
    /// collection: collection holds the NFT items
    /// curve_type
    /// delta: price delta
    /// fee: fee of transactions, transaction maker pays it and send to address
    /// coin: transaction coin type
    /// init_price: NFT initialize price
    /// coin_sui, coin_stable, coin_self: balance of coin X,Y,Z
    struct TradePool<phantom X, phantom Y, phantom Z> has key, store {
        id: UID,
        account: address,
        collection: ID,
        curve_type: vector<u8>,
        fee: u64,
        coin: TypeName,
        init_price: u64,
        coin_sui: Balance<X>,
        coin_stable: Balance<Y>,
        coin_self: Balance<Z>,
    }

    /// generate the trading pool after deposit the NFTs
    public entry fun create_pair_nft_trade_pool<X, Y, Z, T, NFT: key + store>(
        collection: &mut Kiosk,
        curve_type: vector<u8>,
        fee: u64,
        init_price: u64,
        nft: NFT,
        ctx: &mut TxContext,
    ): ID {
        deposit_nft(collection, nft, ctx);
        let new_pool = TradePool<X, Y, Z> {
            id: object::new(ctx),
            account: sender(ctx),
            collection: object::id(collection),
            curve_type,
            coin: get<T>(),
            fee,
            init_price,
            coin_sui: balance::zero(),
            coin_stable: balance::zero(),
            coin_self: balance::zero(),
        };
        let pool_id = object::id(&new_pool);
        transfer::share_object(new_pool);
        pool_id
    }

    /// Initialize the user's account
    public fun initialize_account(ctx: &mut TxContext): ID {
        let kiosk_id = trading::create_kiosk(ctx);
        kiosk_id
    }

    /// Function to deposit the NFT to Kiosk
    public fun deposit_nft<NFT: key + store>(kiosk: &mut Kiosk,
                                             nft: NFT,
                                             ctx: &mut TxContext) {
        trading::deposit_nft(kiosk, nft, ctx);
    }

    /// Function to pay the fee
    fun pay<T>(payment: Coin<T>, amount: u64, reciptant: address, ctx: &mut TxContext) {
        assert!(coin::value(&payment) >= amount, ENotEnoughFeeToPay);
        public_transfer(coin::split(&mut payment, amount, ctx), reciptant);
        public_transfer(payment, sender(ctx));
    }

    /// Split the balance of `T` from Pool
    /// and send to transaction maker when swap the NFT in
    fun split_from_balance<T>(self: &mut Balance<T>, amount: u64, ctx: &mut TxContext) {
        assert!(balance::value(self) >= amount, ENotEnoughBalanceInPool);
        let coin_t = coin::zero<T>(ctx);
        coin::join(&mut coin_t, coin::take<T>(self, amount, ctx));
        public_transfer(coin_t, sender(ctx));
    }

    /// Add the balance of `T` into pool
    /// after swap the NFT out
    fun add_to_balance<T>(self: &mut Balance<T>, coin_t: Coin<T>, amount: u64, ctx: &mut TxContext) {
        let coin_self_in = coin::split(&mut coin_t, amount, ctx);
        coin::put(self, coin_self_in);
        public_transfer(coin_t, sender(ctx));
    }

    /// Swap Coin X by NFTs
    public entry fun swap_sui_for_nfts<X, Y, Z, T, NFT: key + store>(trade_pool: &mut TradePool<X, Y, Z>,
                                                                     kiosk: &mut Kiosk,
                                                                     nft_id: ID,
                                                                     payment: Coin<T>,
                                                                     coin_sui: Coin<X>,
                                                                     ctx: &mut TxContext
    ) {
        assert!(get<T>() == trade_pool.coin, EInvalidTrasnactionCoinType);
        assert!(coin::value(&coin_sui) >= trade_pool.init_price, ENotEnoughCoinX);
        assert!(object::id(kiosk) == trade_pool.collection, ECollectionNotInTradingPool);
        pay(payment, trade_pool.fee, trade_pool.account, ctx);
        trading::withdraw_nft<NFT>(kiosk, nft_id, ctx);
        add_to_balance<X>(&mut trade_pool.coin_sui, coin_sui, trade_pool.init_price, ctx);
    }

    /// Swap Coin Y by NFTs
    public entry fun swap_stable_coin_for_nfts<X, Y, Z, T, NFT: key + store>(trade_pool: &mut TradePool<X, Y, Z>,
                                                                             kiosk: &mut Kiosk,
                                                                             nft_id: ID,
                                                                             payment: Coin<T>,
                                                                             coin_stable: Coin<Y>,
                                                                             ctx: &mut TxContext
    ) {
        assert!(get<T>() == trade_pool.coin, EInvalidTrasnactionCoinType);
        assert!(coin::value(&coin_stable) >= trade_pool.init_price, ENotEnoughCoinX);
        assert!(object::id(kiosk) == trade_pool.collection, ECollectionNotInTradingPool);
        pay(payment, trade_pool.fee, trade_pool.account, ctx);
        trading::withdraw_nft<NFT>(kiosk, nft_id, ctx);
        add_to_balance<Y>(&mut trade_pool.coin_stable, coin_stable, trade_pool.init_price, ctx);
    }

    /// Swap Coin Z by NFTs
    public entry fun swap_self_coin_for_nfts<X, Y, Z, T, NFT: key + store>(trade_pool: &mut TradePool<X, Y, Z>,
                                                                           kiosk: &mut Kiosk,
                                                                           nft_id: ID,
                                                                           payment: Coin<T>,
                                                                           coin_self: Coin<Z>,
                                                                           ctx: &mut TxContext
    ) {
        assert!(get<T>() == trade_pool.coin, EInvalidTrasnactionCoinType);
        assert!(coin::value(&coin_self) >= trade_pool.init_price, ENotEnoughCoinX);
        assert!(object::id(kiosk) == trade_pool.collection, ECollectionNotInTradingPool);
        pay(payment, trade_pool.fee, trade_pool.account, ctx);
        trading::withdraw_nft<NFT>(kiosk, nft_id, ctx);
        add_to_balance<Z>(&mut trade_pool.coin_self, coin_self, trade_pool.init_price, ctx);
    }

    /// Withdraw the NFT by the person who deposited it.
    public entry fun withdraw_nft<X, Y, Z, T, NFT: key + store>(trade_pool: &mut TradePool<X, Y, Z>,
                                                                kiosk: &mut Kiosk,
                                                                nft_id: ID,
                                                                ctx: &mut TxContext) {
        assert!(object::id(kiosk) == trade_pool.collection, ECollectionNotInTradingPool);
        trading::withdraw_nft<NFT>(kiosk, nft_id, ctx);
    }

    /// Swap the Coin X, Y, Z by deposit the NFT to pool
    public fun withdraw_coin<X, Y, Z, T, TCOIN, NFT: key + store>(trade_pool: &mut TradePool<X, Y, Z>,
                                                                  kiosk: &mut Kiosk,
                                                                  nft: NFT,
                                                                  payment: Coin<T>,
                                                                  ctx: &mut TxContext) {
        assert!(
            get<TCOIN>() == get<X>() || get<TCOIN>() == get<Y>() || get<TCOIN>() == get<Z>(),
            ETransactionCoinNotInPool
        );
        assert!(get<T>() == trade_pool.coin, EInvalidTrasnactionCoinType);
        assert!(object::id(kiosk) == trade_pool.collection, ECollectionNotInTradingPool);
        pay(payment, trade_pool.fee, trade_pool.account, ctx);
        deposit_nft<NFT>(kiosk, nft, ctx);
        if (get<TCOIN>() == get<X>()) {
            split_from_balance<X>(&mut trade_pool.coin_sui, trade_pool.init_price, ctx);
        };
        if (get<TCOIN>() == get<Y>()) {
            split_from_balance<Y>(&mut trade_pool.coin_stable, trade_pool.init_price, ctx);
        };
        if (get<TCOIN>() == get<Z>()) {
            split_from_balance<Z>(&mut trade_pool.coin_self, trade_pool.init_price, ctx);
        };
    }
}