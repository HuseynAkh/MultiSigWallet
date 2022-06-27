pragma solidity 0.7.5;
pragma abicoder v2;


contract Wallet {
    address[] public owners;
    uint minApproval;


    Transfer[] transferReq;
    mapping(address => mapping(uint => bool)) approvals;

    struct Transfer{
        uint amount;
        address payable receiver;
        uint approvals;
        bool isSent;
        uint id;
    }

    modifier onlyOwners(){
        bool owner = false;

        for(uint i = 0; i < owners.length; i++){
            if(owners[i] == msg.sender){
                owner = true;
            }
        }
        require(owner == true, "Not Owner");
        _;
    }


    constructor(address[] memory _owners, uint _minApproval){
        owners = _owners;
        minApproval = _minApproval;
    }

    function deposit() public payable{
        //Keep empty
    }

    function transfer(uint _amount, address payable _receiver) public onlyOwners{
        transferReq.push( Transfer(_amount, _receiver, 0, false, transferReq.length) );
    }

    function approve(uint _id) public onlyOwners{
        require(approvals[msg.sender][_id] == false, "Already approved");
        require(transferReq[_id].isSent == false, "Transaction already sent");

        approvals[msg.sender][_id] = true;
        transferReq[_id].approvals++;

        if(transferReq[_id].approvals >= minApproval){
            transferReq[_id].receiver.transfer(transferReq[_id].amount);
            transferReq[_id].isSent = true;
        }
    }

    function getTransferRequests() public view returns (Transfer[] memory){
        return transferReq;
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}
