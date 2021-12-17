const main = async () => {
	const nftContractFactory = await hre.ethers.getContractFactory('MyEpicNFT');
	const nftContract = await nftContractFactory.deploy();
	await nftContract.deployed();
	console.log('Contract was deployed to: ', nftContract.address);

	// Call our Function
	let txn = await nftContract.makeAnEpicNFT();

	// Wait for it to be minted
	await txn.wait();
	console.log('NFT was minted');
};

const runMain = async () => {
	try {
		await main();
		process.exit(0);
	} catch (error) {
		console.log('uh-oh', error);
		process.exit(1);
	}
};

runMain();
