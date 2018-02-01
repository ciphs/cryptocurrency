pragma solidity ^0.4.15;

import "./community.sol";

contract Ciphs is ciphCommunity{

  //using SafeMath for uint256;
  
  string public constant name = "Ciphs";
  string public constant symbol = "CIPHS";
  uint8 public constant decimals = 18;

  uint256 public rate = 1000000e18;
  uint256 raisedAmount = 0;
  uint256 public constant INITIAL_SUPPLY = 7000000e18;
 

  //event Approval(address indexed owner, address indexed spender, uint256 value);
  //event Transfer(address indexed from, address indexed to, uint256 value);
  event BoughtTokens(address indexed to, uint256 value);
  
  event Burn(address indexed burner, uint256 value);

  
  function Ciphs() public {
    _totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }


  modifier canMint() {
    if(propose && is_proposal_supported() && now > prosposal_time.add(7 * 1 days))
    _;
    else
    throw;
  }
  
    
  function () public payable {

    buyTokens();

  }
  
  
  function buyTokens() public payable {
      
    //require(propose);
    
    uint256 weiAmount = msg.value;
    uint256 tokens = weiAmount.mul(getRate());
    
    tokens = tokens.div(1 ether);
    
    BoughtTokens(msg.sender, tokens);

    balances[msg.sender] = balances[msg.sender].add(tokens);
    balances[owner] = balances[owner].sub(tokens);
    _totalSupply.sub(tokens);

    raisedAmount = raisedAmount.add(msg.value);
    
    investors.push(msg.sender) -1;
    
    last_seen[msg.sender] = now;
    //owner.transfer(msg.value);
  }
  
  function getInvestors() view public returns (address[]){
      return investors;
  }

  
  function setRate(uint256 _rate) public onlyOwner{
      rate = _rate;
  }
  
  function getRate() public constant returns (uint256){
      
      return rate;
      
  }

  function burn(uint256 _value) public {
        require(_value > 0);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        _totalSupply = _totalSupply.sub(_value);
        Burn(msg.sender, _value);
        last_seen[msg.sender] = now;
  }
  
  function sendEtherToOwner() public onlyOwner {                       
      owner.transfer(this.balance);
  }
  
  function destroy() internal onlyOwner {
    selfdestruct(owner);
  }


}