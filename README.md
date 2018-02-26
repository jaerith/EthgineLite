# EthgineLite

A proof-of-concept business rules engine for the Ethereum platform that is inherently metadata-driven, written into the form of a smart contract using the Solidity language.  Basically, after providing a number of rules and populating a record, a user can submit the populated record for validation by the rules engine.

# Requirements

* Basic knowledge of Ethereum and some experience with Javascript
* An installation of <a target="_blank" href="http://truffleframework.com/docs/">Truffle</a> and a local blockchain (like <a target="_blank" href="http://truffleframework.com/ganache/">Ganache</a>)
* A fair amount of patience and forgiveness

# The Basics

## Quick Runthrough

After installing the Truffle framework and configuring/starting your local blockchain, change directory to the EthgineLite repo and compile the contracts:

```
$ truffle compile
```

Then deploy them to your local blockchain

```
$ truffle migrate
```

And finally test the engine using the provided Javascript file:

```
$ truffle test
```

## Brief Overview of How to Use the Engine

1.) First, you need to define the data point(s) that we will want to test with the rules engine (like a Price, for example). 

```
        // INSIDE THE CONTRACT'S CONSTRUCTOR
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
```

...
    // INSIDE THE TEST SCRIPT
    instance.addAttribute(web3.fromAscii('Language'), 64, 0, new String('ENG').valueOf(), true, false);
...

For now, the engine automatically creates three Attributes in the engine's constructor, but that could be changed easily.

2.) Next, you need to create a RuleSet for containing the rules:

```
    instance.addRuleSet(accounts[0], web3.fromAscii('ValidateProduct'));
```

As well as create the Rule itself:

```
    instance.addRule(accounts[0], web3.fromAscii('Validate price'), web3.fromAscii('Price'), GREATER_THAN_RULE, new String('0099').valueOf()); // in cents, since we can't use decimals
```

3.) Then, we need to populate our record (held within the contract instance for us) with the data:

```
    instance.setValueOnRecord(accounts[0], web3.fromAscii('Title'), new String('The First Book').valueOf());
    instance.setValueOnRecord(accounts[0], web3.fromAscii('Price'), new String('0999').valueOf()); // in cents
    instance.setValueOnRecord(accounts[0], web3.fromAscii('PageAmount'), new String('289').valueOf());
```

4.) Finally, we execute the rules engine, using our provided RuleSet and applying it to our specified data record:

```
    instance.execute.call(accounts[0]);
```

And we learn whether or not the data record is valid, according to our provided rules.

# Notices

Currently, this project is under construction.  However, you can understand its basis by reading about the 
ideas and the general design presented in my <a target="_blank" href="https://www.infoq.com/articles/mdd-creating-user-friendly-dsl">InfoQ article</a> that talks about metadata-driven design (i.e., MDD) and business rules.
