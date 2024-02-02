// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.21;

import "forge-std/console.sol";

import {
    LRTIntegrationTest,
    ERC20,
    NodeDelegator,
    LRTOracle,
    PrimeStakedETH,
    LRTConfig,
    LRTDepositPool
} from "./LRTIntegrationTest.t.sol";

import { PRETHPriceFeed } from "../../contracts/oracles/PRETHPriceFeed.sol";

contract SkipLRTIntegrationTestETHMainnet is LRTIntegrationTest {
    function setUp() public override {
        string memory ethMainnetRPC = vm.envString("MAINNET_RPC_URL");
        fork = vm.createSelectFork(ethMainnetRPC);

        admin = 0xb3d125BCab278bD478CA251ae6b34334ad89175f;
        manager = 0xb3d125BCab278bD478CA251ae6b34334ad89175f;

        stWhale = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;
        ethXWhale = 0x1a0EBB8B15c61879a8e8DA7817Bb94374A7c4007;

        stEthOracle = 0x46E6D75E5784200F21e4cCB7d8b2ff8e20996f52;
        ethxPriceOracle = 0x4df5Cea2954CEafbF079c2d23a9271681D15cf67;

        EIGEN_STRATEGY_MANAGER = 0x858646372CC42E1A627fcE94aa7A7033e7CF075A;
        EIGEN_STETH_STRATEGY = 0x93c4b944D05dfe6df7645A86cd2206016c51564D;
        EIGEN_ETHX_STRATEGY = 0x9d7eD45EE2E8FC5482fa2428f15C971e6369011d;

        lrtDepositPool = LRTDepositPool(payable(0x551125a39bCf4E85e9B62467DfD2c1FeF3998f19));
        lrtConfig = LRTConfig(0x4BF4cc0e5970Cee11D67f5d716fF1241fA593ca4);
        preth = PrimeStakedETH(0xA265e2387fc0da67CB43eA6376105F3Df834939a);
        lrtOracle = LRTOracle(0xDE2336F1a4Ed7749F08F994785f61b5995FcD560);
        nodeDelegator1 = NodeDelegator(payable(0xfFEB12Eb6C339E1AAD48A7043A98779F6bF03Cfd));

        stETHAddress = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
        ethXAddress = 0xA35b1B31Ce002FBF2058D22F30f95D405200A15b;

        amountToTransfer = 0.11 ether;

        vm.startPrank(ethXWhale);
        ERC20(ethXAddress).approve(address(lrtDepositPool), amountToTransfer);
        lrtDepositPool.depositAsset(ethXAddress, amountToTransfer, minPrimeAmount, referralId);
        vm.stopPrank();

        uint256 indexOfNodeDelegator = 0;

        vm.prank(manager);
        lrtDepositPool.transferAssetToNodeDelegator(indexOfNodeDelegator, ethXAddress, amountToTransfer);
    }

    function test_morphoPriceFeed() public {
        address ethToUSDAggregatorAddress = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
        address prETHOracle = 0x349A73444b1a310BAe67ef67973022020d70020d;
        PRETHPriceFeed priceFeed = new PRETHPriceFeed(ethToUSDAggregatorAddress, prETHOracle, "PrimeStakedETH / USD");

        console.log("desc", priceFeed.description());
        console.log("decimals", priceFeed.decimals());
        console.log("version", priceFeed.version());
        // fetch answer from latestRound
        (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound) =
            priceFeed.latestRoundData();

        console.log("roundId", roundId);
        console.log("answer", uint256(answer));
        console.log("startedAt", startedAt);
        console.log("updatedAt", updatedAt);
        console.log("answeredInRound", answeredInRound);
    }
}
