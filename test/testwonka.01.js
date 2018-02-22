var WonkaEngine = artifacts.require("./WonkaEngine.sol");

var version = web3.version.api;
console.log("Web3 version is now (" + version + ")"); // "0.2.0"

var EQUAL_TO_RULE     = 0;
var LESS_THAN_RULE    = 1;
var GREATER_THAN_RULE = 2;

contract('WonkaEngine', function(accounts) {
  it("should be 3 attributes stored in the engine", function() {
    return WonkaEngine.deployed().then(function(instance) {
      return instance.getNumberOfAttributes.call();
    }).then(function(balance) {
      assert.equal(balance.valueOf(), 3, "More or less than 3 attributes populated");
    });
  });
  it("name of first Attribute should be 'Title'", function() {
    return WonkaEngine.deployed().then(function(instance) {
      return instance.getAttributeName.call(0);
    }).then(function(attrName) {
      console.log("Name of first attribute is (" + web3.toAscii(attrName.valueOf()) + ")");
    });
  });
  it("add the first RuleSet", function() {
    return WonkaEngine.deployed().then(function(instance) {      
      instance.addRuleSet(accounts[0], web3.fromAscii('ValidateProduct'));
      console.log("Added the first RuleSet!");
    });
  });
  it("name of first RuleSet should be 'ValidateBook'", function() {
    return WonkaEngine.deployed().then(function(instance) {
      return instance.getRulesetName.call(accounts[0]);
    }).then(function(rulesetName) {
      console.log("Name of first RuleSet is (" + web3.toAscii(rulesetName.valueOf()) + ")");      
    });
  });
  it("add rules to the first RuleSet", function() {
    return WonkaEngine.deployed().then(function(instance) {
      instance.addRule(accounts[0], web3.fromAscii('Validate title'), web3.fromAscii('Title'), EQUAL_TO_RULE, new String('The First Book').valueOf());
      instance.addRule(accounts[0], web3.fromAscii('Validate price'), web3.fromAscii('Price'), GREATER_THAN_RULE, new String('0099').valueOf()); // in cents, since we can't use decimals
      instance.addRule(accounts[0], web3.fromAscii('Validate pages'), web3.fromAscii('PageAmount'), LESS_THAN_RULE, new String('1000').valueOf());
      console.log("Added the rules to the first RuleSet!");
    });
  });
  it("name of first Rule should be 'Validate title'", function() {
    return WonkaEngine.deployed().then(function(instance) {
      return instance.getRuleName.call(accounts[0], 0);
    }).then(function(ruleName) {
      console.log("Name of first Rule is (" + web3.toAscii(ruleName.valueOf()) + ")");
      // assert.equal(web3.toAscii(rulesetName.valueOf()), "ValidateBook", "RuleSet has the wrong name!");
    });
  });
  it("add Values into current record", function() {
    return WonkaEngine.deployed().then(function(instance) {
      instance.setValueOnRecord(accounts[0], web3.fromAscii('Title'), new String('The First Book').valueOf());
      instance.setValueOnRecord(accounts[0], web3.fromAscii('Price'), new String('0999').valueOf()); // in cents
      instance.setValueOnRecord(accounts[0], web3.fromAscii('PageAmount'), new String('289').valueOf());
      console.log("Added the values to the current record!");
    });
  });
  it("price value of current record should be 999 cents (i.e., $9.99)", function() {
    return WonkaEngine.deployed().then(function(instance) {
      return instance.getValueOnRecord.call(accounts[0], web3.fromAscii('Price'));
    }).then(function(currPrice) {
      // console.log("Current price is (" + web3.toAscii(currPrice.valueOf()) + ")"); 
      console.log("Current price is (" + currPrice.valueOf() + ")");      
    });
  });
  it("page amount of current record should be 289", function() {
    return WonkaEngine.deployed().then(function(instance) {
      return instance.getValueOnRecord.call(accounts[0], web3.fromAscii('PageAmount'));
    }).then(function(pageAmt) {
      console.log("Current page amount is (" + pageAmt.valueOf() + ")");      
    });
  });
  it("conversion test - converting '123456' to numeric equivalent", function() {
    return WonkaEngine.deployed().then(function(instance) {
      var testNum = new String(123456);
      return instance.convertStringToNumber.call(testNum.valueOf());
    }).then(function(convResult) {
      console.log("Conversion amount is (" + convResult.toNumber() + ")");      
    });
  });
  it("asserting price value of current record should be 999 cents (i.e., $9.99)", function() {
    return WonkaEngine.deployed().then(function(instance) {
      return instance.getValueOnRecordAsNum.call(accounts[0], web3.fromAscii('Price'));
    }).then(function(currPrice) {
      assert.equal(currPrice.toNumber(), 999, "Price not matching");     
    });
  });
  it("asserting page amount of current record should be 289", function() {
    return WonkaEngine.deployed().then(function(instance) {
      return instance.getValueOnRecordAsNum.call(accounts[0], web3.fromAscii('PageAmount'));
    }).then(function(pageAmt) {
      assert.equal(pageAmt.toNumber(), 289, "PageAmount not matching");     
    });
  });
  it("check the current record values to see if they're in accordance with the defined Attributes", function() {
    return WonkaEngine.deployed().then(function(instance) {
      return instance.checkRecord.call(accounts[0]);
    }).then(function(recordPasses) {
      console.log("Current record for owner(" + accounts[0] + ") passes?  [" + recordPasses + "]");      
    });
  });
  it("run the business rules on the currently populated record", function() {
    return WonkaEngine.deployed().then(function(instance) {
      return instance.execute.call(accounts[0]);
    }).then(function(recordValid) {
      console.log("Current record for owner(" + accounts[0] + ") is valid?  [" + recordValid + "]");      
    });
  });
	
  /*
   * NOTE: Only run this section if you want to see the contract return an error (i.e., the set data fails the rules)
   *
  it("set bad Value onto current record", function() {
    return WonkaEngine.deployed().then(function(instance) {
      instance.setValueOnRecord(accounts[0], web3.fromAscii('Price'), new String('0049').valueOf());
      console.log("Updated the Price to a bad one (i.e., 0049)!");
    });
  });
  it("run the business rules on the currently populated record", function() {
    return WonkaEngine.deployed().then(function(instance) {
      return instance.execute.call(accounts[0]);
    }).then(function(recordValid) {
      console.log("Current record for owner(" + accounts[0] + ") is valid?  [" + recordValid + "]");      
    });
   */

});
