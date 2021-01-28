pragma solidity 0.6.2;

/**
 * @dev This is a simple contract that emmits input as an event.
 */
contract Emitter {
  event Claim(string _value);

  constructor() public {}

  /**
   * @dev Emits an event with the input.
   * @param _value String we want to emmit.
   */
  function emitClaim(string calldata _value) external {
    emit Claim(_value);
  }
}
