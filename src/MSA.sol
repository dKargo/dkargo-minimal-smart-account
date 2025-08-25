// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {IEntryPoint} from "@openzeppelin/contracts/interfaces/draft-IERC4337.sol";

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {ERC4337Utils,PackedUserOperation} from "@openzeppelin/contracts/account/utils/draft-ERC4337Utils.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {SignerECDSA} from "@openzeppelin/contracts/utils/cryptography/signers/SignerECDSA.sol";
import {AbstractSigner} from "@openzeppelin/contracts/utils/cryptography/signers/AbstractSigner.sol";
import {Account} from "@openzeppelin/contracts/account/Account.sol";
import {AccountERC7579Hooked} from "@openzeppelin/contracts/account/extensions/draft-AccountERC7579Hooked.sol";
import {AccountERC7579} from "@openzeppelin/contracts/account/extensions/draft-AccountERC7579.sol";
import {IERC1271} from "@openzeppelin/contracts/interfaces/IERC1271.sol";
import {IERC7579Validator, MODULE_TYPE_VALIDATOR} from "@openzeppelin/contracts/interfaces/draft-IERC7579.sol";
import {Calldata} from "@openzeppelin/contracts/utils/Calldata.sol";

contract MinimalSmartAccount is Initializable, Account, IERC1271, AccountERC7579Hooked, SignerECDSA, ERC721Holder, ERC1155Holder {

    constructor() SignerECDSA(address(0x00)) {
        _disableInitializers();
    }

     function initialize(address signerAddr) public initializer {
       _setSigner(signerAddr);
     }

    function entryPoint() public view virtual override returns (IEntryPoint) {
        return ERC4337Utils.ENTRYPOINT_V07;
    }

    function _validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash)
        internal
        override(Account, AccountERC7579)
        returns (uint256)
    {
        return super._validateUserOp(userOp, userOpHash);
    }
    
    function isValidSignature(bytes32 hash, bytes calldata signature)
        public
        view
        override(IERC1271, AccountERC7579)
        returns (bytes4)
    {
        // check signature length is enough for extraction
        if (signature.length >= 20) {
            (address module, bytes calldata innerSignature) = _extractSignatureValidator(signature);
            // if module is not installed, skip
            if (isModuleInstalled(MODULE_TYPE_VALIDATOR, module, Calldata.emptyBytes())) {
                // try validation, skip any revert
                try IERC7579Validator(module).isValidSignatureWithSender(msg.sender, hash, innerSignature) returns (
                    bytes4 magic
                ) {
                    return magic;
                } catch {}
            } else {
                if(_rawSignatureValidation(hash, signature)) {
                    return 0x1626ba7e; // EIP1271MagicValue
                }
            }
        }
        return bytes4(0xffffffff);
    }

    // IMPORTANT: Make sure SignerECDSA is most derived than AccountERC7579
    // in the inheritance chain (i.e. contract ... is AccountERC7579, ..., SignerECDSA)
    // to ensure the correct order of function resolution.
    // AccountERC7579 returns false for `_rawSignatureValidation`
    function _rawSignatureValidation(bytes32 hash, bytes calldata signature)
        internal
        view
        override(SignerECDSA, AbstractSigner, AccountERC7579)
        returns (bool)
    {
        return super._rawSignatureValidation(hash, signature);
    }
}