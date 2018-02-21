pragma solidity ^0.4.18;

import "./ConvertLib.sol";

/// @title A library that houses the data structures used by the engine
/// @author Aaron Kendall
/// @notice Not all data structures have been used yet
/// @dev There are probably more efficient layout for these structures
library WonkaLib {

	/// @title A data structure that holds metadata which represents an Attribute (i.e., a unique point of data in a user's record)
	/// @author Aaron Kendall
	/// @notice Not all struct members are currently used
    struct WonkaAttr {
 
        uint attrId;

        bytes32 attrName;

        uint maxLength;

        bool maxLengthTruncate;

        uint maxNumValue;

        string defaultValue;

        bool isString;

        bool isDecimal;
        
        bool isNumeric;

        bool isValue;
    }

	/// @title A data structure that represents a Source (i.e., a provide of a record)
	/// @author Aaron Kendall
	/// @notice This structure isn't currently used
    struct WonkaSource {

        int sourceId;

        bytes32 sourceName;

        bytes32 status;
    }

	/// @title A data structure that represents a rule (i.e., a logical unit for testing the validity of a collection of Attribute values [or what we call a record])
	/// @author Aaron Kendall
	/// @notice Only one Attribute can be targeted now, but in the future, rules should be able to target multiple Attributes
	/// @dev 
    struct WonkaRule {

        uint ruleId;

        bytes32 name;

        uint ruleType;

        WonkaAttr targetAttr;

        string ruleValue;
    }
    
	/// @title A data structure that represents a set of rules
	/// @author Aaron Kendall
	/// @notice 
	/// @dev The actual rules are kept outside the struct since I'm currently unsure about the costs to keeping it inside
    struct WonkaRuleSet {

        bytes32     ruleSetId;
        // WonkaRule[] ruleSetCollection;
        bool        isValue;
    }

}

/// @title A simple business rules engine that will test the validity of a provided data record against a set of caller-defined rules
/// @author Aaron Kendall
/// @notice Some Attributes are currently hard-coded in the constructor, by default.  Also, a record can only be tested by a ruler (i.e., owner of a RuleSet).
/// @dev The efficiency (i.e., the rate of spent gas) of the contract may not yet be optimal
contract WonkaEngine {

    // using WonkaLib for *;

    uint constant MAX_ARGS = 32;

    enum RuleTypes { IsEqual, IsLessThan, IsGreaterThan, MAX_TYPE }
    RuleTypes constant defaultType = RuleTypes.IsEqual;

    address public rulesMaster;
    uint    public ruleCounter;

    mapping(bytes32 => WonkaLib.WonkaAttr) private attrMap;

    WonkaLib.WonkaAttr[] public attributes;

    // This declares a state variable that stores a `RuleSet` struct for each possible address.
    mapping(address => WonkaLib.WonkaRuleSet) private rulers;

    // A dynamically-sized array of `RuleSet` structs.
    WonkaLib.WonkaRuleSet[] public rulesets;

    mapping(bytes32 => WonkaLib.WonkaRule[]) private allRules;

    mapping(address => mapping(bytes32 => string)) currentRecords;

	/// @author Aaron Kendall
    /// @notice The engine's constructor
    /// @dev Some Attributes are created by default, but in future versions, Attributes can be created by the contract's user
    function WonkaEngine() public {
        rulesMaster = msg.sender;

        attributes.push(WonkaLib.WonkaAttr({
                attrId: 1,
                attrName: "Title",
                maxLength: 256,
                maxLengthTruncate: true,
                maxNumValue: 0,
                defaultValue: "Blank",
                isString: true,
                isDecimal: false,
                isNumeric: false,
                isValue: true                
            }));

        attrMap[attributes[attributes.length-1].attrName] = attributes[attributes.length-1];

        attributes.push(WonkaLib.WonkaAttr({
                attrId: 2,
                attrName: "Price",
                maxLength: 128,
                maxLengthTruncate: false,
                maxNumValue: 1000000,
                defaultValue: "000",
                isString: false,
                isDecimal: false,
                isNumeric: true,
                isValue: true               
            }));

        attrMap[attributes[attributes.length-1].attrName] = attributes[attributes.length-1];
        
        attributes.push(WonkaLib.WonkaAttr({
                attrId: 3,
                attrName: "PageAmount",
                maxLength: 256,
                maxLengthTruncate: false,
                maxNumValue: 1000,
                defaultValue: "",
                isString: false,
                isDecimal: false,
                isNumeric: true,
                isValue: true              
            }));

        attrMap[attributes[attributes.length-1].attrName] = attributes[attributes.length-1];
    }

	/// @author Aaron Kendall
    /// @notice This function will create a RuleSet, which is the container for a set of Rules created/owned by a user.  Only the RuleMaster (i.e., the contract instance's creator) can create a RuleSet for a user.
    /// @dev Users are currently allowed only one RuleSet.
    /// @param ruler The owner (i.e., the user's address) of the new RuleSet 
    /// @param ruleSetName The name given to the new RuleSet
    /// @return 
    function addRuleSet(address ruler, bytes32 ruleSetName) public {

        require(msg.sender == rulesMaster);

        rulesets.push(WonkaLib.WonkaRuleSet({
                ruleSetId: ruleSetName,
                // ruleSetCollection: new WonkaLib.WonkaRule[](0),
                isValue: true                
            }));

        rulers[ruler] = rulesets[rulesets.length-1];
    }

	/// @author Aaron Kendall
    /// @notice This function will add a Rule to the RuleSet owned by 'ruler'.  Only 'ruler' or the RuleMaster can add a rule.
    /// @dev The type of rules are limited to the enum RuleTypes
    /// @param ruler The owner (i.e., the user's address) of the RuleSet to which we are adding a rule
    /// @param ruleName The name given to the new Rule
    /// @param attrName The record Attribute that the rule is testing
    /// @param rType The type of operation for the rule
    /// @param rVal The value against which the rule is pitting the Attribute of the record [like Attribute("Price").Value > 500]
    /// @return 	
    function addRule(address ruler, bytes32 ruleName, bytes32 attrName, uint rType, string rVal) public {

        require((msg.sender == ruler) || (msg.sender == rulesMaster));

        require(rulers[ruler].isValue);

        require(attrMap[attrName].isValue);

        require(rType < uint(RuleTypes.MAX_TYPE));

        // WonkaLib.WonkaRuleSet memory foundRuleset = rulers[ruler];
        // WonkaLib.WonkaAttr memory foundAttr = attrMap[attrName];
        // uint memory tmpRuleId = ruleCounter++;

        allRules[rulers[ruler].ruleSetId].push(WonkaLib.WonkaRule({
                                                        ruleId: ruleCounter++,
                                                        name: ruleName,
                                                        ruleType: rType,
                                                        targetAttr: attrMap[attrName],
                                                        ruleValue: rVal               
                                                    }));
    }

	/// @author Aaron Kendall
    /// @notice This function will use the Attribute metadata to do a simple check of the provided value, like ensuring a Price value is actually numeric
    /// @dev Static memory load of more than 32 bytes requested?
    /// @param checkAttr The Attribute metadata used for analysis
    /// @param checkVal The record value being analyzed in accordance with the Attribute
    /// @return bool that indicates whether the 'checkVal' is a valid instance of Attribute	    
    function checkCurrValue(WonkaLib.WonkaAttr checkAttr, string checkVal) private pure returns(bool valuePasses) {

        require(checkAttr.attrName.length != 0);

        bytes memory testValue = bytes(checkVal);
        require(testValue.length != 0);

        if (checkAttr.maxLength > 0) {

            if (checkAttr.maxLengthTruncate) {
                // Do something here
            }

            // if (checkAttr.defaultValue)

            require(testValue.length < checkAttr.maxLength);
        }

        if (checkAttr.isNumeric) {
            uint testNum = 0;
            
            testNum = ConvertLib.parseInt(checkVal, 0);
            require(testNum > 0);

            if (checkAttr.maxNumValue > 0)
                require(testNum < checkAttr.maxNumValue);
        } 

        valuePasses = true;
    }

	/// @author Aaron Kendall
    /// @notice Should be used just for testing by the user
    /// @dev
    /// @param ruler The owner (i.e., the user's address) of the record which we want to test
    /// @param targetRules The rules being invoked against the ruler's record
    /// @return bool that indicates whether the record of 'ruler' is valid according to the Attributes mentioned in 'targetRules'
    function checkRecordBeta(address ruler, WonkaLib.WonkaRule[] targetRules) private view returns(bool recordPasses) {

        require(rulers[ruler].isValue);

        for (uint idx; idx < targetRules.length; idx++) {
            
            WonkaLib.WonkaRule memory tempRule = targetRules[idx];

            string memory tempValue = currentRecords[ruler][tempRule.targetAttr.attrName];

            // require(checkCurrValue(tempRule.targetAttr, tempRule.ruleType, tempValue));
            checkCurrValue(tempRule.targetAttr, tempValue);
        }

        recordPasses = true;
    }

	/// @author Aaron Kendall
    /// @notice This method will test a record's values against the Attribute metadata.  It should only be called once all of the Attribute values are set for the ruler's current record.
    /// @dev Perhaps the variables 'tempRule' and 'tempValue' are a waste of gas?
    /// @param ruler The owner of the record and the RuleSet being invoked
    /// @return bool that indicates whether the record of 'ruler' is valid, according to the metadata of Attributes mentioned in the RuleSet of 'ruler'
    function checkRecord(address ruler) public view returns(bool recordPasses) {

        require(rulers[ruler].isValue);

        WonkaLib.WonkaRule[] memory targetRules = allRules[rulers[ruler].ruleSetId];

        for (uint idx; idx < targetRules.length; idx++) {
            
            WonkaLib.WonkaRule memory tempRule = targetRules[idx];

            string memory tempValue = currentRecords[ruler][tempRule.targetAttr.attrName];

            // require(checkCurrValue(tempRule.targetAttr, tempRule.ruleType, tempValue));
            checkCurrValue(tempRule.targetAttr, tempValue);
        }

        recordPasses = true;
    }

    /// @author Aaron Kendall
    /// @notice Should be used just for testing by the user
    /// @dev This method is just a proxy to call the 'parseInt()' method
    /// @param origVal The 'string' which we want to convert into a 'uint'
    /// @return uint that contains the conversion of the provided string
    function convertStringToNumber(string origVal) public pure returns (uint) {

        uint convertVal = 123;

        convertVal = ConvertLib.parseInt(origVal, 0);

        return convertVal;
    }

	/// @author Aaron Kendall
    /// @notice This method will actually process the current record by invoking the RuleSet.  Before this method is called, all record data should be set and all rules should be added.
    /// @dev The efficiency (i.e., the rate of spent gas) of the method may not yet be optimal
    /// @param ruler The owner of the record and the RuleSet being invoked
    /// @return bool that indicates whether the record of 'ruler' is valid, according to both the Attributes and the RuleSet
    function execute(address ruler) public view returns (bool executeSuccess) {
            
        require(rulers[ruler].isValue);

        executeSuccess = true;

        WonkaLib.WonkaRule[] memory targetRules = allRules[rulers[ruler].ruleSetId];

        // require(attrNames.length == attrValues.length);

		// This call will make sure all the values in the ruler's record are valid instances of Attributes (like Price is actually numeric)
        checkRecordBeta(ruler, targetRules);

        uint testNumValue = 0;
        uint ruleNumValue = 0;

        // Now invoke the rules
        for (uint idx = 0; idx < targetRules.length; idx++) {

            string memory tempValue = (currentRecords[ruler])[targetRules[idx].targetAttr.attrName];

            if (targetRules[idx].targetAttr.isNumeric) {          
                testNumValue = ConvertLib.parseInt(tempValue, 0);
                ruleNumValue = ConvertLib.parseInt(targetRules[idx].ruleValue, 0);
            }

            if (uint(RuleTypes.IsEqual) == targetRules[idx].ruleType) {

                if (targetRules[idx].targetAttr.isNumeric) {
                    require(testNumValue == ruleNumValue);
                } else {
                    require(keccak256(tempValue) == keccak256(targetRules[idx].ruleValue));
                }

            } else if (uint(RuleTypes.IsLessThan) == targetRules[idx].ruleType) {

                if (targetRules[idx].targetAttr.isNumeric)
                    require(testNumValue < ruleNumValue);

            } else if (uint(RuleTypes.IsGreaterThan) == targetRules[idx].ruleType) {

                if (targetRules[idx].targetAttr.isNumeric)
                    require(testNumValue > ruleNumValue);
            }  
        }        
    }

	/// @author Aaron Kendall
    /// @notice Retrieves the name of the attribute at the index
    /// @dev Should be used just for testing
    /// @param idx The index of the Attribute being examined
    /// @return bytes32 that contains the name of the specified Attribute	
    function getAttributeName(uint idx) public view returns(bytes32) {
		return attributes[idx].attrName;
	}

	/// @author Aaron Kendall
    /// @notice Retrieves the value of the record that belongs to the user (i.e., 'ruler')
    /// @dev Should be used just for testing
    /// @param ruler The owner of the record
    /// @param key The name of the Attribute in the record	
    /// @return string that contains the Attribute value from the record that belongs to 'ruler'
    function getValueOnRecord(address ruler, bytes32 key) public view returns(string) { 

        require(rulers[ruler].isValue);

        return (currentRecords[ruler])[key];
    }

	/// @author Aaron Kendall
    /// @notice Retrieves the value of the record that belongs to the user (i.e., 'ruler')
    /// @dev Should be used just for testing
    /// @param ruler The owner of the record
    /// @param key The name of the Attribute in the record	
    /// @return uint that contains the Attribute value from the record that belongs to 'ruler'
    function getValueOnRecordAsNum(address ruler, bytes32 key) public view returns(uint) { 

        uint currValue = 0;

        require(rulers[ruler].isValue);

        currValue = ConvertLib.parseInt((currentRecords[ruler])[key], 0);

        return currValue;
    }

	/// @author Aaron Kendall
    /// @notice Retrieves the number of current Attributes
    /// @dev Should be used just for testing
    /// @param idx The index of the Attribute being examined
    /// @return uint that indicates the num of current Attributes	
	function getNumberOfAttributes() public view returns(uint) {
		return attributes.length;
	}

	/// @author Aaron Kendall
    /// @notice Retrieves the name of the indexed rule in the RuleSet of 'ruler'
    /// @dev Should be used just for testing
    /// @param ruler The owner of the RuleSet
    /// @param idx The index of the Rule being examined
    /// @return bytes32 that contains the name of the indexed Rule	
    function getRuleName(address ruler, uint idx) public view returns(bytes32) {

        require((msg.sender == ruler) || (msg.sender == rulesMaster));

        require(rulers[ruler].isValue);

		return allRules[rulers[ruler].ruleSetId][idx].name;
	}

	/// @author Aaron Kendall
    /// @notice Retrieves the name of the RuleSet of 'ruler'
    /// @dev Should be used just for testing
    /// @param ruler The owner of the RuleSet
    /// @return bytes32 that contains the name of the RuleSet belonging to 'ruler'
    function getRulesetName(address ruler) public view returns(bytes32) {

        require((msg.sender == ruler) || (msg.sender == rulesMaster));

        require(rulers[ruler].isValue);

        return rulers[ruler].ruleSetId;
	}

	/// @author Aaron Kendall
    /// @notice This method populates the record of 'ruler' with a value that represents an instance of an Attribute
    /// @dev This method does not yet check to see if the provided 'key' is the valid name of an Attribute.  Is it worth the gas?
    /// @param ruler The owner of the RuleSet
    /// @param key The name of the Attribute for the value being inserted into the record	
    /// @param value The string to insert into the record
    /// @return	
    function setValueOnRecord(address ruler, bytes32 key, string value) public { 

        require(rulers[ruler].isValue);

        (currentRecords[ruler])[key] = value;
    }
}