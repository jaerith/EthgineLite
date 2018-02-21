pragma solidity ^0.4.4;

/// @title A library for doing simple conversions
/// @author Aaron Kendall
/// @notice You should use this contract as a linked library
/// @dev All function calls are currently implemented without side effects
library ConvertLib{

    /// @author Aaron Kendall
    /// @notice This is just a test method
    /// @dev Should be used really just for testing if the library has been linked to
    /// @param amount The principal
    /// @param conversionRate The conversion rate
    /// @return The converted amount
	function convert(uint amount,uint conversionRate) public pure returns (uint convertedAmount) {
	
		return amount * conversionRate;
	}

    /// @author Aaron Kendall
    /// @notice This is just a test method
    /// @dev Should be used really just for testing if the library has been linked to
    /// @param amount The principal
    /// @param conversionRate The conversion rate
    /// @return The converted amount
    function bytesToString(byte[] bytesString) public pure returns (string) {

        uint charCount = bytesString.length;

        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }

        return string(bytesStringTrimmed);
    }

    /// @author Aaron Kendall
    /// @notice This is just a test method
    /// @dev Should be used really just for testing if the library has been linked to
    /// @param amount The principal
    /// @param conversionRate The conversion rate
    /// @return The converted amount
    function bytes32ToString(bytes32 x) public pure returns (string) {

        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }

        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }

        return string(bytesStringTrimmed);
    }

    /// @author Aaron Kendall
    /// @notice This is just a test method
    /// @dev Should be used really just for testing if the library has been linked to
    /// @param amount The principal
    /// @param conversionRate The conversion rate
    /// @return The converted amount
    function parseInt(string _a, uint _b) internal pure returns (uint) {

        bytes memory bresult = bytes(_a);
        uint mint = 0;
        bool decimals = false;

        for (uint i = 0; i < bresult.length; i++) {
            if ((bresult[i] >= 48) && (bresult[i] <= 57)) {
                if (decimals) {
                    if (_b == 0) 
                        break;
                    else 
                        _b--;
                }
                mint *= 10;
                mint += uint(bresult[i]) - 48;
            } else if (bresult[i] == 46) 
                decimals = true;
        }

        return mint;
    }

    /// @author Aaron Kendall
    /// @notice This is just a test method
    /// @dev Should be used really just for testing if the library has been linked to
    /// @param amount The principal
    /// @param conversionRate The conversion rate
    /// @return The converted amount
    function uintToString(uint v) public pure returns (string str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory s = new bytes(i + 1);
        for (uint j = 0; j <= i; j++) {
            s[j] = reversed[i - j];
        }
        str = string(s);
    }
}