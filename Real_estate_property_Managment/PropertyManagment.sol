// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./token.sol";

contract RealEstateProperty { 

    uint256 Id;
    mapping(uint256 => Property) public properties;
    mapping(address => uint[]) public ownedBy;
    mapping(uint256 => address) public buyerOf;
    mapping(uint256 => Sale) public sales;
    mapping(uint256 => uint256) public salePrice;

    mapping(uint256 => Gift) public gifts;

    mapping(uint256 => Pledge) public pledges;
    mapping(uint265 => address) public pledgorOf;

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
    }

    struct Gift {
        address recipient;
    }

    struct Pledge (
        uint256 amount;
        uint256 duration;
        bool active;
        address pledgor;
    )

    ProfiCoin profiCoin;

    event Log();

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

        ownedBy[_ownerEstate].push(propertyId); // заполняется ownedBy

        return Id;
    }

    function saleAnnouncment (uint256 propertyId, uint256 price, uint256 saleDuration) public {
        require(properties[propertyId].ownerEstate == msg.sender, "Only owner");
        sales[propertyId] = Sale({
            price: price,
            saleDuration: saleDuration
        });
        properties[propertyId].isSale = true;
    }

    //покупатель
    function saleRequest (uint256 propertyId) public {
        require(sales[propertyId].price > 0);
        require(buyerOf[propertyId]  == (0));

        proficoin.transfer(msg.sender, address(this), sale.price);

        emit Log("реквест на покупку имущества с id ", propertyId, " отправлен от ", msg.sender )
        buyerOf[propertyId] = msg.sender;
        salePrice[propertyId] = sale.price;
        properties[propertyId].isSale = false;
    }

    function saleConfirm (uint propertyId) public {
        Property storage property = properties[propertyId];
        Sale storage sale = sales[propertyId];

        require(properties[propertyId].ownerEstate == msg.sender, "Only owner");
        require(buyerOf[propertyId] != (0));

        proficoin.transfer(address(this), msg.sender, salePrice[propertyId]);
        property.ownerEstate = buyerOf[propertyId];
        ownedBy[propertyId] = buyerOf[propertyId];
        totalExplotationDuration += block.timestamp;

        delete buyerOF[propertyId];
        delete salePrice[propertyId];
        delete sales[propertyId];
    }

    function saleCancel (uint256 propertyId) public {
        require(msg.sender == properties[propertyId].ownerEstate);
        proficoin.transfer(address(this), buyerOd[propertyID], salePrice[propertyId]);
        buyerOf[propertyId] = (0); 
        ownedBy[propertyId] = (0);

        delete buyerOf[propertyId];
        delete salePrice[propertyId];
    }

    function createPledge (uint256 propertyId, uint256 amount, uint256 duration, address pledgor) public {
        Property storage property = properties[propertyId];
        require(property.isSale == false);
        require(property.isGift == false);
        property.isPledge = true;

        pledges[propertyId] = Pledge ({
            amount: amount,
            duration: duration,
            pledgor: pledgor
        })

        property.isPledge = true;

        emit Log();
    }


    function pledgeConfirm (uint256 propertyId) public {
        Property storage property = properties[propertyId];
        Pledge storage pledge = pledges[propertyId];

        pledge.active = true;
    }






    function createGift (uint256 propertyID, address _recipient ) public {
        require(msg.sender == properties[propertyId].ownerEstate);
        property[propertyID].isGift = true;
        gifts[propertyId].receipient = _recipient;
        property[propertyId].isGift = true;
    }

    function giftConfirm (propertyId) public {
        require(msg.sender == gifts[propertyId].receipient)
        property[propertyId].ownerEstate = msg.sender
    }
}
