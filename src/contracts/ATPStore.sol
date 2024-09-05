// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "ATP.sol";

contract ATPStore is AccessControl {
    ATP public ATPCredit;
    bytes32 public constant API_ROLE = keccak256("API_ROLE");
    address public treasurerWallet;
    AggregatorV3Interface internal priceFeed;
    uint256 buyTokenEfforce = 232918;
    
    struct Purchase {
        uint256 tokenAmount;
        uint256 paidWei;
        uint256 timestamp;
    }

    struct Package {
        string name;
        uint256 priceCentUSD;
        uint256 tokenAmount;
    }

    mapping(address => Purchase[]) public purchaseRecords;
    mapping(uint256 => Package) public packages;
    uint256 public packageCount; // Contador para generar IDs de paquetes

    event TokenPurchased(address indexed buyer, uint256 tokenAmount, uint256 paidWei);

    constructor(address _ATPContract, address _priceFeed, address _treasurerWallet) {
        require(_ATPContract != address(0), "ATP Contract address cannot be the zero address");
        require(_priceFeed != address(0), "Price Feed address cannot be the zero address");
        require(_treasurerWallet != address(0), "Treasurer Wallet address cannot be the zero address");
        ATPCredit = ATP(_ATPContract);
        treasurerWallet = _treasurerWallet;
        priceFeed = AggregatorV3Interface(_priceFeed);
        _grantRole(API_ROLE, msg.sender);
    }

    function setPriceFeed (address _contractAddress) public onlyRole(API_ROLE){
        priceFeed = AggregatorV3Interface(_contractAddress);
    }

    function addPackage(string memory name, uint256 priceCentUSD, uint256 tokenAmount) public onlyRole(API_ROLE) {
        packages[packageCount] = Package(name, priceCentUSD, tokenAmount);
        packageCount++;
    }

    function updatePackage(uint256 packageId, string memory name, uint256 priceCentUSD, uint256 tokenAmount) public onlyRole(API_ROLE) {
        packages[packageId] = Package(name, priceCentUSD, tokenAmount);
    }

    function buyToken(uint256 packageId) public payable {
        require(packageId < packageCount, "Invalid package ID");
        Package memory pkg = packages[packageId];
        uint256 costWei = getPackagePrice(packageId);
        require(msg.value >= costWei, "Insufficient Ether sent.");
        processPayment(msg.sender, pkg.tokenAmount, costWei);
    }

    function processPayment(address buyer, uint256 tokenAmount, uint256 paidWei) private {
        (bool success, ) = treasurerWallet.call{value: paidWei}("");
        require(success, "Failed to send Ether");
        ATPCredit.mint(buyer, tokenAmount);
        emit TokenPurchased(buyer, tokenAmount, paidWei);
        purchaseRecords[buyer].push(Purchase({
            tokenAmount: tokenAmount,
            paidWei: paidWei,
            timestamp: block.timestamp
        }));
        if (msg.value > paidWei) {
            payable(buyer).transfer(msg.value - paidWei);
        }
    }

    function transferPackageFromAPI(address to, uint256 packageId) public onlyRole(API_ROLE) {
        require(packageId < packageCount, "Invalid package ID");
        Package memory pkg = packages[packageId];
        ATPCredit.mint(to, pkg.tokenAmount);
        uint256 costWei = getPackagePrice(packageId);
        emit TokenPurchased(to, pkg.tokenAmount, costWei);
    }

    function transferTokenFromAPI(address to, uint256 amount) public onlyRole(API_ROLE) {
        ATPCredit.mint(to, amount);
        emit TokenPurchased(to, amount, 0);
    }

    function consumeToken(address from, uint256 amount) public onlyRole(API_ROLE) {
        ATPCredit.autoBurn(from, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public onlyRole(API_ROLE) {
        ATPCredit.autoTransfer(from, to, amount);
    }

    function getBalance(address from) public view returns(uint256) {
        return ATPCredit.balanceOf(from);
    }

    function getPackagePrice(uint256 packageId) public view returns (uint256){
        require(packageId < packageCount, "Invalid package ID");
        Package memory pkg = packages[packageId];
        int USDPriceCoef = getLatestPrice(); // Precio de ETH en USD
        uint256 costWei = (uint256((1e18/USDPriceCoef))*1e6)*pkg.priceCentUSD;
        uint256 gasCost = estimateGasCost(); // Estimar el costo del gas
        return costWei > gasCost ? costWei - gasCost : 0;
    }

    function settbuyTokenEfforce(uint256 newEfforce) public onlyRole(API_ROLE) {
        buyTokenEfforce = newEfforce;
    }

    function estimateGasCost() public view returns (uint256) {
        return buyTokenEfforce * currentGasPrice(); // Estimación del costo en wei
    }

    function currentGasPrice() public view returns (uint256) {
        return block.basefee + tx.gasprice; // tx.gasprice aquí representaría maxPriorityFeePerGas en EIP-1559
    }
    
    function getLatestPrice() public view returns (int) {
        (
            , 
            int price,
            ,
            ,
        ) = priceFeed.latestRoundData();
        return price;
    }
}
