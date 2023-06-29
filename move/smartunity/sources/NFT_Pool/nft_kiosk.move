module smartunity::nft_kiosk {

    use sui::object::{Self, ID};
    use sui::tx_context::{TxContext, sender};
    use sui::transfer::{public_share_object, public_transfer};
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap, uid_mut};
    use sui::dynamic_field::{Self as df};
    use sui::vec_set::{Self, VecSet};
    use sui::table::{Self};

    /// Trying to withdraw profits and sender is not owner
    const ENotOwner :u64 = 1001;
    const ENotAuthorized :u64 = 1002;

    /// For `Kiosk::id` value `Table<ID, NftRef>`
    struct NftRefsDfKey has store, copy, drop {}
    /// Hold the `KioskOwnerCap`
    struct KioskOwnerCapDfKey has store, copy, drop {}

    /// Stored as dynamic field for `NftRefsDfKey`
    /// Holds NFT's information
    struct NftRef has store, drop{
        auths: VecSet<address>,
        is_excusively_listed: bool,
    }

    /// Create `Kiosk` for the sender and share it
    public fun create_kiosk(ctx: &mut TxContext): ID{
        let owner = sender(ctx);
        let (kiosk, kiosk_cap) = kiosk::new(ctx);
        let kiosk_id = object::id(&kiosk);
        kiosk::set_owner_custom(&mut kiosk, &kiosk_cap, owner);
        insert_extension(&mut kiosk, kiosk_cap, ctx);
        public_share_object(kiosk);
        kiosk_id
    }


    fun insert_extension(
        self: &mut Kiosk,
        kiosk_cap: KioskOwnerCap,
        ctx: &mut TxContext,
    ) {
        assert!(kiosk::has_access(self, &kiosk_cap), ENotOwner);
        let kiosk_ext = uid_mut(self);
        df::add(kiosk_ext, KioskOwnerCapDfKey {}, kiosk_cap);
        df::add(kiosk_ext, NftRefsDfKey {}, table::new<ID, NftRef>(ctx));
    }

    public fun is_owner(self: &Kiosk, address: address): bool {
        let owner = kiosk::owner(self);
        owner == address
    }

    public fun deposit_nft<NFT: key + store>(
        self: &mut Kiosk,
        nft: NFT,
        _ctx: &mut TxContext,
    ) {
        let nft_id = object::id(&nft);
        let refs = df::borrow_mut(uid_mut(self), NftRefsDfKey{});
        table::add(refs, nft_id, NftRef{
            auths: vec_set::empty(),
            is_excusively_listed: false,
        });
        let cap = pop_cap(self);
        kiosk::place(self, &cap, nft);
        set_cap(self, cap);
    }


    public fun withdraw_nft<NFT: key + store>(
        self: &mut Kiosk,
        nft_id: ID,
        ctx: &mut TxContext
    ){
        let refs = df::borrow_mut(uid_mut(self), NftRefsDfKey{});
        let _ref: NftRef = table::remove(refs, nft_id);
        assert!(is_owner(self, sender(ctx)),ENotAuthorized);
        let cap = pop_cap(self);
        let nft = kiosk::take<NFT>(self, &cap, nft_id);
        set_cap(self, cap);
        public_transfer(nft, sender(ctx));
    }

    /// Pop `KioskOwnerCap` from within the `Kiosk`
    fun pop_cap(self: &mut Kiosk): KioskOwnerCap {
        df::remove(uid_mut(self), KioskOwnerCapDfKey {})
    }

    /// Return `KioskOwnerCap` to the `Kiosk`
    fun set_cap(self: &mut Kiosk, cap: KioskOwnerCap) {
        df::add(uid_mut(self), KioskOwnerCapDfKey {}, cap);
    }
}
