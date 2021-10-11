
#issue 1:
Source "@openzeppelin/contracts/..." not found: File import callback not supported
#solution 1:
https://github.com/juanfranblanco/vscode-solidity#openzeppelin
- Go to solidity extension (Ethereum Solidity Language for Vistual Studio Code)
- Go to Workspace tab on the setting page.
- Make sure that packageDefaultDependenciesDirectory points to correct path for package defult dependencies directory
If the solidity project is in solution of the workspace.
  "solidity.packageDefaultDependenciesContractsDirectory": "",
  "solidity.packageDefaultDependenciesDirectory": "<solidity_project>/node_modules"

#2 For Opensea ERC1155 project

npm install --save-dev opensea-js //require node 8.11
npm install --save-dev multi-token-standard //ok on current node version 16
(or yarn add multi-token-standard)
npm install --save-dev @0x/subproviders //ok
npm install --save-dev eth-gas-reporter //installation failed
