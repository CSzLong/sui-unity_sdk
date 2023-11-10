module smartunity::nft_owner {
    use sui::object::{ID, UID};
    use sui::table::Table;
    use sui::tx_context::{TxContext, sender};
    use sui::object;
    use sui::table;
    use sui::transfer::transfer;

    /// NftHolder holds NFT deposit information
    struct NftHolder has store, drop {
        kiosk_id: ID,
        owner: address
    }

    /// Collection for NftHolder
    /// IDs are NFT ids.
    struct NftHolderOwner has key {
        id: UID,
        nftholder: Table<ID, NftHolder>
    }

    /// Initalize the NftHolderOnwer and send to
    /// address that deposits the NFT
    public fun new(ctx: &mut TxContext): ID {
        let nftholderOwner = NftHolderOwner {
            id: object::new(ctx),
            nftholder: table::new<ID, NftHolder>(ctx),
        };
        let holder_id = object::id(&nftholderOwner);
        transfer(nftholderOwner, sender(ctx));
        holder_id
    }

    /// Remove the NFT deposit information from NFT Holder Collection
    public fun remove_nftholder(self: NftHolderOwner, id: ID, ctx: &TxContext) {
        let _nftholder = table::remove(&mut self.nftholder, id);
        transfer(self, sender(ctx));
    }

    /// Add new NFT deposit information from NFT Holder Collection
    public fun add_nftholder(self: NftHolderOwner, id: ID, kiosk_id: ID, ctx: &TxContext){
        let nftholder = NftHolder {
            kiosk_id,
            owner: sender(ctx),
        };
        table::add(&mut self.nftholder, id, nftholder);
        transfer(self, sender(ctx));
    }
}
