// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./token.sol";

contract RealEstateProperty { 

    uint[] public allProperties;
    uint256 Id;
    mapping(uint256 => Property) public properties;
    mapping(address => uint[]) public ownedBy;
    mapping(uint256 => address) public buyerOf;
    mapping(uint256 => Sale) public sales;
    mapping(uint256 => uint256) public salePrice;

    mapping(uint256 => Gift) public gifts;

    mapping(uint256 => Pledge) public pledges;
    mapping(uint256 => address) public pledgorOf;
    mapping(uint256 => uint256) public pledgePrice;

    struct Property { 
        address ownerEstate;
        uint256 areaEstate;
        bool residentialEstate;
        uint256 totalExplotationDuration; 
        bool isSale;
        bool isGift;
        bool isPledge;
    }

    struct Sale {
        uint256 price;
        uint256 saleDuration;
        uint256 startTime;
        uint256 newExploatationDuration;
    }

    struct Gift {
        address recipient;
        uint256 startTime;
        uint256 newExploatationDuration;
        uint256 giftDuration;
    }

    struct Pledge {
        uint256 amount;
        uint256 deadline;
        bool active;
        address pledgor;
        address pledgee;
        uint256 whenDeadlineActivated;
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
            isPledge: false,
            isGift: false,
            isSale: false
        });

        allProperties.push(propertyId); //

        ownedBy[_ownerEstate].push(propertyId); // заполняется ownedBy

        return Id;
    }

    function saleAnnouncment (uint256 propertyId, uint256 price, uint256 saleDuration, uint256 newExploatationDuration) public {
        require(properties[propertyId].ownerEstate == msg.sender, "Only owner");
        sales[propertyId] = Sale({
            price: price,
            saleDuration: saleDuration,
            newExploatationDuration: newExploatationDuration,
            startTime: block.timestamp
        });
        properties[propertyId].isSale = true;
    }

    function saleRequest (uint256 propertyId) public {
        require(sales[propertyId].price > 0);
        require(buyerOf[propertyId]  == address(0));
        require(block.timestamp <= sales[propertyId].startTime + sales[propertyId].saleDuration, "sale expired");
        Sale storage sale = sales[propertyId];

        profiCoin.transfer(msg.sender, address(this), sale.price);
        buyerOf[propertyId] = msg.sender;
        salePrice[propertyId] = sale.price;
        properties[propertyId].isSale = false;
    }

    function saleConfirm (uint propertyId) public {
        Property storage property = properties[propertyId];

        require(properties[propertyId].ownerEstate == msg.sender, "Only owner");
        require(buyerOf[propertyId] != address(0));
        require(block.timestamp <= sales[propertyId].startTime + sales[propertyId].saleDuration, "sale expired");

        profiCoin.transfer(address(this), msg.sender, salePrice[propertyId]);
        property.ownerEstate = buyerOf[propertyId];
        property.totalExplotationDuration += sales[propertyId].newExploatationDuration;

        delete buyerOf[propertyId];
        delete salePrice[propertyId];
        delete sales[propertyId];
    }

    function saleCancel (uint256 propertyId) public {
        require(msg.sender == properties[propertyId].ownerEstate);
        profiCoin.transfer(address(this), buyerOf[propertyId], salePrice[propertyId]);
        buyerOf[propertyId] = address(0); 

        delete buyerOf[propertyId];
        delete salePrice[propertyId];
    }

    function createGift (uint256 propertyId, address recipient, uint256 newExploatationDuration, uint256 giftDuration) public {
        require(properties[propertyId].isGift = false);
        require(msg.sender == properties[propertyId].ownerEstate);
        properties[propertyId].isGift = true;
        gifts[propertyId] = Gift ({
            recipient: recipient,
            newExploatationDuration: newExploatationDuration,
            startTime: block.timestamp,
            giftDuration: giftDuration
        });
        properties[propertyId].isGift = true;
    }

    function giftConfirm (uint256 propertyId) public {
        require(properties[propertyId].isGift = true);
        require(msg.sender == gifts[propertyId].recipient);
        require(block.timestamp <= gifts[propertyId].startTime + gifts[propertyId].giftDuration, "gift expired");
        properties[propertyId].ownerEstate = msg.sender;
        properties[propertyId].totalExplotationDuration += gifts[propertyId].newExploatationDuration;
    }

    function giftCancel (uint256 propertyId) public {
        require(block.timestamp <= gifts[propertyId].startTime + gifts[propertyId].giftDuration, "gift expired");
        properties[propertyId].isGift = false;
    }

    function createPledge (uint256 propertyId, uint256 amount, uint256 deadline, address pledgor) public {
        Property storage property = properties[propertyId];
        require(property.isSale == false);
        require(property.isGift == false);
        property.isPledge = true;

        pledges[propertyId] = Pledge ({
            amount: amount,
            deadline: deadline,
            pledgor: pledgor,
            pledgee: msg.sender,
            whenDeadlineActivated: 0,
            active: false
        });

        property.isPledge = true;
        pledgePrice[propertyId] = amount;
    }


    function pledgeConfirm (uint256 propertyId) public {
        require(msg.sender == pledges[propertyId].pledgor);
        Pledge storage pledge = pledges[propertyId];
        pledge.active = true;
        profiCoin.transfer(msg.sender, pledge.pledgee, pledgePrice[propertyId]);
        pledge.whenDeadlineActivated = block.timestamp; //
    }

    function pledgeCancel (uint256 propertyId) public {
        Pledge storage pledge = pledges[propertyId];
        require(pledge.active = true);
        pledges[propertyId].active = false;
        properties[propertyId].isPledge = false;

        delete pledges[propertyId];
    }

    function returnFunds (uint256 propertyId) public {
        Pledge storage pledge = pledges[propertyId];
        require(msg.sender == pledge.pledgee);
        require(pledge.deadline - pledge.whenDeadlineActivated > 0); //
        profiCoin.transfer(msg.sender, pledge.pledgor, pledgePrice[propertyId]);
    }

    function pledgeExpired (uint256 propertyId) public {
        Pledge storage pledge = pledges[propertyId];
        Property storage property = properties[propertyId];
        require(msg.sender == pledge.pledgor);
        if (pledge.deadline - pledge.whenDeadlineActivated < 0) { //
            property.ownerEstate = msg.sender;      
        }
    }

    function getAllProperties () public view returns (uint[] memory) {
        return allProperties;
    }
}
