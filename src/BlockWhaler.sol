// SPDX-License-Identifier: MIT
// An example of a consumer contract that relies on a subscription for funding.
pragma solidity 0.8.20;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts@1.1.1/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {LinkTokenInterface} from "@chainlink/contracts@1.1.1/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {VRFV2PlusClient} from "@chainlink/contracts@1.1.1/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import { MyToken } from "./MyToken.sol";
import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract BlockWhalerV3 is VRFConsumerBaseV2Plus {
    mapping(uint => address) public shootingStatus;
    uint256 public minMintAmount = 1000000000000000000; // 1 LINK
    address public fishNftAddress = 0x9328010C4d16740Fa4fD18837D3178F0e6e70eb5;
    address public fishPoolAddress = 0x390bb4C1e2a81c6341224138b9b6FcAA8f9e3E22;
    uint256 public s_subscriptionId = 113800401297404484128801628471587050326250125118878756374450775171794310439111;

    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);
    event ShotResult(address requester, uint256 nftId, bool result);

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
        address requester; // address that made the request
        uint256 nftId; // nft id
    }
    mapping(uint256 => RequestStatus)
        public s_requests; /* requestId --> requestStatus */

    // Your subscription ID.

    // Past request IDs.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf/v2-5/supported-networks
    bytes32 public keyHash =
        0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 public callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 public requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2_5.MAX_NUM_WORDS.
    uint32 public numWords = 1;

    /**
     * HARDCODED FOR SEPOLIA
     * COORDINATOR: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B
     */
    constructor() VRFConsumerBaseV2Plus(0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B) {
    }

    address linkAddress = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    IERC20 linkToken = IERC20(linkAddress);
    MyToken fishNft = MyToken(fishNftAddress);

    function setFishNftAddress(address _fishNftAddress) external onlyOwner {
        fishNftAddress = _fishNftAddress;
    }

    function setFishPoolAddress(address _fishPoolAddress) external onlyOwner {
        fishPoolAddress = _fishPoolAddress;
    }

    function setSubscriptionId(uint256 _subscriptionId) external onlyOwner {
        s_subscriptionId = _subscriptionId;
    }

    function shotFish(uint256 nftId, uint256 amount) external returns(uint256 requestId) {
        require(fishNftAddress != address(0), "fish nft not set");
        require(fishPoolAddress != address(0), "fish pool not set");
        require(shootingStatus[nftId] == address(0), "fish already shot");
        require(amount >= minMintAmount , "amount too low");
        linkToken.transferFrom(msg.sender, address(this), amount);
        shootingStatus[nftId] = msg.sender;
        requestId = requestRandomWords(false,nftId);
    }

    // Assumes the subscription is funded sufficiently.
    // @param enableNativePayment: Set to `true` to enable payment in native tokens, or
    // `false` to pay in LINK
    function requestRandomWords(
        bool enableNativePayment,
        uint256 nftId
    ) internal returns (uint256 requestId) {
        // Will revert if subscription is not set and funded.
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({
                        nativePayment: enableNativePayment
                    })
                )
            })
        );
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false,
            nftId: nftId,
            requester: msg.sender
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] calldata _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords);

        uint256 nftId = s_requests[_requestId].nftId;
        bool result = (_randomWords[0] % 10000 + 1) <= ratio;
        uint ratio = fishNft.ratio(nftId);
        address requester = s_requests[_requestId].requester;
        emit ShotResult(requester, nftId, result);

        if (result) {
            fishNft.transferFrom(fishPoolAddress, requester, nftId);
        } else {
            shootingStatus[nftId] = address(0);
        }
    }

    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(linkAddress);
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }
}
