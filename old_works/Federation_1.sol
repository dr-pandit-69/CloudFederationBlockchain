// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Federation {
    struct VMTypeConfig {
        string vmType;
        string vmConfiguration;
        uint numberOfVMs;
        uint resourcePrice;
    }

    event AuctionStarted(uint auctionId);
    event AuctionWinnerSelected(address winner, uint bidAmount);
    event ResourceAllocated(address client, address provider, uint resources);

    address public owner;
    uint public nextCSPId;
    uint private auctionCounter = 0;

    mapping(address => uint) public cspIds;
    mapping(uint => CSPInfo) public cspDetails;
    mapping(uint => address) public cspSmartContracts;
    mapping(uint => VMTypeConfig[]) public cspVMConfigurations; // Multiple VM configurations per CSP

    constructor() {
        owner = msg.sender;
        nextCSPId = 1;
    }

    function allocateResources(uint trustValue, uint qosRequirement, uint maxPrice, address requester) public {
        address[] memory qualifiedCSPs;
        uint numQualifiedCSPs = 0;
        
        VMTypeConfig[] memory selectedVMs;
        uint totalResources = 0;
        
        for (uint i = 1; i < nextCSPId; i++) {
            CSPInfo storage csp = cspDetails[i];

            if (csp.trustValue >= trustValue && csp.qosRating >= qosRequirement) {
                qualifiedCSPs[numQualifiedCSPs] = csp.owner;
                numQualifiedCSPs++;
                
                for (uint j = 0; j < cspVMConfigurations[i].length; j++) {
                    if (cspVMConfigurations[i][j].resourcePrice <= maxPrice) {
                        selectedVMs.push(cspVMConfigurations[i][j]);
                        totalResources += cspVMConfigurations[i][j].numberOfVMs;
                    }
                }
            }
        }
        
        uint auctionId = generateUniqueAuctionId();
        conductAuction(auctionId, qualifiedCSPs, selectedVMs, totalResources, requester);
    }
    
    function conductAuction(uint auctionId, address[] memory qualifiedCSPs, VMTypeConfig[] memory selectedVMs, uint totalResources, address requester) internal {
        require(msg.sender == owner, "Only the owner can conduct an auction");
        require(auctionId > 0, "Invalid auction ID");

        for (uint i = 0; i < qualifiedCSPs.length; i++) {
            CSP cspContract = CSP(cspSmartContracts[cspIds[qualifiedCSPs[i]]);
            
            cspContract.updateResourceAvailability(selectedVMs[i].vmType, selectedVMs[i].vmConfiguration, selectedVMs[i].numberOfVMs, selectedVMs[i].resourcePrice);
        }

        emit AuctionStarted(auctionId);

        uint totalAllocatedResources = 0;
        uint i = 0;
        
        while (totalAllocatedResources < totalResources && i < qualifiedCSPs.length) {
            CSP cspContract = CSP(cspSmartContracts(cspIds[qualifiedCSPs[i]]));
            
            // Calculate how many resources to allocate from this CSP.
            uint resourcesToAllocate = totalResources - totalAllocatedResources > selectedVMs[i].numberOfVMs
                ? selectedVMs[i].numberOfVMs
                : totalResources - totalAllocatedResources;
            
            cspContract.acceptResourceAllocation(auctionId, requester, resourcesToAllocate);

            totalAllocatedResources += resourcesToAllocate;
            
            emit ResourceAllocated(requester, qualifiedCSPs[i]);

        }
    }
}