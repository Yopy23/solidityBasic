// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


// проверки require(properties[propertyId].ownerEstate == msg.sender, "Only owner");


import "./token.sol";

contract RealEstateProperty { 

    struct Property { 
        uint256 Id;
        address ownerEstate;
        uint256 areaEstate;
        bool residentialEstate;
        uint256 totalExplotationDuration; 
        bool isSale;
        bool isGift;
        bool isPledge;
    }

    struct Sale {
        uint256 Id;
        uint256 saleId;
        uint256 price;              // цена
        uint256 saleDuration;       // время существования продажи
        uint256 timeAfter;          // время после которого продажа не актуальна
        address buyer;              // покупатель
        address seller;             // продавец 
    }

    struct Gift {
        uint256 Id;
        address recipient;          // получатель
        address sender;             // отправитель
        uint256 timeAfter;          // время после которого дарение не актуально
        uint256 giftDuration;       // время существования подарка
    }

    struct Pledge {
        uint256 Id;
        uint256 amount;             // количество средств которые нужно отдать
        uint256 deadline;           // в течение какого времени можно отдать залог
        bool active;                // активен ли залог
        address pledgor;            // тот кто взял собственность в залог 
        address pledgee;            // тот кто отдал собственность в залог 
    }

    mapping(uint256 => Property) public properties;
    mapping(uint256 => Sale) public sales;

    mapping(uint256 => Gift) public gifts;

    mapping(uint256 => Pledge) public pledges;
    uint[] public propertyIds;
    uint256 Id;
    ProfiCoin profiCoin;

    constructor(address _ProfiCoin) {
        profiCoin = ProfiCoin(_ProfiCoin);
    }

    // создание объекта
    function createObject (address _ownerEstate, uint256 _areaEstate, bool _residentialEstate, uint256 _totalExplotationDuration
    )   public returns (uint256) {

        uint256 propertyId = ++Id; 
        properties[Id] = Property({
            Id: propertyId,
            ownerEstate: _ownerEstate,
            areaEstate: _areaEstate,
            residentialEstate: _residentialEstate,
            totalExplotationDuration: _totalExplotationDuration,
            isPledge: false,
            isGift: false,
            isSale: false
        });

        return Id;
    }

    // создание продажи 
    function announceSale (uint256 propertyId, uint256 price, uint256 saleDuration) public {
        require(properties[propertyId].ownerEstate == msg.sender, "Only owner");
        uint256 saleId = ++Id;
        sales[propertyId] = Sale({
            Id: propertyId,
            saleId: saleId,
            price: price,
            saleDuration: saleDuration,
            timeAfter: block.timestamp + saleDuration,
            buyer: address(0),
            seller: msg.sender
        });
        properties[propertyId].isSale = true;
        propertyIds.push(propertyId);
    }

    // запрос на покупку 
    function requestSale (uint256 propertyId) public {

        require(properties[Id].isSale == true, "not for sale");
        require(block.timestamp <= sales[propertyId].timeAfter, "sale expired");

        profiCoin.transfer(msg.sender, address(this), sales[propertyId].price);
        properties[propertyId].isSale = false;

        sales[propertyId].buyer = msg.sender;
    }

    // подтверждение продажи
    function confirmSale (uint propertyId) public {
        Property storage property = properties[propertyId];

        require(properties[Id].isSale == true, "not for sale");
        require(properties[propertyId].ownerEstate == msg.sender, "Only owner");

        profiCoin.transfer(address(this), msg.sender, sales[propertyId].price);
        property.ownerEstate = sales[propertyId].buyer; 
        property.totalExplotationDuration += sales[propertyId].saleDuration;
    }

    // отмена продажи 
    function sellerCancelSale (uint256 propertyId) public {
        require(msg.sender == properties[propertyId].ownerEstate, "only owner can cancel");
        require(properties[Id].isSale == true, "not for sale");
        profiCoin.transfer(address(this), sales[propertyId].buyer, sales[propertyId].price);
        properties[propertyId].isSale = false;
    }

    function buyerCancelSale(uint256 propertyId) public {
        require(msg.sender == sales[propertyId].buyer, "only buyer can cancel");
        require(properties[Id].isSale == true, "not for sale");
        profiCoin.transfer(address(this), msg.sender, sales[propertyId].price);
        properties[propertyId].isSale = false;
    }

    // создание подарка + реквест
    function createGift (uint256 propertyId, address recipient, uint256 giftDuration) public {
        require(properties[propertyId].isGift = false);
        require(msg.sender == properties[propertyId].ownerEstate);
        gifts[propertyId] = Gift ({
            Id: propertyId,
            recipient: recipient,
            timeAfter: block.timestamp + giftDuration,
            giftDuration: giftDuration,
            sender: msg.sender
            });
        properties[propertyId].isGift = true;
    }

    // подтверждение получения подарка
    function giftConfirm (uint256 propertyId) public {
        require(properties[propertyId].isSale == false);
        require(properties[propertyId].isGift = true);
        require(msg.sender == gifts[propertyId].recipient);
        require(block.timestamp <= gifts[propertyId].timeAfter, "gift expired");
        properties[propertyId].ownerEstate = msg.sender;
    }

    function receiverCancelGift (uint256 propertyId) public {
        require(properties[propertyId].isSale == false);
        require(properties[propertyId].isGift = true);
        require(gifts[propertyId].recipient == msg.sender, "only receiver can do it");
        properties[propertyId].isGift = false;
    }

    function ownerCancelGift (uint256 propertyId) public {
        require(properties[propertyId].isGift = true);
        require(gifts[propertyId].sender == msg.sender, "only receiver can do it");
        properties[propertyId].isGift = false;
    }

    // создание преджложения о залоге 
    function createPledge (uint256 propertyId, uint256 amount, uint256 deadline) public {
        Property storage property = properties[propertyId];
        require(property.ownerEstate == msg.sender);
        require(property.isSale == false);
        require(property.isGift == false);
        property.isPledge = true;

        pledges[propertyId] = Pledge ({
            Id: propertyId,
            amount: amount,
            deadline: block.timestamp + deadline,
            pledgor: address(0),          // тот кто взял собственность в залог 
            pledgee: msg.sender,       // тот кто отдал собственность в залог
            active: false
        });

        property.isPledge = true;
        properties[propertyId].ownerEstate = address(0xDA0bab807633f07f013f94DD0E6A4F96F8742B53);
        }

    // взятие в залог
    function pledgeRequest (uint256 propertyId) public {
        Property storage pr = properties[propertyId];
        Pledge storage pledge = pledges[propertyId];
        require(pr.isPledge == true, "not a pledge");
        require(block.timestamp <= pledge.deadline, "pledge expired");
        require(msg.sender == pledges[propertyId].pledgor);
        
        pledges[propertyId].pledgor = msg.sender;
        profiCoin.transfer(msg.sender, address(this), pledge.amount);
        pr.isPledge = false;
    } 

    // подтверждение залога
    function pledgeConfirm (uint256 propertyId) public {
        require(msg.sender == pledges[propertyId].pledgee);
        require(properties[propertyId].isPledge == true, "not for pledge");
        require(block.timestamp < pledges[propertyId].deadline, "pledge expired");
        require(pledges[propertyId].active == false, "active pledge couldnt be confirmed again");
        profiCoin.transfer(address(this), pledges[propertyId].pledgee, pledges[propertyId].amount);
        pledges[propertyId].active = true;
    }

    // залог просрочен
    function pledgeExpired (uint256 propertyId) public {
        require(msg.sender == pledges[propertyId].pledgor, "only pledgor can do it");
        require(block.timestamp > pledges[propertyId].deadline, "pledge haven`t expired");
        require(pledges[propertyId].active = true, "pledge is not confirmed");
        properties[propertyId].ownerEstate = msg.sender;
        pledges[propertyId].active = false;
    }

    // вернуть средства по залогу
    function returnPledgeFunds (uint256 propertyId) public {
        require(msg.sender == pledges[propertyId].pledgee);
        require(block.timestamp < pledges[propertyId].deadline, "pledge expired");
        require(pledges[propertyId].active = true, "pledge is not confirmed");
        profiCoin.transfer(msg.sender, pledges[propertyId].pledgor, pledges[propertyId].amount);
        
        properties[propertyId].ownerEstate = msg.sender;
    }

   // отмена залога 
    function pledgorCancelPledge (uint256 propertyId) public {
        Pledge storage pledge = pledges[propertyId];
        require(pledge.active == false, "active pledge couldnt be cancelled");
        require(pledge.pledgor == msg.sender, "only pledgor");
        profiCoin.transfer(address(this), msg.sender, pledge.amount); 
        pledges[propertyId].active = false;
    }

   // отмена залога 
    function pledgeeCancelPledge (uint256 propertyId) public {
        Property storage pr = properties[propertyId];
        Pledge storage pledge = pledges[propertyId];
        require(pledge.active == false, "active pledge couldnt be cancelled");
        require(pledge.pledgee == msg.sender, "only pledgee");
        profiCoin.transfer(address(this), pledge.pledgor, pledge.amount); 
        pr.isPledge = false;
    }

    modifier exists(uint256 _id) {
        require(properties[_id].ownerEstate != address(0), "Property not found");
        _;
    }

// получить объект
    function getProperty(uint256 _id)
        external
        view
        exists(_id)
        returns (Property memory)
    {
        return properties[_id];
    }

// получить все объекты
    function getAllProperties() external view returns (Property[] memory) {
        uint256 len = propertyIds.length;
        Property[] memory result = new Property[](len);

        for (uint256 i = 0; i < len; i++) {
            result[i] = properties[propertyIds[i]];
        }
        return result;
    }

// получить все мои залоги 
    function getAllPledges() external view returns (Pledge[] memory) {
        uint256 len = propertyIds.length;
        uint256 count;
        for (uint256 i = 0; i < len; i++) {
            if (properties[propertyIds[i]].isPledge) count++;
        }
        Pledge[] memory result = new Pledge[](count);
        uint256 j;
        for (uint256 i = 0; i < len; i++) {
            Pledge storage p = pledges[propertyIds[i]];
            if (p.active == false) {
                result[j++] = p;
            }
        }
        return result;
    }

// получить все подарки
    function getAllGifts() external view returns (Gift[] memory) {
        uint256 len = propertyIds.length;
        uint256 count;
        for (uint256 i = 0; i < len; i++) {
            if (properties[propertyIds[i]].isGift) count++;
        }
        Gift[] memory result = new Gift[](count);
        uint256 j;
        for (uint256 i = 0; i < len; i++) {
            Gift storage g = gifts[propertyIds[i]];
            result[j++] = g;
        }
        return result;
    }
}

