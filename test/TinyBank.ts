import hre from "hardhat";
import { expect } from "chai";
import { DECIMALS, MINTING_AMOUNT } from "./constant";
import { MyToken, TinyBank } from "../typechain-types";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";

describe("TinyBank", () => {
  let signers: HardhatEthersSigner[];
  let myTokenC: MyToken;
  let tinyBankC: TinyBank;
  beforeEach(async () => {
    signers = await hre.ethers.getSigners();
    myTokenC = await hre.ethers.deployContract("MyToken", [
      "MyToken",
      "MT",
      DECIMALS,
      MINTING_AMOUNT,
    ]);
    tinyBankC = await hre.ethers.deployContract("TinyBank", [
      await myTokenC.getAddress(),
    ]);
    await myTokenC.setManager(await tinyBankC.getAddress());
  });

  describe("Initialized state check", () => {
    it("should return totalStaked 0", async () => {
      expect(await tinyBankC.totalStaked()).equal(0);
    });
    it("should return staked 0 amount of sugner0", async () => {
      const signer0 = signers[0];
      expect(await tinyBankC.staked(signer0.address)).equal(0);
    });
  });

  describe("Staking", () => {
    it("should return staked amount", async () => {
      const signer0 = signers[0];
      const stakingAmount = hre.ethers.parseUnits("50", DECIMALS);
      await myTokenC.approve(await tinyBankC.getAddress(), stakingAmount);
      await expect(tinyBankC.stake(stakingAmount))
        .to.emit(tinyBankC, "Staked")
        .withArgs(signer0.address, stakingAmount);
      expect(await tinyBankC.staked(signer0.address)).equal(stakingAmount);
      expect(await tinyBankC.totalStaked()).equal(stakingAmount);
      expect(await myTokenC.balanceOf(tinyBankC)).equal(
        await tinyBankC.totalStaked(),
      );
    });
  });

  describe("Withdraw", () => {
    it("should return 0 staked after withdrawing total token", async () => {
      const signer0 = signers[0];
      const stakingAmount = hre.ethers.parseUnits("50", DECIMALS);
      await myTokenC.approve(await tinyBankC.getAddress(), stakingAmount);
      await tinyBankC.stake(stakingAmount);
      await expect(tinyBankC.withdraw(stakingAmount))
        .to.emit(tinyBankC, "Withdraw")
        .withArgs(stakingAmount, signer0.address);
      expect(await tinyBankC.staked(signer0.address)).equal(0);
    });
  });

  describe("reward", () => {
    it("should reward 1MT every blocks", async () => {
      const signer0 = signers[0];
      const stakingAmount = hre.ethers.parseUnits("50", DECIMALS);
      await myTokenC.approve(await tinyBankC.getAddress(), stakingAmount);
      await tinyBankC.stake(stakingAmount);

      const before = await myTokenC.balanceOf(signer0.address);
      await tinyBankC.withdraw(stakingAmount);
      const after = await myTokenC.balanceOf(signer0.address);

      expect(after - before).equal(
        stakingAmount + hre.ethers.parseUnits("1", DECIMALS),
      );
    });

    it("Should revert when changing rewardPerBlock by hacker", async () => {
      const hacker = signers[3];
      const rewardToChange = hre.ethers.parseUnits("10000", DECIMALS);
      await expect(
        tinyBankC.connect(hacker).setRewardPerBlock(rewardToChange),
      ).to.be.revertedWith("You are not authorized to manage this contract");
    });
  });
  // const transferAmount = hre.ethers.parseUnits("1", DECIMALS);
  // for (var i = 0; i < 5; i++) {
  //   await myTokenC.transfer(transferAmount, signer0.address);
  // }

  // await tinyBankC.withdraw(stakingAmount);
  //   expect(await myTokenC.balanceOf(signer0.address)).equal(
  //     hre.ethers.parseUnits((BLOCKS + MINTING_AMOUNT + 1n).toString()),
  //   );
  // });

  // describe("Manager confirm & setRewardPerBlock", () => {
  //   const newReward = hre.ethers.parseUnits("2", DECIMALS);

  //   it("should revert confirm from a non-manager", async () => {
  //     await expect(tinyBankC.connect(signers[5]).confirm()).to.be.revertedWith(
  //       "You are not one of managers",
  //     );
  //   });

  //   it("should revert setRewardPerBlock when no one confirmed", async () => {
  //     await expect(tinyBankC.setRewardPerBlock(newReward)).to.be.revertedWith(
  //       "Not all managers confirmed yet",
  //     );
  //   });

  //   it("should revert setRewardPerBlock when only some managers confirmed", async () => {
  //     for (let i = 0; i < 3; i++) {
  //       await tinyBankC.connect(signers[i]).confirm();
  //     }
  //     await expect(tinyBankC.setRewardPerBlock(newReward)).to.be.revertedWith(
  //       "Not all managers confirmed yet",
  //     );
  //   });

  //   it("should change rewardPerBlock after all managers confirmed", async () => {
  //     for (let i = 0; i < 5; i++) {
  //       await tinyBankC.connect(signers[i]).confirm();
  //     }
  //     await expect(tinyBankC.setRewardPerBlock(newReward)).not.to.be.reverted;
  //     // 실행 후 confirmed가 reset 되므로 다시 호출하면 revert
  //     await expect(tinyBankC.setRewardPerBlock(newReward)).to.be.revertedWith(
  //       "Not all managers confirmed yet",
  //     );
  //   });
  // });
});
