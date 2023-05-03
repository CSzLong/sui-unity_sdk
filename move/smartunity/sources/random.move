module smartunity::random {
    use std::hash::sha2_256;
    use std::vector;

    use sui::object::{Self, uid_to_bytes};
    use sui::tx_context::TxContext;

    const EInvalidSeed: u64 = 3;

    friend smartunity::interface;

    public(friend) fun randint(n: u64, ctx: &mut TxContext): u64 {
        let test_id = object::new(ctx);
        let rnd = sha2_256(uid_to_bytes(&test_id));
        assert!(vector::length(&rnd) >= 16, EInvalidSeed);
        let m: u128 = 0;
        let i = 0;
        while (i < 16) {
            m = m << 8;
            let curr_byte = *vector::borrow(&rnd, i);
            m = m + (curr_byte as u128);
            i = i + 1;
        };
        let n_128 = (n as u128);
        let module_128 = m % n_128;
        let res = (module_128 as u64);
        object::delete(test_id);
        if (res != 0) {
            res << 1
        }else {
            1
        }
    }
}