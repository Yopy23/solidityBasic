# variables

address public ownerEstate; // переменные должны быть инициированы вне структуры для области видимости

bool public pledgedEstate; // в залоге (нет по умолчанию)

bool public residentialEstate; // жилая (нет по умолчанию)

uint256 public areaEstate; // площадь

uint256 public previousTotalExplotationDuration; // срок эксплуатации объекта на момент последней продажи


# functions
    sell
      newOwner присылает деньги (transferTo) -> owner получает, передает адрес newOwner в owner
      переменные:
        sellObject
        sellCost
        sellRelevance
      меняется:
        address owner
        pledgeEstate
        newDuration+ previousTotalExplotationDuration
        количество токенов у newOwner и (previous) Owner
    gift
      переприсваивается owner без передачи токенов 
        address owner
        newDuration + previousTotalExplotationDuration
      
    pledge
      блокируются возможность транзакции и изменение статуса кроме автоматического изменения статуса залога через время залога
      переменные: 
        string public pledgeObject
        uint256 public pledgeSum
        uint256 public pledgePeriod

        
        
