pragma solidity ^0.5.0;

import "../contracts/SupplyChain.sol";

contract ProxyContract {

    function addItem(address instance, string memory _name, uint _price) public returns (bool) {
        return SupplyChain(instance).addItem(_name, _price);
    }

    function buyItem(address instance, uint sku) public payable {
        SupplyChain(instance).buyItem(sku);
    }

    function shipItem(address instance, uint sku) public {
        SupplyChain(instance).shipItem(sku);
    }

    function receiveItem(address instance, uint sku) public {
        SupplyChain(instance).receiveItem(sku);
    }

}
