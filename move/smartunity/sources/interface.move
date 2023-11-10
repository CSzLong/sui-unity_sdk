module smartunity::interface {
    use smartunity::flag::{Self, Flag};
    use smartunity::gcoin::{Self, GCOIN};
    use smartunity::liquidity::{Self, Pool, Pocket, LP};
    use smartunity::record::{Self, Record};
    use sui::balance;
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::event;
    use sui::object::{Self, ID};
    use sui::pay;
    use sui::sui::SUI;
    use sui::transfer;
    use sui::tx_context::{TxContext, sender};

    struct Returned has copy, drop {
        coin_id: ID,
        record_id: ID
    }

    /*
    struct Score has copy, drop {
        score: u64
    }*/

    struct Property has copy, drop {
        lp_id: ID
    }

    const ErrCoin_Exist: u64 = 2003;
    const ErrNot_Enough_Coin: u64 = 2004;
    const GAMEADDR: address = @0x7ca598a4eb9a9aea07720bb18e3fad68581f6712ab5517b798cc12c9edcc303f;

    public entry fun init_coin(flag: &mut Flag,
                               ctx: &mut TxContext) {
        assert!(!flag::exists_coin(flag, object::id_from_address(sender(ctx))), ErrCoin_Exist);
        let zero_coin = coin::zero<GCOIN>(ctx);
        let coin_id = object::id(&zero_coin);
        transfer::public_transfer(zero_coin, sender(ctx));
        flag::add<GCOIN>(flag, object::id_from_address(sender(ctx)));
        let record_id = record::create(ctx);
        event::emit(Returned { coin_id, record_id })
    }

    public entry fun increase_score(record: &mut Record, value: u64) {
        record::increase_score(record, value);
    }

    public entry fun decrease_score(record: &mut Record, value: u64) {
        record::decrease_score(record, value);
    }

    public entry fun increase_begin_score(record: &mut Record, value: u64) {
        record::increase_begin_score(record, value);
    }

    public entry fun buy_coin(coin: &mut Coin<GCOIN>,
                              payment: &mut Coin<SUI>,
                              amount: u64,
                              cap: &mut TreasuryCap<GCOIN>,
                              ctx: &mut TxContext) {
        assert!(coin::value(payment) >= amount, ErrNot_Enough_Coin);
        let coin_balance = coin::balance_mut(payment);
        let paid_coin = balance::split(coin_balance, amount);
        transfer::public_transfer(coin::from_balance<SUI>(paid_coin, ctx), GAMEADDR);
        coin::join(coin, coin::mint(cap, amount, ctx));
    }

    public entry fun gain_coin(
        coin: &mut Coin<GCOIN>,
        cap: &mut TreasuryCap<GCOIN>,
        value: u64,
        ctx: &mut TxContext) {
        gcoin::join_coin(coin, cap, value, ctx);
    }

    ///entry function to generate new pool
    public entry fun generate_pool<X, Y>(ctx: &mut TxContext) {
        liquidity::new_pool<X, Y>(ctx);
    }

    public entry fun create_pocket(ctx: &mut TxContext) {
        liquidity::create_pocket(ctx);
    }

    ///entry function to deposit total Coin X and Y to pool
    public entry fun deposit_totally<X, Y>(pool: &mut Pool<X, Y>,
                                           coin_x: Coin<X>,
                                           coin_y: Coin<Y>,
                                           pocket: &mut Pocket,
                                           ctx: &mut TxContext) {
        let (lp, vec) = liquidity::add_liquidity(pool, coin_x, coin_y, ctx);
        let lp_id = object::id(&lp);
        liquidity::update_pocket(pocket, lp_id, vec);
        transfer::public_transfer(lp, sender(ctx));
        event::emit(Property { lp_id })
    }

    ///entry function to deposit part of Coin X and Y to pool
    public entry fun deposit_partly<X, Y>(pool: &mut Pool<X, Y>,
                                          coin_x_vec: vector<Coin<X>>,
                                          coin_y_vec: vector<Coin<Y>>,
                                          coin_x_amt: u64,
                                          coin_y_amt: u64,
                                          pocket: &mut Pocket,
                                          ctx: &mut TxContext) {
        let coin_x_new = coin::zero<X>(ctx);
        let coin_y_new = coin::zero<Y>(ctx);
        pay::join_vec(&mut coin_x_new, coin_x_vec);
        pay::join_vec(&mut coin_y_new, coin_y_vec);
        let coin_x_in = coin::split(&mut coin_x_new, coin_x_amt, ctx);
        let coin_y_in = coin::split(&mut coin_y_new, coin_y_amt, ctx);
        let (lp, vec) = liquidity::add_liquidity(pool, coin_x_in, coin_y_in, ctx);
        let lp_id = object::id(&lp);
        liquidity::update_pocket(pocket, lp_id, vec);
        transfer::public_transfer(lp, sender(ctx));
        let sender_address = sender(ctx);
        if (coin::value(&coin_x_new) == 0) {
            coin::destroy_zero(coin_x_new);
        }else {
            transfer::public_transfer(coin_x_new, sender_address);
        };
        if (coin::value(&coin_y_new) == 0) {
            coin::destroy_zero(coin_y_new);
        }else {
            transfer::public_transfer(coin_y_new, sender_address);
        };
    }

    ///entry function Withdraw all balance in Liquidity provider from pool
    public entry fun withdraw_totally<X, Y>(pool: &mut Pool<X, Y>,
                                                    lp: Coin<LP<X, Y>>,
                                                    pocket: &mut Pocket,
                                                    ctx: &mut TxContext) {
        liquidity::remove_liquidity_totally(pool, lp, pocket, ctx);
    }

    ///Withdraw part of balance in liquidity provider from pool
    public entry fun withdraw_out<X, Y>(pool: &mut Pool<X, Y>,
                                        lp_vec: vector<Coin<LP<X, Y>>>,
                                        coin_x_amt: u64,
                                        coin_y_amt: u64,
                                        pocket: &mut Pocket,
                                        ctx: &mut TxContext) {
        let (combined_lp, combined_vec) = liquidity::join_lp_vec(lp_vec, pocket, ctx);
        let (withdraw_coin_x, withdraw_coin_y) =
            liquidity::withdraw(pool, &mut combined_lp, &mut combined_vec, coin_x_amt, coin_y_amt, ctx);
        let combined_lp_id = object::id(&combined_lp);
        liquidity::update_pocket(pocket, combined_lp_id, combined_vec);
        let sender_address = sender(ctx);
        transfer::public_transfer(withdraw_coin_x, sender_address);
        transfer::public_transfer(withdraw_coin_y, sender_address);
        transfer::public_transfer(combined_lp, sender_address);
    }

    public entry fun swap_x_to_y<X, Y>(pool: &mut Pool<X, Y>,
                                       coin_x_vec: vector<Coin<X>>,
                                       amount: u64,
                                       ctx: &mut TxContext) {
        let coin_x = coin::zero<X>(ctx);
        pay::join_vec<X>(&mut coin_x, coin_x_vec);
        let coin_x_in = coin::split(&mut coin_x, amount, ctx);
        let coin_y_out = liquidity::swap_x_outto_y(pool, coin_x_in, ctx);
        let sender_addres = sender(ctx);
        transfer::public_transfer(coin_x, sender_addres);
        transfer::public_transfer(coin_y_out, sender_addres);
    }

    public entry fun swap_y_to_x<X, Y>(pool: &mut Pool<X, Y>,
                                       coin_y_vec: vector<Coin<Y>>,
                                       amount: u64,
                                       ctx: &mut TxContext) {
        let coin_y = coin::zero<Y>(ctx);
        pay::join_vec<Y>(&mut coin_y, coin_y_vec);
        let coin_y_in = coin::split(&mut coin_y, amount, ctx);
        let coin_x_out = liquidity::swap_y_into_x(pool, coin_y_in, ctx);
        let sender_addres = sender(ctx);
        transfer::public_transfer(coin_x_out, sender_addres);
        transfer::public_transfer(coin_y, sender_addres);
    }
}