pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";
import "./contract-helpers.sol";

contract TestSupplyChain {
    uint public initialBalance = 50 ether;

    SupplyChain instance;
    ProxyContract user1;

    event Log(bytes data);

    function() external payable {}

    // Test for failing conditions in this contracts:
    // https://truffleframework.com/tutorials/testing-for-throws-in-solidity-tests
    function beforeAll() public {
        user1 = new ProxyContract();
    }

    function beforeEach() public {
        instance = new SupplyChain();
    }

    // buyItem
    function buyItemPayload(uint sku) internal pure returns (bytes memory) {
        return abi.encodeWithSignature("buyItem(uint256)", sku);
    }

    function testForFailureIfUserDoesNotSendEnoughFunds() public {
        instance.addItem("item1", 2 ether);
        uint sku = 0;
        bool r;

        (r, ) = address(instance).call.value(1 ether)(buyItemPayload(sku));

        Assert.isFalse(r, "Should fail when transfering less amount of ether than is the price");
    }

    function testForPurchasingAnItemThatIsNotForSale() public {
        uint sku = 1;
        bool r;

        (r, ) = address(instance).call.value(1 ether)(buyItemPayload(sku));

        Assert.isFalse(r, "Should fail when purchasing an item which does not exist");
    }

    // shipItem
    function testForCallsThatAreMadeByNotTheSeller() public {
        instance.addItem("item1", 0 ether);
        uint sku = 0;
        instance.buyItem(sku);
        bool r;

        (r, ) = address(user1).call(abi.encodeWithSignature("shipItem(address,uint256)", address(instance), sku));

        Assert.isFalse(r, "Should fail when sender is not seller");
    }

    function testForTryingToShipAnItemThatIsNotMarkedSold() public {
        uint sku = 0;
        bool r;

        (r, ) = address(instance).call(abi.encodeWithSignature("shipItem(uint256)", sku));

        Assert.isFalse(r, "Should fail when shipping item which is not sold");
    }

    // receiveItem
    function receiveItemPayload(uint sku) internal pure returns (bytes memory) {
        return abi.encodeWithSignature("receiveItem(uint256)", sku);
    }

    function testCallingTheFunctionFromAnAddressThatIsNotTheBuyer() public {
        instance.addItem("item1", 0 ether);
        uint sku = 0;
        instance.buyItem(sku);
        instance.shipItem(sku);
        bool r;

        (r, ) = address(user1).call(abi.encodeWithSignature("receiveItem(address,uint256)", address(instance), sku));

        Assert.isFalse(r, "Should fail when sender is not buyer");
    }

    function testCallingTheFunctionOnAnItemNotMarkedShipped() public {
        uint sku = 0;
        bool r;

        (r, ) = address(user1).call(abi.encodeWithSignature("receiveItem(address,uint256)", address(instance), sku));

        Assert.isFalse(r, "Should fail when receiving item which is not shipped");
    }

}
