pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;
import "dop.sol";
contract Todo {
    /*
     * ERROR CODES
     * 100 - Unauthorized
     * 102 - task not found
     */
    modifier onlyOwner() {
        require(msg.pubkey() == m_ownerPubkey, 101);
        _;
    }

    uint32 m_count;
    mapping(uint32 => Purchase) m_purchases;
    uint256 m_ownerPubkey;

    constructor( uint256 pubkey) public {
        require(pubkey != 0, 120);
        tvm.accept();
        m_ownerPubkey = pubkey;
    }

    function addPurchase(string text, uint32 number) public onlyOwner {
        tvm.accept();
        m_count++;
        m_purchases[m_count] = Purchase(m_count, text, number, now, false, 0);
    }

    function buyPurchase(uint32 id, uint32 price) public onlyOwner {
        optional(Purchase) purchase = m_purchases.fetch(id);
        require(purchase.hasValue(), 102);
        tvm.accept();
        Purchase thisPurchase = purchase.get();
        thisPurchase.totalPrice = thisPurchase.number*price;
        thisPurchase.isBuy = true;
        m_purchases[id] = thisPurchase;
    }

    function deletePurchase(uint32 id) public onlyOwner {
        require(m_purchases.exists(id), 102);
        tvm.accept();
        delete m_purchases[id];
    }

    function getPurchases() public view returns (Purchase[] purchases) {
        string text;
        uint32 number;
        uint64 createdAt;
        bool isBuy;
        uint32 totalPrice;

        for((uint32 id, Purchase purchase) : m_purchases) {
            text = purchase.text;
            number = purchase.number;
            createdAt = purchase.createdAt;
            isBuy = purchase.isBuy;
            totalPrice = purchase.totalPrice;
            purchases.push(Purchase(id, text, number, createdAt, isBuy, totalPrice));
       }
    }

    function getStat() public view returns (Stat stat) {
        uint32 paidCount;
        uint32 unpaidCount;
        uint32 totalPaid;

        for((, Purchase purchase) : m_purchases) {
            if  (purchase.isBuy) {
                paidCount = paidCount + purchase.number;
                totalPaid = totalPaid + purchase.totalPrice;
            } else {
                unpaidCount = unpaidCount + purchase.number;
            }
        }
        stat = Stat(paidCount, unpaidCount, totalPaid);
    }
}

