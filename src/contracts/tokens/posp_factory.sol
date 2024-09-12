// SPDX-License-Identifier: MIT
pragma solidity = 0.8.7;
import "./posp.sol";
contract POSPTokenFactory is Ownable{
    struct Token{
        string name;
        string symbol;
        address lab_emmiter;
        PoSP sm_address;
    }
    event tokenCreationEvent(
        address emmiter_address,
        PoSP sm_address
    );

    mapping (address => Token) contracts;
    mapping (address => PoSP[]) userTokens;
    
    function createToken(string memory _name, string memory _symbol, address _lab) public onlyOwner returns (PoSP) {
        if (isStringEmpty(_name)){
            _name = "Proof OF Stake Protocol";  
        }
        if (isStringEmpty(_symbol)){
            _symbol = "POSP";
        }
        PoSP sm_posp_token = new PoSP(_name, _symbol);

        Token memory tknstruct = Token({
            name:_name,
            symbol:_symbol,
            lab_emmiter:_lab,
            sm_address: sm_posp_token
        });

        contracts[_lab] = tknstruct;
        emit tokenCreationEvent(_lab, sm_posp_token);
        return sm_posp_token;
    }

    function mintInstancePOSP(PoSP _token_contract_address, PoSP.PoSPStruct memory PoSPToken)public onlyOwner{
        _token_contract_address.mintPOSP(PoSPToken);
        userTokens[PoSPToken.user].push(_token_contract_address);
    }

    function getTokensByUsers(address _user) public view returns(PoSP[] memory _allUserTokens){
        return userTokens[_user];
    }

    function transferInstancePOSPOwner(address _newSMOwner, PoSP _token_contract_address ) public onlyOwner{
        _token_contract_address.transferOwnership(_newSMOwner);
    }
    //this name is wromg we are getting the sm address, and no the laboratiory asdres
    //suggested name getTokenSmartContractAddress()
    function getTokenSmartContractAddress(address _lab) public view returns(Token memory){
        return contracts[_lab];
    }

    function isStringEmpty(string memory value) internal pure returns(bool){
        bytes1 space = ' ';
        bytes memory str = bytes(value);
        bool _isEmpty = true;
        for (uint i=0; i<str.length; i++){
            if(str[i] != space){
                _isEmpty = false;
            }
        }
        return _isEmpty;
    }
}