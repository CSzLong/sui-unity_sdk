module smartunity::flag {
    use std::ascii::into_bytes;
    use std::string::{Self, String};
    use std::type_name::{get, into_string};

    use sui::object::{Self, UID, ID};
    use sui::table::{Self, Table};
    use sui::transfer;
    use sui::tx_context::TxContext;

    friend smartunity::interface;

    struct Flag has key {
        id: UID,
        coin: Table<ID, String>
    }

    fun init(ctx: &mut TxContext) {
        let coin = table::new<ID, String>(ctx);
        let flag = Flag {
            id: object::new(ctx),
            coin,
        };
        transfer::share_object(flag);
    }

    public(friend) fun add<Coin>(flag: &mut Flag, id: ID) {
        table::add(&mut flag.coin, id, get_name<Coin>());
    }

    public(friend) fun exists_coin(flag: &Flag, id: ID): bool {
        table::contains(&flag.coin, id)
    }

    public fun get_name<Coin>(): String {
        let name = get<Coin>();
        let str = string::utf8(b"");
        string::append_utf8(&mut str, into_bytes(into_string(name)));
        str
    }
}