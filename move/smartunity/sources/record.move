module smartunity::record {

    use sui::object::{Self, UID, ID};
    use sui::transfer;
    use sui::tx_context::{TxContext, sender};

    friend smartunity::interface;

    //const ErrOverflow: u64 = 2001;
    const ErrNotEnough: u64 = 2002;

    struct Record has key, store {
        id: UID,
        begin_score: u64,
        score: u64
    }

    public(friend) fun create(ctx: &mut TxContext): ID {
        let record = Record {
            id: object::new(ctx),
            begin_score: 0,
            score: 0
        };
        let record_id = object::id(&record);
        transfer::transfer(
            record,
            sender(ctx)
        );
        record_id
    }

    public(friend) fun increase_score(self: &mut Record, value: u64) {
        self.score = self.score + value;
    }

    spec increase_score {
        ensures self.score == old(self.score) + value;
    }

    public(friend) fun decrease_score(self: &mut Record, value: u64) {
        assert!(self.score >= value, ErrNotEnough);
        self.score = self.score - value;
    }

    spec decrease_score {
        aborts_if self.score >= value with ErrNotEnough;
        ensures self.score == old(self.score) - value;
    }

    public(friend) fun increase_begin_score(self: &mut Record, value: u64) {
        self.begin_score = self.begin_score + value;
    }

    spec increate_begin_score {
        ensures self.begin_score == old(self.begin_score) + value;
    }
}