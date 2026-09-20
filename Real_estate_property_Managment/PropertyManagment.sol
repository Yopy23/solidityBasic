// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./token.sol";

contract RealEstateProperty {

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

    mapping(address => uint256) public _balances; // баланс пользователя

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
    }

    function createSale (address _owner, uint objectId) public {
        require(_owner = msg.sender, "only owner");
        // проверить на наличие ошибок по всем параметрам чтобы убедиться что продающий знает что продает
        properties[objectId] = true;
    }

    function createGift () public {

    }

    function createdGift () public {

    }

    function createPledge () public {

    }
}
