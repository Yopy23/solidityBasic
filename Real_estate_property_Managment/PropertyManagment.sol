// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./token.sol";

contract RealEstateProperty {

    error NotEnoughFunds();
    error ConfirmingReverted();
    error SaleExpired();
    error NotGift();

    struct Property {
        address ownerEstate; 
        uint256 areaEstate;
        bool pledgedEstate;
        bool residentialEstate;
        uint256 totalExplotationDuration; 
        bool saleRelevance;
    }

    struct Sale {
        uint256 price;
        uint256 deadline;
        // address buyer;
    }

    struct Gift {
    address addressee;
    uint256 deadline;
}
    struct Pledge {
    address pledgor;
    uint255 amount;
    
}


    createObject // создаётся структура
    createGift
    createPledge

    requestSale // структура отдается туда-то так-то и удаляется из списка
    requestGift
    requestPledge

    cancelSale // структура просто удаляется из списка
    cancelGift
    cancelPledge

    confirmSale // структура переходит во владение другому человеку и удаляется из списка 
    confirmGift
    confirmPledge


    uint256 public propertyId;
    mapping (uint256 => Property) public properties; // id -> объект
    mapping(address => uint256[]) public ownedBy; // вдаледец -> id
    mapping(uint256 => Sale) public sales;

    function createObject (
        address _ownerEstate, 
        uint256 _areaEstate,
        bool _pledgedEstate,
        bool _residentialEstate,
        uint256 _totalExplotationDuration,
        uint256 Id
    )   public returns (uint256) {

        Id = ++propertyId; 

        properties[Id] = Property({ // заполняется properties
            ownerEstate: _ownerEstate,
            areaEstate: _areaEstate,
            pledgedEstate: _pledgedEstate,
            residentialEstate: _residentialEstate,
            totalExplotationDuration: _totalExplotationDuration,
            saleRelevance: false
        });

        ownedBy[_ownerEstate].push(Id); // заполняется ownedBy

        return Id;
    }

// при создании продажи указываются
    function saleAnnouncmentOrGift(uint _Id, uint _price, uint _deadline) public {
        require(_Id != 0, "create object first");
        require(msg.sender == properties[_Id].ownerEstate, "only owner");
        properties[_Id].saleRelevance = true; // заполняется sales
        sales[_Id] = Sale({
            price: _price,
            deadline: _deadline
        });
    }


        /* теперь заполнены:
             properties[_Id], все созданные объекты 
             ownedBy[msg.sender],    все владельцы
             sales[_Id],      все доступные для продажи объекты */


    
// возможнось возврата средств если не подтвердил продавец
    function objectSale (address contractAddress, uint256 _Id) public payable {
        require(_Id != 0, "create object first");
        require(msg.sender == properties[_Id].ownerEstate, "only owner");
        Property storage p = properties[_Id];
        Sale storage s = sales[_Id];
        uint price = s.price;
        if (msg.value > s.price && p.saleRelevance == true) {
            bool success = IERC20(contractAddress).transfer(msg.sender, address(this), price); 
            require(success == true, "transfer failed");
        }
        else {
            revert NotEnoughFunds();
        }

        if (p.saleRelevance == true) {
            bool successConfirming = IERC20(contractAddress).transfer(msg.sender, address(this), price);
                if (successConfirming == true) {
                    p.ownerEstate = msg.sender;
                    p.totalExplotationion += block.timestamp;
                    p.saleRelevance = false;
                }
                else {
                    revert ConfirmingReverted();
                }
        }
        else {
            revert SaleExpired();
            bool success = IERC20(contractAddress).transferFrom(address(this), msg.sender, price);
        }

    }

// возможность отмены продажи - возможность возврата средств покупателю, если продавец отказывается от 
// продажи, срок эксплуатации должен остаться таким, каким он был до продажи
    // function cancelSale (uint _Id) public {
    //     properties[_Id].saleRelevance = false;
    //     sales[_Id] = (0);
    // } 

    function objectGift (uint _Id, address addressee ) public payable {
        require(_Id != 0, "create object first");
        require(msg.sender == properties[_Id].ownerEstate, "only owner");
        Property storage p = properties[_Id];
        Sale storage s = sales[_Id];
        if (s.price == 0) {
            revert NotGift();
        }
        
        bool success = IERC20(contractAddress).transfer(msg.sender, addressee, 0); 
        require(success == true, "transfer failed");
                p.ownerEstate = msg.sender;
                p.totalExplotationion += block.timestamp;
                p.saleRelevance = false;
            }
       
        
    function objectPledge (uint _Id) public {
        require(_Id != 0, "create object first");
        require(msg.sender == properties[_Id].ownerEstate, "only owner");
    } 




}
