// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./token.sol";

contract RealEstateProperty { 

    uint256 Id;
    mapping(uint256 => Property) public properties;
    mapping(address => uint[]) public ownedBy;
    mapping(uint256 => Sale) public sales;

    struct Property {
        address ownerEstate;
        uint256 areaEstate;
        bool residentialEstate;
        uint256 totalExplotationDuration; 
        bool saleRelevance;
        bool isSale;
        bool isGift;
        bool isPledge;
    }

    struct Sale {
        uint256 price;
        uint256 saleDuration;
    }

    ProfiCoin profiCoin;

    constructor(address _ProfiCoin) {
        profiCoin = ProfiCoin(_ProfiCoin);
    }


    // создание объекта
    function createObject (address _ownerEstate, uint256 _areaEstate, bool _residentialEstate, uint256 _totalExplotationDuration
    )   public returns (uint256) {

        uint256 propertyId = ++Id; 
        properties[Id] = Property({ // заполняется properties
            ownerEstate: _ownerEstate,
            areaEstate: _areaEstate,
            residentialEstate: _residentialEstate,
            totalExplotationDuration: _totalExplotationDuration,
            saleRelevance: false,
            isPledge: false,
            isGift: false,
            isSale: false
        });

        ownedBy[_ownerEstate].push(propertyId); // заполняется ownedBy

        return Id;
    }

    function saleAnnouncment (uint256 propertyId, uint256 price, uint256 saleDuration) public {
        require(properties[propertyId].ownerEstate == msg.sender, "Only owner");
        sales[propertyId] = Sale({
            price: price,
            saleDuration: saleDuration
        });
    }

    //покупатель
    function saleRequest (uint256 propertyId) public {
        Property storage property = properties[propertyId];
        require(properties[propertyId].ownerEstate == msg.sender, "Only owner");
        payable()

    }
}
