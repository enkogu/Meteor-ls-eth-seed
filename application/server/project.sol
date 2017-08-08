pragma solidity ^0.4.11; // Template

contract SafeMath {
    function safeMul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeSub(uint a, uint b) internal returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }

    function assert(bool assertion) internal {
        if (!assertion) throw;
    }
}

contract Project is SafeMath {
    address public creator = 0x0;

    mapping (address => uint) offers;

    modifier onlyByCreator(){
        if(msg.sender!=creator)
            throw;
        _;
    }

    function Project(){
        creator = msg.sender;
    }

    function getBalance(address seller) constant returns (uint out){
        out = offers[seller];
        return;
    }

    function() payable {
        offers[msg.sender] += msg.value;
    }
}
