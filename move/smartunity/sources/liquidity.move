module smartunity::liquidity {
    use std::vector;

    use sui::balance::{Self, Supply, Balance};
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID, ID};
    use sui::pay;
    use sui::table::{Self, Table};
    use sui::transfer;
    use sui::tx_context::{TxContext, sender};

    friend smartunity::interface;

    ///When Coin is zero
    const ErrZeroAmount: u64 = 1001;
    ///Insufficient Coin X in pool
    const ErrNotEnoughXInPool: u64 = 1002;
    ///Insufficient Coin Y in pool
    const ErrNotEnoughYInPool: u64 = 1003;
    ///When vector length is not 2
    const ErrInvalidVecotrType: u64 = 1004;
    ///When balance in LP doesn't match summary in vector
    const ErrBalanceNotMatch: u64 = 1005;
    ///When balance in LP is not sufficient to withdraw
    const ErrNotEnoughBalanceLP: u64 = 1006;
    ///When withdraw failed
    const ErrRemoveFailed: u64 = 1011;
    ///When Liquidity provider vector is empty
    const ErrEmptyLPVector: u64 = 1012;

    ///Liquidity provider, parameter 'X' and 'Y'
    ///are coins held in the pool.
    struct LP<phantom X, phantom Y> has drop {}

    /// Pool with exchange
    struct Pool<phantom X, phantom Y> has key {
        id: UID,
        coin_x: Balance<X>,
        coin_y: Balance<Y>,
        lp_supply: Supply<LP<X, Y>>
    }

    ///pocket to keep the Liquidity provider
    ///and balance of Coin X/Y
    struct Pocket has key, store {
        id: UID,
        table: Table<ID, vector<u64>>
    }


    ///function to create new pocket
    public(friend) fun create_pocket(ctx: &mut TxContext) {
        let pocket = Pocket {
            id: object::new(ctx),
            table: table::new<ID, vector<u64>>(ctx)
        };
        transfer::transfer(pocket, sender(ctx));
    }

    ///friend function to update the pocket
    public(friend) fun update_pocket(pocket: &mut Pocket, id: ID, vec: vector<u64>) {
        table::add(&mut pocket.table, id, vec);
    }

    ///create a new pool
    public(friend) fun new_pool<X, Y>(ctx: &mut TxContext) {
        let new_pool = Pool<X, Y> {
            id: object::new(ctx),
            coin_x: balance::zero(),
            coin_y: balance::zero(),
            lp_supply: balance::create_supply<LP<X, Y>>(LP {})
        };
        transfer::share_object(new_pool);
    }

    ///Add liquidity into pool, exchange rate is 1 between X and Y
    public(friend) fun add_liquidity<X, Y>(pool: &mut Pool<X, Y>,
                                           coin_x: Coin<X>,
                                           coin_y: Coin<Y>,
                                           ctx: &mut TxContext): (Coin<LP<X, Y>>, vector<u64>) {
        let coin_x_value = coin::value(&coin_x);
        let coin_y_value = coin::value(&coin_y);
        assert!(coin_x_value > 0 && coin_y_value > 0, ErrZeroAmount);
        coin::put(&mut pool.coin_x, coin_x);
        coin::put(&mut pool.coin_y, coin_y);
        let lp_bal = balance::increase_supply(&mut pool.lp_supply, coin_x_value + coin_y_value);
        let vec_value = vector::empty<u64>();
        vector::push_back(&mut vec_value, coin_x_value);
        vector::push_back(&mut vec_value, coin_y_value);
        (coin::from_balance(lp_bal, ctx), vec_value)
    }

    ///Remove the liquidity and balance from pool
    public(friend) fun remove_liquidity<X, Y>(pool: &mut Pool<X, Y>,
                                              lp: Coin<LP<X, Y>>,
                                              vec: vector<u64>,
                                              ctx: &mut TxContext): (Coin<X>, Coin<Y>) {
        assert!(vector::length(&vec) == 2, ErrInvalidVecotrType);
        let lp_balance_value = coin::value(&lp);
        let coin_x_out = *vector::borrow(&vec, 0);
        let coin_y_out = *vector::borrow(&vec, 1);
        assert!(lp_balance_value == coin_x_out + coin_y_out, ErrBalanceNotMatch);
        assert!(balance::value(&pool.coin_x) > coin_x_out, ErrNotEnoughXInPool);
        assert!(balance::value(&pool.coin_y) > coin_y_out, ErrNotEnoughYInPool);
        balance::decrease_supply(&mut pool.lp_supply, coin::into_balance(lp));
        (
            coin::take(&mut pool.coin_x, coin_x_out, ctx),
            coin::take(&mut pool.coin_y, coin_y_out, ctx)
        )
    }

    ///entry function Withdraw all balance in Liquidity provider from pool
    public(friend) fun remove_liquidity_totally<X, Y>(pool: &mut Pool<X, Y>,
                                                      lp: Coin<LP<X, Y>>,
                                                      pocket: &mut Pocket,
                                                      ctx: &mut TxContext) {
        let lp_id = object::id(&lp);
        let vec = *table::borrow(&pocket.table, lp_id);
        let (coin_x_out, coin_y_out) = remove_liquidity(pool, lp, vec, ctx);
        assert!(coin::value(&coin_x_out) > 0 && coin::value(&coin_y_out) > 0, ErrRemoveFailed);
        let vec_out = table::remove(&mut pocket.table, lp_id);
        vector::remove(&mut vec_out, 0);
        vector::remove(&mut vec_out, 0);
        let sender_address = sender(ctx);
        transfer::public_transfer(coin_x_out, sender_address);
        transfer::public_transfer(coin_y_out, sender_address);
    }

    ///withdraw coin from balance
    public(friend) fun withdraw<X, Y>(pool: &mut Pool<X, Y>,
                                      lp: &mut Coin<LP<X, Y>>,
                                      vec: &mut vector<u64>,
                                      coin_x_out: u64,
                                      coin_y_out: u64,
                                      ctx: &mut TxContext): (Coin<X>, Coin<Y>) {
        assert!(balance::value(&pool.coin_x) > coin_x_out, ErrNotEnoughXInPool);
        assert!(balance::value(&pool.coin_y) > coin_y_out, ErrNotEnoughYInPool);
        assert!(coin::value(lp) >= coin_x_out + coin_y_out, ErrNotEnoughBalanceLP);
        let coin_x_balance = vector::borrow_mut(vec, 0);
        *coin_x_balance = *coin_x_balance - coin_x_out;
        let coin_y_balance = vector::borrow_mut(vec, 1);
        *coin_y_balance = *coin_y_balance - coin_y_out;
        let lp_split = coin::split(lp, coin_x_out + coin_y_out, ctx);
        balance::decrease_supply(&mut pool.lp_supply, coin::into_balance(lp_split));
        (
            coin::take(&mut pool.coin_x, coin_x_out, ctx),
            coin::take(&mut pool.coin_y, coin_y_out, ctx)
        )
    }

    ///swap Coin X to Y, return Coin Y
    public(friend) fun swap_x_outto_y<X, Y>(pool: &mut Pool<X, Y>,
                                            paid_in: Coin<X>,
                                            ctx: &mut TxContext): Coin<Y> {
        let paid_value = coin::value(&paid_in);
        coin::put(&mut pool.coin_x, paid_in);
        assert!(paid_value < balance::value(&pool.coin_y), ErrNotEnoughYInPool);
        coin::take(&mut pool.coin_y, paid_value, ctx)
    }

    ///swap Coin Y to X, return Coin X
    public(friend) fun swap_y_into_x<X, Y>(pool: &mut Pool<X, Y>,
                                           paid_in: Coin<Y>,
                                           ctx: &mut TxContext): Coin<X> {
        let paid_value = coin::value(&paid_in);
        coin::put(&mut pool.coin_y, paid_in);
        assert!(paid_value < balance::value(&pool.coin_x), ErrNotEnoughXInPool);
        coin::take(&mut pool.coin_x, paid_value, ctx)
    }

    ///combine multiple liquidity providers
    public(friend) fun join_lp_vec<X, Y>(lp_vec: vector<Coin<LP<X, Y>>>,
                                         pocket: &mut Pocket,
                                         ctx: &mut TxContext): (Coin<LP<X, Y>>, vector<u64>) {
        let idx = 0;
        let vec_length = vector::length(&lp_vec);
        assert!(vec_length > 0, ErrEmptyLPVector);
        let (combined_lp, combined_vec, combined_x_amt, combined_y_amt) =
            (coin::zero<LP<X, Y>>(ctx), vector::empty<u64>(), (0 as u64), (0 as u64));
        while (idx < vec_length) {
            let lp_out = vector::pop_back(&mut lp_vec);
            let lp_id = object::id(&lp_out);
            let vec_out = table::remove(&mut pocket.table, lp_id);
            combined_y_amt = combined_y_amt + vector::pop_back(&mut vec_out);
            combined_x_amt = combined_x_amt + vector::pop_back(&mut vec_out);
            vector::destroy_empty(vec_out);
            pay::join(&mut combined_lp, lp_out);
            idx = idx + 1;
        };
        vector::destroy_empty(lp_vec);
        vector::push_back(&mut combined_vec, combined_x_amt);
        vector::push_back(&mut combined_vec, combined_y_amt);
        (combined_lp, combined_vec)
    }
}