pragma solidity ^0.8.0;

contract Contract1 {
    address public owner;  // The owner of the contract
    address[] public eligibleProviders;  // List of eligible service providers
    mapping(address => bool) public responseReceived;  // Mapping to track responses
    
    
    event EligibleProviderAdded(address indexed provider);
    event ResponseReceived(address indexed provider, bool accepted);
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
    
    
    function addEligibleProvider(address provider) public onlyOwner {
        eligibleProviders.push(provider);
        emit EligibleProviderAdded(provider);
    }
    
    
    function sendRequest(address[] memory providers, uint[] memory values, bytes[] memory slas) public {
        require(providers.length == values.length && providers.length == slas.length, "Input arrays must have the same length");
        
        for (uint i = 0; i < providers.length; i++) {
            require(isEligibleProvider(providers[i]), "Provider is not eligible");
            //requets imp
        }
    }
    
    
    function isEligibleProvider(address provider) public view returns (bool) {
        //func elbility check
    }
    
   
}
