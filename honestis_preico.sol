Deployed at:
https://gastracker.io/contract/0x9555347fe761fe5f50f1d047c7913aabc813975d
https://gastracker.io/ according to gastracker:
fundingStartBlock = 3910498;
fundingEndBlock = 4037025;
MinCap = 10000 ether classic

pragma solidity ^0.4.4;


/// @title Migration Agent interface
contract MigrationAgent {
    function migrateFrom(address _from, uint256 _value);
}

/// @title Honestis.Network Token (HNT) - crowdfunding code for Honestis Network Token PreICO
contract HonestisNetworkTokenpreICO {
    string public constant name = "preICO Honestis Network Token";
    string public constant symbol = "HNT";
    uint8 public constant decimals = 18;  // 18 decimal places, the same as ETH/ETC.

    uint256 public constant tokenCreationRate = 1000;

    // The funding cap in weis.
    uint256 public constant tokenCreationCap = 830000 ether * tokenCreationRate;
    uint256 public constant tokenCreationMin = 10000 ether * tokenCreationRate;

    uint256 public fundingStartBlock = 3910498;
    uint256 public fundingEndBlock = 4037025;

    // The flag indicates if the HNT contract is in Funding state.
    bool public funding = true;

    // Receives ETC and its own HNT endowment.
    address public honestisFort = 0x82B8BA724b5CcA94e3F71EBCEd93e73ca68209A0;

    // Has control over token migration to next version of token.
    address public migrationMaster = 0x84bBFCbf59358D976F5D305e99731Da8e9709B65;


    // The current total token supply.
    uint256 totalTokens;
	uint256 bonusCreationRate;
    mapping (address => uint256) balances;
    mapping (address => uint256) balancesRAW;
    
    address public migrationAgent;
    uint256 public totalMigrated;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Migrate(address indexed _from, address indexed _to, uint256 _value);
    event Refund(address indexed _from, uint256 _value);

    function HonestisNetworkTokenpreICO() {

        if (honestisFort == 0) throw;
        if (migrationMaster == 0) throw;
        if (fundingStartBlock <= block.number) throw;
        if (fundingEndBlock   <= fundingStartBlock) throw;


     //   migrationMaster = _migrationMaster;
     //   honestisFort = _honestisFort;
     //   fundingStartBlock = _fundingStartBlock;
     //   fundingEndBlock = _fundingEndBlock;
    }

    /// @notice Transfer `_value` HNT tokens from sender's account
    /// `msg.sender` to provided account address `_to`.
    /// @notice This function is disabled during the funding.
    /// @dev Required state: Operational
    /// @param _to The address of the tokens recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool) {
        // Abort if not in Operational state.
        if (funding) throw;
//end of July
        var senderBalance = balances[msg.sender];
        if (senderBalance >= _value && _value > 0) {
            senderBalance -= _value;
            balances[msg.sender] = senderBalance;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    function totalSupply() external constant returns (uint256) {
        return totalTokens;
    }

    function balanceOf(address _owner) external constant returns (uint256) {
        return balances[_owner];
    }

    // Token migration support:

    /// @notice Migrate tokens to the new token contract.
    /// @dev Required state: Operational Migration
    /// @param _value The amount of token to be migrated
    function migrate(uint256 _value) external {
        // Abort if not in Operational Migration state.
        if (funding) throw;
        if (migrationAgent == 0) throw;

        // Validate input value.
        if (_value == 0) throw;
        if (_value > balances[msg.sender]) throw;

        balances[msg.sender] -= _value;
        totalTokens -= _value;
        totalMigrated += _value;
        MigrationAgent(migrationAgent).migrateFrom(msg.sender, _value);
        Migrate(msg.sender, migrationAgent, _value);
    }

    /// @notice Set address of migration target contract and enable migration
	/// process.
    /// @dev Required state: Operational Normal
    /// @dev State transition: -> Operational Migration
    /// @param _agent The address of the MigrationAgent contract
    function setMigrationAgent(address _agent) external {
        // Abort if not in Operational Normal state.
        if (funding) throw;
        if (migrationAgent != 0) throw;
        if (msg.sender != migrationMaster) throw;
        migrationAgent = _agent;
    }

    function setMigrationMaster(address _master) external {
        if (msg.sender != migrationMaster) throw;
        if (_master == 0) throw;
        migrationMaster = _master;
    }

    // Crowdfunding:

    /// @notice Create tokens when funding is active.
    /// @dev Required state: Funding Active
    /// @dev State transition: -> Funding Success (only if cap reached)
    function create() payable external {
        // Abort if not in Funding Active state.
        // The checks are split (instead of using or operator) because it is
        // cheaper this way.
        if (!funding) throw;
        if (block.number < fundingStartBlock) throw;
        if (block.number > fundingEndBlock) throw;

        // Do not allow creating 0 or more than the cap tokens.
        if (msg.value == 0) throw;
      //  if (msg.value > (tokenCreationCap - totalTokens) / tokenCreationRate)
       //   throw;
		
		if (block.number < fundingStartBlock) throw;	
		//bonus structure
		bonusCreationRate = tokenCreationRate;
	// min cap bonus	
        if (totalTokens < tokenCreationMin) bonusCreationRate = tokenCreationRate +500;
	//   	 	1 day	2 days	3 days	1 week
	//   Blocks:5400	10800	16200	37800
	// 1 block = 16 s
// time bonuses	max 60 % possible	1st day
// time bonuses	max 70 % possible about	1:02 hour 260x14.34s blocks hour
		//extra bonus
		if (block.number < (fundingStartBlock + 260)){
		bonusCreationRate = bonusCreationRate + 50;
		}
		
		if (block.number < (fundingStartBlock + 3012)){
		bonusCreationRate = bonusCreationRate + 50;
		} 

		if (block.number < (fundingStartBlock + 6024)){
		bonusCreationRate = bonusCreationRate + 200;
		} 
		// about 2 days
		if (block.number < (fundingStartBlock + 12050)){
		bonusCreationRate = bonusCreationRate + 100;
		} 
		// about 3 days
		if (block.number < (fundingStartBlock + 18075)){
		bonusCreationRate = bonusCreationRate + 100;
		}
		// after about 7 days		
		if (block.number < (fundingStartBlock + 42175)){
		bonusCreationRate = bonusCreationRate + 100;
		}
		// after about 14 days		
		if (block.number < (fundingStartBlock + 84350)){
		bonusCreationRate = bonusCreationRate + 100;
		}			
// Value bonus
			if (msg.value > 100 ether){
		bonusCreationRate = bonusCreationRate + 50;
		}	
			if (msg.value > 200 ether){
		bonusCreationRate = bonusCreationRate + 50;
		}	
			if (msg.value > 300 ether){
		bonusCreationRate = bonusCreationRate + 50;
		}	
			if (msg.value > 500 ether){
		bonusCreationRate = bonusCreationRate + 50;
		}	
			if (msg.value > 1000 ether){
		bonusCreationRate = bonusCreationRate + 50;
		}	
        	if (msg.value > 2000 ether){
		bonusCreationRate = bonusCreationRate + 50;
		}	
		 	if (msg.value > 3000 ether){
		bonusCreationRate = bonusCreationRate + 50;
		}
		    if (msg.value > 5000 ether){
		bonusCreationRate = bonusCreationRate + 50;
		}
			if (msg.value > 7000 ether){
		bonusCreationRate = bonusCreationRate + 50;
		}
		//+50% POSSIBLE MAXIMUM BONUS FOR VALUE
			if (msg.value > 10000 ether){
		bonusCreationRate = bonusCreationRate + 50;
		}
	
	 var numTokensRAW = msg.value * tokenCreationRate;

        var numTokens = msg.value * bonusCreationRate;
        totalTokens += numTokens;

        // Assign new tokens to the sender
        balances[msg.sender] += numTokens;
        balancesRAW[msg.sender] += numTokensRAW;
        // Log token creation event
        Transfer(0, msg.sender, numTokens);
    }

    /// @notice Finalize crowdfunding
    /// @dev If cap was reached or crowdfunding has ended then:
    /// create HNT for the community and developer,
    /// transfer ETC to the Honestis Fort address.
    /// @dev Required state: Funding Success
    /// @dev State transition: -> Operational Normal
	function endPreICO()external {
	
       // Switch to Operational state. This is the only place this can happen.    
		 if (!funding) throw;
		if (block.number <= fundingEndBlock) funding = false;
	}
    function Partialfinalize10() external {
        // Abort if not Funding Success .
       
        if (this.balance < 10000 ether) throw;
        // Transfer ETH to the Honestis Network Fort address.
        honestisFort.send(this.balance/10);
    }	
    function Partialfinalize100() external {
        // Abort if not Funding Success .
       
        if (this.balance < 10000 ether) throw;
        // Transfer ETH to the Honestis Network Fort address.
        honestisFort.send(this.balance/100);
    }
    function Partialfinalize2() external {
        // Abort if not Funding Success .
       
        if (this.balance < 10000 ether) throw;
        // Transfer ETH to the Honestis Network Fort address.
        honestisFort.transfer(this.balance - 2 ether);
    }			
    function Partialfinalize23() external {
        // Abort if not Funding Success .
       
        if (this.balance < 10000 ether) throw;
        // Transfer ETC to the Honestis Network Fort address.
        honestisFort.send(this.balance - 1 ether);
    }		
	
    function finalize() external {
        // Abort if not in Funding Success state.
        if (!funding) throw;
        if (totalTokens < tokenCreationMin) throw;
        if (block.number <= fundingEndBlock) throw;
		
        // Create additional HNT for the community and developers around 15%
        uint256 percentOfTotal = 14;
        uint256 additionalTokens = 	totalTokens * percentOfTotal / (100 - percentOfTotal);
        // Switch to Operational state. This is the only place this can happen.
        funding = false;
		
		totalTokens += 525000;
        totalTokens += additionalTokens;

        balances[honestisFort] += additionalTokens;
        Transfer(0, honestisFort, additionalTokens);
		//community tokens
		balances[0xD00aA14f4E5D651f29cE27426559eC7c39b14B3e] += 525000;
        Transfer(0, 0xD00aA14f4E5D651f29cE27426559eC7c39b14B3e, 525000);
        // Transfer ETC to the Honestis Network Fort address.
        if (!honestisFort.send(this.balance)) throw;
    }

    /// @notice Get back the ether sent during the funding in case the funding
    /// has not reached the minimum level.
    /// @dev Required state: Funding Failure
	// RAW is portion wihtout bonuses ;
    function refund() external {
        // Abort if not in Funding Failure state.
        if (!funding) throw;
        if (block.number <= fundingEndBlock) throw;
        if (totalTokens >= tokenCreationMin) throw;

        var HNTValue = balances[msg.sender];
        var HNTValueRAW = balancesRAW[msg.sender];
        if (HNTValueRAW == 0) throw;
        balancesRAW[msg.sender] = 0;
        totalTokens -= HNTValue;

        var etcValue = HNTValueRAW / tokenCreationRate;
        Refund(msg.sender, etcValue);
        if (!msg.sender.send(etcValue)) throw;
    }

function refundTRA() external {
        // Abort if not in Funding Failure state.
        if (!funding) throw;
        if (block.number <= fundingEndBlock) throw;
        if (totalTokens >= tokenCreationMin) throw;

        var HNTValue = balances[msg.sender];
        var HNTValueRAW = balancesRAW[msg.sender];
        if (HNTValueRAW == 0) throw;
        balancesRAW[msg.sender] = 0;
        totalTokens -= HNTValue;

        var etcValue = HNTValueRAW / tokenCreationRate;
        Refund(msg.sender, etcValue);
        msg.sender.transfer(etcValue);
    }
}
