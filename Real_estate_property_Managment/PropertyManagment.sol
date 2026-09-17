// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./token.sol";

contract RealEstateProperty {

    string public _sellObject;
    // address public _ownerEstate;


    struct Property {
        address ownerEstate; // переменные должны быть инициированы вне структуры для области видимости
        bool pledgedEstate; // в залоге (нет по умолчанию)
        bool residentialEstate; // жилая (нет по умолчанию)
        uint256 areaEstate; // площадь
        uint256 previousTotalExplotationDuration; // срок эксплуатации объекта на момент последней продажи 
    }

    struct SellProperty {
        uint256 salePeriod; // если уже продано, =0
        uint256 saleCost; // если продано, =0. цена должна быть больше 0, при gift цена 0 по умолчанию (токены не переводятся)
    }

    mapping(address => address) public objectOwner; // владелец -> название собственности
    mapping(address => Property) public object; // название собственности -> параметры собсвенности
    mapping(address => uint256) public _balances; // баланс пользователя
    mapping(address => bool) public sellRelevance; // обявления о продаже
    mapping(address => SellProperty) public sellObjects;

    // Property storage property = 

    function saleAnnouncment (address _owner, address _saleObject) public {
        require(_owner = msg.sender, "only owner");
        sellRelevance[_saleObject] = true;
    }

    function cancelAnnouncment (address _owner, address _saleObject) public {
        require(_owner = msg.sender, "only owner");
        sellRelevance[_saleObject] = false;
    }

    function buy (address _buyer, address _owner, address _saleObject) public {
        require(sellRelevance[_saleObject] = true, "object is not for sale");
        if (_buyer != (0) && _owner != (0) && _saleObject != (0))
            transferFrom(_buyer, _owner, sellObjects[_saleObject].salecost);
                if (false)
                    revert "transaction failed";
        else
            revert "invalid data"
    }

    




















//     function createObject (
//         address _ownerEstate,
//         bool _pledgedEstate,
//         uint256 _areaEstate,
//         uint256 _previousTotalExplotationDuration,
//         bool _residentialEstate ) public {

//         Property.ownerEstate = _ownerEstate;
//         Property.pledgedEstate = _pledgedEstate;

//     }
//     function createSell (
//         string memory _sellObject,
//         bool _residentialEstate,
//         uint256 _sellCost,
//         uint256 _salePeriod) public {

//         Property storage property = object[_sellObject];

//         Property.residentialEstate = _residentialEstate;
//         Property.salePeriod = _salePeriod; 
//         Property.saleCost = _sellCost;



        
//         }
