pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "listDebot.sol";

contract fillingDebot is listDebot {

    function _menu() internal override {
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "You have {}/{} (unpaid/paid) purhases. Total price of purchases {}",
                    m_stat.unpaidCount,
                    m_stat.paidCount,
                    m_stat.totalPaid
            ),
            sep,
            [
                MenuItem("Add new purchase","",tvm.functionId(addPurchase)),
                MenuItem("Show shopping list","",tvm.functionId(showPurchases)),
                MenuItem("Delete purchase","",tvm.functionId(deletePurchase))
            ]
        );
    }
    
    function addPurchase(uint32 index) public {
        index = index;
        Terminal.input(tvm.functionId(addPurchase_), "Enter name of purchase:", false);
    }

    function addPurchase_(string value) public {
        m_string = value;
        Terminal.input(tvm.functionId(addPurchase__),"Enter number of purchase:", false);
    }

    function addPurchase__(string value) public {
        (uint256 num,) = stoi(value);
        m_number = uint32(num);
        optional(uint256) pubkey = 0;
        IList(m_address).addPurchase{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(m_string, m_number);
    }
     
    function showPurchases(uint32 index) public view {
        index = index;
        optional(uint256) none;
        IList(m_address).getPurchases{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(showPurchases_),
            onErrorId: 0
        }();
    }

    function showPurchases_( Purchase[] purchases ) public {
        uint32 i;
        if (purchases.length > 0 ) {
            Terminal.print(0, "Your Shopping list:");
            for (i = 0; i < purchases.length; i++) {
                Purchase purchase = purchases[i];
                string bought;
                if (purchase.isBuy) {
                    bought = '✓';
                } else {
                    bought = ' ';
                }
                Terminal.print(0, format("{} {}  \"{}\"({}) add at {}", purchase.id, bought, purchase.text, purchase.number, purchase.createdAt));
            }
        } else {
            Terminal.print(0, "Your Shopping list is empty");
        }
        _menu();
    }

    function deletePurchase(uint32 index) public {
        index = index;
        if (m_stat.paidCount + m_stat.unpaidCount > 0) {
            Terminal.input(tvm.functionId(deletePurchase_), "Enter purchase id:", false);
        } else {
            Terminal.print(0, "Sorry, you have no purchases to delete");
            _menu();
        }
    }

    function deletePurchase_(string value) public view {
        (uint256 num,) = stoi(value);
        optional(uint256) pubkey = 0;
        IList(m_address).deletePurchase{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(uint32(num));
    }
    
}