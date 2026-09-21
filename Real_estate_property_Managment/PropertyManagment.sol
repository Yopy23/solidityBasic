// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./token.sol";

contract RealEstateProperty {

    error NotEnoughFunds();
    error ConfirmingReverted();

    event Log(string message);
    // параметры объекта
    // обладатель // площадь // в залоге (нет по умолчанию) // жилая (нет по умолчанию)
    // срок эксплуатации объекта на момент последней продажи 
    struct Property {
        address ownerEstate; 
        uint256 areaEstate;
        bool pledgedEstate;
        bool residentialEstate;
        uint256 previousTotalExplotationDuration; 
        bool saleRelevance;
    }

    struct Sale {
        uint256 price;
        uint256 deadline;
        address buyer;
    }

    // владелец -> объект -> id
    uint256 public propertyId;
    mapping (uint256 => Property) public properties; // id -> объект
    mapping(address => uint256[]) public ownedBy; // вдаледец -> id
    mapping(uint256 => Sale) public sales;
    uint[] public salesStack;

    mapping(address => uint256) public _balances; // баланс пользователя

    modifier KnowledgeOfObject (
        address _ownerEstate, 
        uint256 _areaEstate,
        bool _pledgedEstate,
        bool _residentialEstate,
        uint256 _previousTotalExplotationDuration,
        uint256 objectId) {
        Property storage p = properties[objectId];
        require (_ownerEstate = p.ownerEstate, "invalid ownerEstate");
        require(_areaEstate = p.areaEstate, "invalid areaEstate");
        require(_pledgedEstate = p.pledgedEstate, "the property is pledged");
        require(_residentialEstate = p.residentialEstate, "invalid residentialEstate");
        require(_previousTotalExplotationDuration = p.previousTotalExplotationDuration, "the time for selling the property has expired.");
        require(_saleRelevance = p.saleRelevance, "the sale of the property is no longer relevant.");
        _;
    }

    modifier KnowledgeOfSale (uint256 objectId) {
        Sale storage s = sales[objectId];
        require(_price = s.price, "invalid price");
        require(_buyer = s.buyer, "invalid buyer");
        require(_deadline = s.deadline, "invalid deadline");
        _;
    }

    modifier OnlyObjectOwner () {
        ownedBy[_msg.sender] = _objectId;
        _;
    }

    function createObject (
        address _ownerEstate, 
        uint256 _areaEstate,
        bool _pledgedEstate,
        bool _residentialEstate,
        uint256 _previousTotalExplotationDuration
    )   public returns (uint256) {

        uint256 objectId = ++propertyId; 

        properties[objectId] = Property({ // записываем параметры объекта и присываиваем id
            ownerEstate: _ownerEstate,
            areaEstate: _areaEstate,
            pledgedEstate: _pledgedEstate,
            residentialEstate: _residentialEstate,
            previousTotalExplotationDuration: _previousTotalExplotationDuration
        });

        ownedBy[_ownerEstate].push(objectId); // записываем один из возможно нескольких обектов в массив к владельцу

        return objectId;

        emit Log("object created");

     }


    function saleAnnouncement(uint _objectId, uint256 _price, uint256 _deadline) public {
        require(OnlyObjectOwner, "check id accuracy or is it your object");
        properties[_objectId].saleRelevance = true;
        sales[_objectId] = Sale({
            price: _price,
            deadline: _deadline
        });
        
        sales[_ownerEstate].push(_objectId);

        emit Log("the sale is announced");
        emit Log ("you can see info about sale and property by using getSale");
    }

    function createSale () private payable {
        require (OnlyObjectOwner, "check id accuracy or is it your object");
        require(KnowledgeOfObject, "invalid data");
        Property storage p = properties[objectId];
        Sale storage s = sales[objectId];
    
    uint256 _amount = s.price;
    if (msg.value > s.price & saleRelevance = true) {
        bool success = transferFrom(msg.sender, address(this), _amount);
        require(success = true, "transfer failed");
    } 
    else if ()
    else {
        revert NotEnoughFunds();
    }

    if (saleRelevance = true) {
        bool successConfirming = transferFrom(address(this), p.ownerEstate, _amount);
        if (successConfirming = true) {
            p.ownerEstate = msg.sender;
        }
        else {
            revert ConfirmingReverted();
        }
    else {
        revert SaleExpired();
        bool success = transferFrom(address(this), msg.sender,_amount);
    }
    

    emit Log("the object is saled");
    }

    function cancellSale () public {
        require(OnlyObjectOwner, "check id accuracy or is it your object");
        properties[objectId].saleRelevance = false;
    }

    function returnFundscuz () public {
    //  возможность возврата средств покупателю, если продавец отказывается от 
    // продажи, срок эксплуатации должен остаться таким, каким он был до 
    // продажи.
    }

    
 - возможность возврата средств покупателю, если продавец не подтвердил и 

// закончился срок продажи, срок эксплуатации должен остаться таким, каким 

// он был до продажи. - механизм подтверждения получения средств продавцом

    function createGift () public {
        // проверить 
        Property storage p = properties[objectId];
        Sale storage s = sales[objectId];
        require(KnowledgeOfObject, "invalid data");
        require (p.ownerEstate != (0));
    
    uint256 _amount = s.price;
    bool success = transferFrom(msg.sender, address(this), _amount);
    // передать лог о том что отправплена заявка на подарок
    require(success = true, "transfer failed");

    bool successConfirming = transferFrom(address(this), p.ownerEstate, _amount);
    if (successConfirming = true) {
        p.ownerEstate = msg.sender;
    }
    else {
        revert ; // 
    }

    emit Log("the object is saled");
    }

    function createPledge () {

    }

}


// objectId вынести в отдельное поле

.
