// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract MultiSignerWallet{
  // wallet owners object
  mapping(address => bool) private owners;
  // min. approval needed for transfer
  uint private approverThreshold;


  /*
  create approval tracker object
    {
      ownwerAddress: {
        transferId: approvedStatus
      }
    }
  */ 
  mapping(address => mapping(uint => bool)) private approvalTracker;

  // model for transfer
  struct transferObject{
    uint id;
    uint amount;
    address payable receiver;
    uint approvedCount;
    bool isTransfered;
  }

  // transfers array
  transferObject[] public allTransfers;

  constructor(address[] memory _owners, uint _approverThreshold){
    // create object from owners array
    for(uint i = 0; i < _owners.length; i++){
      owners[_owners[i]] = true;
    }
    approverThreshold = _approverThreshold;
  }

  function getAllTransfers() external view returns(transferObject[] memory){
    return allTransfers;
  }

  function createTransfer(uint amount, address payable receiver) external {
    // check if the creater is a owner
    require(owners[msg.sender] == true, "You are not authorised to create a transfer");

    // create a transfer object with given details
    transferObject memory newTransfer = transferObject(allTransfers.length, amount, receiver, 0, false);
    // add the created transfer to allTransfers
    allTransfers.push(newTransfer);
  } 

  function approveTransfer(uint transferId) external payable {
    // check if the approver is a owner
    require(owners[msg.sender] == true, "You are not authorised to approve the transfer");

    // select the transfer which is to be approved
    transferObject storage transferDetails = allTransfers[transferId];

    // check if it's already transfered
    require(transferDetails.isTransfered == false, "Already transfered");

    // check if the caller already approved the current transfer
    require(approvalTracker[msg.sender][transferId] == false , "You already approved this transfer");
    // if not update in approval tracker and increase the approvedCount
    approvalTracker[msg.sender][transferId] = true;
    transferDetails.approvedCount++;
    
    // if approvedCount >= threshold, transfer the amount and update transfered status
    if(transferDetails.approvedCount >= approverThreshold){
      transferDetails.receiver.transfer(transferDetails.amount);
      transferDetails.isTransfered = true;
    }
  }

  function addFunds() external payable {}
}