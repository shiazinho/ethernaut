60 08 80 60 09 3d 39 3d f3 // CONTRACT CREATION

BYTECODE	MNEMONIC	STACK			ACTION
60 2a		PUSH1 0x2a	[0x2a]			
5f		PUSH0		[0x00, 0x2a] 
52		MSTORE		[]			Store 0x2a in the first 32 bytes of memory 
60 20		PUSH1 0x20 	[0x20]
5f		PUSH0		[0x00, 0x20]
f3		RETURN 		[]			Return the first 32 bytes of memory

