# Shamir Secret Sharing impl notes

A node deploys a smart contract. 
In storage: 
- public keys of other parties
- encrypted shares received from other parties (encrypted with shared key)

Methods:
- addNode: add the public key of another node to the list of participants
- sendShares: a secret and share are sent privately to the smart contract from the PXE. The smart contract verifies the shares are correct wrt secret and sends the shares enrcrypted under shares keys to the other participants. 
Alternatively: privately a secret is sent to the smart contract and there the shares and generated and distributed
- receiveShare: another node posts a share that is encrypted under a shared key (add to storage). Do verification of share. When enough shares have been received, this triggers calculate_res
- calculate_res: decrypt all shares and add them together. This is it for now. 

## Step 1
Use unencrypted shares, but with a mapping of pubkeys.

- addNode
- sendShares: privately a secret is sent to the smart contract, shares are calculated and distributed
- receiveShare: called by another node to add a share to this collection. When enough shares have been received, reconstruction starts.
- calculate_res: add shares together