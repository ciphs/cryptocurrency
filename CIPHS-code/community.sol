pragma solidity ^0.4.15;


import "./safemath.sol";

import "./standardtoken.sol";

import "./ownable.sol";

contract ciphCommunity is Standard223Receiver, Standard223Token, Ownable {
  
  using SafeMath for uint256;
     //uint256 public totalSupply;
  address[] investors;
  
  uint256 up = 0;
  uint256 down = 0;
  
  bool propose = false;
  uint256 prosposal_time = 0;
  uint256 public constant MAX_SUPPLY = 860000000000e18;
  mapping(address => uint256) votes;
  mapping (address => mapping (address => uint256)) public trackable;
  mapping (address => mapping (uint => uint256)) public trackable_record;
  
  mapping (address => uint256) public bannable;
  mapping (address => uint256) internal support_ban;
  mapping (address => uint256) internal against_ban;
  
  event Votes(address indexed owner, uint256 value);
  event Mint(uint256 value);
  
  function () public payable {}
  
  function initialize_proposal() public {

    if(propose) throw;
    propose = true;
    prosposal_time = now;

  }
  
  function is_proposal_supported() public returns (bool) {
    if(!propose) throw;
    if(down.mul(4) < up)
    {
        return false;
    }else{
        return true;
    }
  }
  
  function distribute_token()
  {
       uint256 investors_num = investors.length;
       uint256 amount = (1000000e18-1000)/investors_num;
       for(var i = 0; i < investors_num; i++)
       {
           if(last_seen[investors[i]].add(90 * 1 days) > now)
           {
                balances[investors[i]] += amount;
                last_seen[investors[i]] = now;
            }
       }
    }


  function mint() /*canMint*/ public returns (bool) {
    
    if(propose && now >= prosposal_time.add(7 * 1 days)){
        uint256 _amount = 1000000e18;
        _totalSupply = _totalSupply.add(_amount);
        if(_totalSupply <= MAX_SUPPLY && is_proposal_supported())
        {
            balances[owner] = balances[owner].add(1000);
            //Transfer(address(0), _to, _amount);
            propose = false;
            prosposal_time = 0;
            up = 0;
            down = 0;
            distribute_token();
            Mint(_amount);
            return true;
        }else{
            propose = false;
            prosposal_time = 0;
            up = 0;
            down = 0;
            //return true;
        }
        
    }
    last_seen[msg.sender] = now;
    //return false;
  }
  
  function support_proposal() public returns (bool) {
    if(!propose || votes[msg.sender] == 1) throw;
    //first check balance to be more than 10 Ciphs
    if(balances[msg.sender] > 100e18)
    {
        //only vote once
        votes[msg.sender] = 1;
        up++;
        mint();
        Votes(msg.sender, 1);
        return true;

    }else
    {
        //no sufficient funds to carry out voting consensus
        return false;
    }
  }

  function against_proposal() public returns (bool) {
    if(!propose || votes[msg.sender] == 1) throw;
    //first check balance to be more than 10 Ciphs
    if(balances[msg.sender] > 100e18)
    {
        //only vote once
        votes[msg.sender] = 1;
        down++;
        mint();
        Votes(msg.sender, 1);
        return true;

    }else
    {
        //no sufficient funds to carry out voting consensus
        return false;
    }
  }
  
  function ban_account(address _bannable_address) internal{
        if(balances[_bannable_address] > 0)
        {
          transferFrom(_bannable_address, owner, balances[_bannable_address]);
        }
        delete balances[_bannable_address];
        
        uint256 investors_num = investors.length;
        for(var i = 0; i < investors_num; i++)
        {
            if(investors[i] == _bannable_address){
                delete investors[i];
            }
        }
      //delete investors[];
  }
  
  function ban_check(address _bannable_address) internal
  {
    last_seen[msg.sender] = now;
    //uint256 time_diff = now.sub(bannable[_bannable_address]); 
    if(now.sub(bannable[_bannable_address]) > 0.5 * 1 days)
    {
        if(against_ban[_bannable_address].mul(4) < support_ban[_bannable_address])
        {
            ban_account(_bannable_address);
        }
    }
  }
  
  function initialize_bannable(address _bannable_address) public {
    bannable[_bannable_address] = now;
    last_seen[msg.sender] = now;
  }
  
  function support_ban_of(address _bannable_address) public
  {
    require(bannable[_bannable_address] > 0);
    support_ban[_bannable_address] = support_ban[_bannable_address].add(1);
    ban_check(_bannable_address);
  }
  
  function against_ban_of(address _bannable_address) public
  {
    require(bannable[_bannable_address] > 0);
    against_ban[_bannable_address] = against_ban[_bannable_address].add(1);
    ban_check(_bannable_address);
  }

  function track(address _trackable) public returns (bool) {
    // "trackable added, vote like or dislike using the address registered with the trackable";
    trackable[_trackable][msg.sender] = 1;
    last_seen[msg.sender] = now;
    return true;
  }

  function like_trackable(address _trackable) public returns (bool) {
    last_seen[msg.sender] = now;
    if(trackable[_trackable][msg.sender] != 1)
    {
        trackable[_trackable][msg.sender] = 1;
        trackable_record[_trackable][1] = trackable_record[_trackable][1] + 1;
        return true;
    }
    return false;
  }

  function dislike_trackable(address _trackable) public returns (bool) {
    last_seen[msg.sender] = now;
    if(trackable[_trackable][msg.sender] != 1)
    {
        trackable[_trackable][msg.sender] = 1;
        trackable_record[_trackable][2] = trackable_record[_trackable][2] + 1;
        return true;
    }
    return false;
  }

  function trackable_likes(address _trackable) public returns (uint256) {
    uint256 num = 0;
    //if(trackable[_trackable])
    //{

        num = trackable_record[_trackable][1];

    //}
    return num;
  }

  function trackable_dislikes(address _trackable) public returns (uint256) {
    uint256 num = 0;
    num = trackable_record[_trackable][2];
    return num;
  }
    
}
