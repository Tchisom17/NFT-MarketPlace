import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const name = "MarketPlace";
const symbol = "MKP";

const NFTMarketPlaceModule = buildModule("NFTMarketPlaceModule", (m) => {
  const nftMarketPlace = m.contract("NFTMarketPlace", [name, symbol]);

  return { nftMarketPlace };
});

export default NFTMarketPlaceModule;
