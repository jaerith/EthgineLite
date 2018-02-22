# EthgineLite

A proof-of-concept business rules engine for the Ethereum platform that is inherently metadata-driven.  Basically, after providing a number of rules and populating a record, a user can submit the populated record for validation by the rules engine.

# Requirements

* Basic knowledge of Ethereum and some experience with Javascript
* An installation of <a target="_blank" href="http://truffleframework.com/docs/">Truffle</a> and a local blockchain (like <a target="_blank" href="http://truffleframework.com/ganache/">Ganache</a>)
* A fair amount of patience and forgiveness

# The Basics

## Quick Runthrough

After installing the Truffle framework and configuring starting your local blockchain, change directory to the EthgineLite repo and compile the contracts:

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

# Notices

Currently, this project is under construction.  However, you can understand its basis by reading about the 
ideas and the general design presented in my <a target="_blank" href="http://www.infoq.com/articles/metadata-and-agile">InfoQ article</a>.

