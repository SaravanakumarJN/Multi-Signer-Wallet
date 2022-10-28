const hre = require('hardhat')

const runScript = async () => {
  // ethers.getSigners() method gives ten random signer object with address
  const [owner1, owner2, owner3, recipient] = await hre.ethers.getSigners()

  const multiSignerWallet = await hre.ethers.getContractFactory("MultiSignerWallet")
  const iMultiSignerWallet = await multiSignerWallet.deploy([owner1.address, owner2.address, owner3.address], 2)
  iMultiSignerWallet.deployed()

  // add fund to the contract wallet
  await iMultiSignerWallet.addFunds({value: 5})

  // get contract wallet balance
  const contarctWalletBalanceBeforeTransfer = await ethers.provider.getBalance(iMultiSignerWallet.address);
  console.log("Contarct Balance (before transfer)" ,contarctWalletBalanceBeforeTransfer)

  let allTransfersBefore = await iMultiSignerWallet.getAllTransfers()
  console.log(allTransfersBefore)

  await iMultiSignerWallet.createTransfer(1, recipient.address)

  // By default, the methods are called by 1st signer address inorder to call it different address we use connect and pass signer details.
  let approve1Tx = await iMultiSignerWallet.connect(owner1).approveTransfer(0)
  await approve1Tx.wait()

  let approve2Tx = await iMultiSignerWallet.connect(owner2).approveTransfer(0)
  await approve2Tx.wait()

  let allTransfersAfter = await iMultiSignerWallet.getAllTransfers()
  console.log(allTransfersAfter)

  const contarctWalletBalanceAfterTransfer = await ethers.provider.getBalance(iMultiSignerWallet.address);
  console.log("Contarct Balance (after transfer)" , contarctWalletBalanceAfterTransfer)
}

runScript().catch((error) => {
  console.log(error)
  process.exitCode = 1
})