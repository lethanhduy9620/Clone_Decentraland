// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0<0.9.0;

import "./LANDStorage.sol";
import "./AssetRegistryStorage.sol";
import "./OwnableStorage.sol";


contract Storage is LANDStorage, AssetRegistryStorage, OwnableStorage {}