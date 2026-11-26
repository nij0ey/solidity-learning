import { HardhatUserConfig, vars } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-ignition-ethers";
import "@nomiclabs/hardhat-vyper";

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  vyper: {
    version: "0.3.0",
  },
  networks: {
    kairos: {
      url: "https://public-en-kairos.node.kaia.io",
      accounts: [vars.get("KAIROS_PRIVATE_KEY")],
    },
  },
  etherscan: {
    apiKey: {
      kairos: "unnecessary",
    },
    customChains: [
      {
        network: "kairos",
        chainId: 1001,
        urls: {
          apiURL: "https://compiler-api-v2.kaiascan.io/kairos/hardhat-verify",
          browserURL: "https://kairos.kaiascan.io",
        },
      },
    ],
  },
};

export default config;

// MyTokenDeploy#MyToken - 0xB3bDfaAd28641ddFBA0b4383968f2B80cC47A562
// MyTokenDeploy#TinyBank - 0xA05228B2Cd39228E030BDA4C54a55c0cCd86F086
