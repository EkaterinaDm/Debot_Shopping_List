pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

struct Purchase {
   uint32 id;
   string text;
   uint32 number;
   uint64 createdAt;
   bool isBuy;
   uint32 totalPrice;
}

struct Stat {
   uint32 paidCount;
   uint32 unpaidCount;
   uint32 totalPaid;
}

interface IList {
   function addPurchase(string text, uint32 number) external;
   function buyPurchase(uint32 id, uint32 price) external;
   function deletePurchase(uint32 id) external;
   function getPurchases() external returns (Purchase[] purchases);
   function getStat() external returns (Stat);
}

interface IMsig {
   function sendTransaction(address dest, uint128 value, bool bounce, uint8 flags, TvmCell payload  ) external;
}

abstract contract AList{
   constructor(uint256 pubkey) public {}
}

