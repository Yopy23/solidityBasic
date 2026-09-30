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
        uint256 price;              // цена
        uint256 saleDuration;       // время существования продажи
        uint256 timeAfter;          // время после которого продажа не актуальна
        address buyer;              // покупатель
        address seller;             // продавец
        uint256 arrayIndex;         // индекс в массиве всех покупок
        uint256 awaitIndex;         // все покупки ожидающие подтверждения
    }

    struct Gift {
        uint256 Id;
        address recipient;          // получатель
        address sender;             // отправитель
        uint256 timeAfter;          // время после которого дарение не актуально
        uint256 giftDuration;       // время существования подарка
        uint256 arrayIndex;
    }

    struct Pledge {
        uint256 Id;
        uint256 amount;             // количество средств которые нужно отдать
        uint256 deadline;           // в течение какого времени можно отдать залог
        bool active;                // активен ли залог
        address pledgor;            // тот кто взял собственность в залог 
        address pledgee;            // тот кто отдал собственность в залог 
        uint256 arrayIndex;
    }

    mapping(uint256 => Property) public properties;
    mapping(uint256 => Sale) public sales;

    mapping(uint256 => Gift) public gifts;

    mapping(uint256 => Pledge) public pledges;

    uint[] public allProperties;                // все объекты
    uint[] public allSales;                     // предложения о продаже
    uint[] public allPledges;                   // все мои предложения о залоге 
    uint[] public allPurchasesAwaitingConfirmations;     // все мои «покупки» ожидающие подтверждения 
    uint[] public allPledgesRequests;           //все мои предложения о залоге
    uint[] public allGifts;
    uint256 Id;
    ProfiCoin profiCoin;

    constructor(address _ProfiCoin) {
        profiCoin = ProfiCoin(_ProfiCoin);
    }

    // создание объекта
    function createObject (address _ownerEstate, uint256 _areaEstate, bool _residentialEstate, uint256 _totalExplotationDuration
    )   public returns (uint256) {

        uint256 propertyId = ++Id; 
        properties[Id] = Property({ // заполняется properties
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
        sales[propertyId] = Sale({
            Id: propertyId,
            price: price,
            saleDuration: saleDuration,
            timeAfter: block.timestamp + saleDuration,
            buyer: address(0),
            seller: msg.sender,
            arrayIndex: 0,
            awaitIndex: 0
        });
        properties[propertyId].isSale = true;
    }

    // запрос на покупку 
    function requestSale (uint256 propertyId) public {

        require(properties[Id].isSale == true, "not for sale");
        require(block.timestamp <= sales[propertyId].timeAfter, "sale expired");

        profiCoin.transfer(msg.sender, address(this), sales[propertyId].price);
        properties[propertyId].isSale = false;

        sales[propertyId].buyer = msg.sender;

        allPurchasesAwaitingConfirmations.push(propertyId);
    }

    // подтверждение продажи
    function confirmSale (uint propertyId) public {
        Property storage property = properties[propertyId];

        require(properties[Id].isSale == true, "not for sale");
        require(properties[propertyId].ownerEstate == msg.sender, "Only owner");

        profiCoin.transfer(address(this), msg.sender, sales[propertyId].price);
        property.ownerEstate = sales[propertyId].buyer; 
        property.totalExplotationDuration += sales[propertyId].saleDuration;

        _removePurchasesAwaitingConfirmation(propertyId);
        allSales.push(propertyId);
    }

    // отмена продажи 
    function sellerCancelSale (uint256 propertyId) public {
        require(msg.sender == properties[propertyId].ownerEstate, "only owner can cancel");
        require(properties[Id].isSale == true, "not for sale");
        profiCoin.transfer(address(this), sales[propertyId].buyer, sales[propertyId].price);
        properties[propertyId].isSale = false;

        _removeSale(propertyId); 
        _removePurchasesAwaitingConfirmation(propertyId);
    }

    function buyerCancelSale(uint256 propertyId) public {
        require(msg.sender == sales[propertyId].buyer, "only buyer can cancel");
        require(properties[Id].isSale == true, "not for sale");
        profiCoin.transfer(address(this), msg.sender, sales[propertyId].price);
        properties[propertyId].isSale = false;

        _removeSale(propertyId); 
        _removePurchasesAwaitingConfirmation(propertyId);
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
            sender: msg.sender,
            arrayIndex: 0
        });
        properties[propertyId].isGift = true;

        allGifts.push(propertyId);
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

        _removeGift(propertyId);
    }

    function ownerCancelGift (uint256 propertyId) public {
        require(properties[propertyId].isGift = true);
        require(gifts[propertyId].sender == msg.sender, "only receiver can do it");
        properties[propertyId].isGift = false;
        delete gifts[propertyId];

        _removeGift(propertyId);
    }

    // создание преджложения о залоге 
    function createPledge (uint256 propertyId, uint256 amount, uint256 deadline, address pledgor) public {
        Property storage property = properties[propertyId];
        require(property.ownerEstate == msg.sender);
        require(property.isSale == false);
        require(property.isGift == false);
        property.isPledge = true;

        pledges[propertyId] = Pledge ({
            Id: propertyId,
            amount: amount,
            deadline: block.timestamp + deadline,
            pledgor: pledgor,          // тот кто взял собственность в залог 
            pledgee: msg.sender,       // тот кто отдал собственность в залог
            active: false,
            arrayIndex: 0
        });

        property.isPledge = true;
        properties[propertyId].ownerEstate = address(0xDA0bab807633f07f013f94DD0E6A4F96F8742B53);
        allPledges.push(propertyId);
    }

    // подтверждение залога
    function pledgeConfirm (uint256 propertyId) public {
        require(msg.sender == pledges[propertyId].pledgor);
        require(properties[propertyId].isPledge == true, "not for pledge");
        require(block.timestamp < pledges[propertyId].deadline, "pledge expired");
        profiCoin.transfer(msg.sender, pledges[propertyId].pledgee, pledges[propertyId].amount);
        pledges[propertyId].active = true;
    }

    // залог просрочен
    function pledgeExpired (uint256 propertyId) public {
        require(msg.sender == pledges[propertyId].pledgor, "only pledgor can do it");
        require(block.timestamp > pledges[propertyId].deadline, "pledge haven`t expired");
        require(pledges[propertyId].active = true, "pledge is not confirmed");
        properties[propertyId].ownerEstate = msg.sender;
        pledges[propertyId].active = false;

        _removePledge(propertyId);
    }

    // вернуть средства по залогу
    function returnPledgeFunds (uint256 propertyId) public {
        require(msg.sender == pledges[propertyId].pledgee);
        require(block.timestamp < pledges[propertyId].deadline, "pledge expired");
        require(pledges[propertyId].active = true, "pledge is not confirmed");
        profiCoin.transfer(msg.sender, pledges[propertyId].pledgor, pledges[propertyId].amount);
        
        properties[propertyId].ownerEstate = msg.sender;

        _removePledge(propertyId);
    }

    // remove
    function _removeGift(uint propertyId) public {
        uint256 index = gifts[propertyId].arrayIndex;
        uint256 lastId = allGifts[allGifts.length -1];

        if (lastId != propertyId) {
          allProperties[index] = lastId;
          gifts[lastId].arrayIndex = index;
          }

        allGifts.pop();

        delete gifts[propertyId];
    }

    function _removePledge (uint256 propertyId) public {
        uint256 index = pledges[propertyId].arrayIndex;
        uint256 lastId = allPledges[allPledges.length - 1];

        if (lastId != propertyId) {
            allPledges[index] = lastId;
            pledges[lastId].arrayIndex = index;
        }

        allPledges.pop();

        delete pledges[propertyId];
    }

    function _removeSale (uint propertyId) public {
        uint256 index = sales[propertyId].arrayIndex;
        uint256 lastId = allSales[allSales.length - 1];

        if (lastId != propertyId) {
          allSales[index] = lastId;
          sales[lastId].arrayIndex = index;
        }
        
        allSales.pop();

        delete sales[propertyId];
    }

    function _removeSaleOffer(uint propertyId) public {}

    function _removePledgeOffers(uint propertyId) public {}

    function _removePurchasesAwaitingConfirmation(uint propertyId) public {
        uint256 index = sales[propertyId].awaitIndex;
        uint256 lastId = allPurchasesAwaitingConfirmations[allPurchasesAwaitingConfirmations.length - 1];

        if (lastId != propertyId) {
          allPurchasesAwaitingConfirmations[index] = lastId;
          sales[lastId].arrayIndex = index;
        }
        
        allPurchasesAwaitingConfirmations.pop();

        delete sales[propertyId];
    }

    /*
    function getProperties () public returns (uint[] memory) {
        return ;
    }
    */
    
    // function getSaleOffers () public returns(uint[] memory) {
    //     return AllSaleOffers;
    // }
    // function getPurchasesAwaitingConfirmation () public returns(uint[] memory) {
    //     return AllPurchasesAwaitingConfirmation;
    // }
    // function getPledgeOffers () public returns(uint[] memory) {
    //     return allPledgeOffers;
    // }
    function getPledges () public view returns(uint[] memory) {
        return allPledges;
    }

}
