const { assert, expect } = require("chai");
const { deployments, ethers, network } = require("hardhat");
const { developmentChains } = require("../../helper-hardhat-config");

!developmentChains.includes(network.name)
    ? describe.skip
    : describe("Random NFT Unit Tests:", function () {
          let randomNFT, deployer, coordinatorMock;

          beforeEach(async function () {
              accounts = await ethers.getSigners();
              deployer = accounts[0];
              await deployments.fixture(["mocks", "random-nft"]);
              randomNFT = await ethers.getContract("RandomNFT");
              coordinatorMock = await ethers.getContract(
                  "VRFCoordinatorV2Mock"
              );
          });

          describe("Constructor:", function () {
              it("Sets starting values correctly.", async function () {
                  const tokenURIZero = await randomNFT.getTokenURIs(0);
                  assert(tokenURIZero.includes("ipfs://"));
              });
          });

          describe("Function <requestNFT>:", function () {
              it("Fails if the payment is not sent with the request.", async function () {
                  await expect(randomNFT.requestNFT()).to.be.revertedWith(
                      "RandomNFT__NotEnoughETHSent"
                  );
              });

              it("Emits an event and starts a random word request.", async function () {
                  const mintFee = await randomNFT.getMintFee();
                  await expect(
                      randomNFT.requestNFT({ value: mintFee.toString() })
                  ).to.emit(randomNFT, "NFTRequested");
              });
          });

          describe("Function <fulfillRandomWords>:", function () {
              it("Mints an NFT after a random number is returned.", async function () {
                  await new Promise(async (resolve, reject) => {
                      randomNFT.once("NFTMinted", async function () {
                          try {
                              const tokenURI = await randomNFT.tokenURI("0");
                              const tokenCounter =
                                  await randomNFT.getTokenCounter();
                              assert.equal(
                                  tokenURI.toString().includes("ipfs://"),
                                  true
                              );
                              assert.equal(tokenCounter.toString(), "1");
                              resolve();
                          } catch (error) {
                              console.log(error);
                              reject(error);
                          }
                      });
                      try {
                          const mintFee = await randomNFT.getMintFee();
                          const requestNFTResponse = await randomNFT.requestNFT(
                              {
                                  value: mintFee.toString(),
                              }
                          );
                          const requestNFTReceipt =
                              await requestNFTResponse.wait(1);
                          await coordinatorMock.fulfillRandomWords(
                              requestNFTReceipt.events[1].args.requestId,
                              randomNFT.address
                          );
                      } catch (error) {
                          console.log(error);
                          reject(error);
                      }
                  });
              });
          });
      });
