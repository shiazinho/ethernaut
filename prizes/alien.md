```shell
shiazinho@shiazinho:~/ethernaut$ forge script --rpc-url $RPC_URL --account teste3 script/Alien.s.sol --tc Deployer --broadcast
[⠊] Compiling...
No files changed, compilation skipped
Enter keystore password:
Script ran successfully.

## Setting up 1 EVM.

==========================

Chain 11155111

Estimated gas price: 0.001225009 gwei

Estimated total gas used for script: 487734

Estimated amount required: 0.000000597478539606 ETH

==========================

##### sepolia
✅  [Success] Hash: 0x92d80171cfdb9b46ac5331bfa3fb0d8e6e6a7da46d2ea36276b73f4084611181
Contract Address: 0xbB9285743bF02A67548938AE9C804a0D45AEb7E8
Block: 9545316
Paid: 0.00000045959587518 ETH (375180 gas * 0.001225001 gwei)

✅ Sequence #1 on sepolia | Total Paid: 0.00000045959587518 ETH (375180 gas * avg 0.001225001 gwei)
                                                                                                                                                                                              

==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.

Transactions saved to: /home/shiazinho/ethernaut/broadcast/Alien.s.sol/11155111/run-latest.json

Sensitive values saved to: /home/shiazinho/ethernaut/cache/Alien.s.sol/11155111/run-latest.json

shiazinho@shiazinho:~/ethernaut$ cast call --rpc-url $RPC_URL 0xbB9285743bF02A67548938AE9C804a0D45AEb7E8 "exploit()"
0x
shiazinho@shiazinho:~/ethernaut$ cast send --account teste3 --rpc-url $RPC_URL 0xbB9285743bF02A67548938AE9C804a0D45AEb7E8 "exploit()"
Enter keystore password:

blockHash            0x87dda4fa4091b3f15677fda0596e1249f46a4863b46688f903fb6feebf03dff0
blockNumber          9545321
contractAddress      
cumulativeGasUsed    9939861
effectiveGasPrice    625505
from                 0xEA81F42cc64c33541de9b5aE9eD176346aF7DA52
gasUsed              55156
logs                 []
logsBloom            0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
root                 
status               1 (success)
transactionHash      0x990a39b22d24a81e6715f3520e195978552253d6f35ee14b6f76c8030df34157
transactionIndex     89
type                 2
blobGasPrice         
blobGasUsed          
to                   0xbB9285743bF02A67548938AE9C804a0D45AEb7E8
```