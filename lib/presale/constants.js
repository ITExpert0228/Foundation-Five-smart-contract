/* Useful aliases */

// No, we don't have easy access to web3 here.
// And bn.js new BN() weirdly doesn't work with truffle-assertions
const toBN = a => a;
const toBNHex = a => a;


// Configfuration for our tokens

const NUM_ACCESSORIES = 5;
const INITIAL_SUPPLY = toBNHex('0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF');

const ID_M_NAIL = 1;
const ID_M_WOOD = 2;
const ID_M_PAINT = 3;
const ID_M_GLASS = 4;
const ID_M_METAL = 5;

const M_MINT_INIT_SUPPLY_LIST = new Map([
  [ID_M_NAIL,  toBN(225000)], 
  [ID_M_WOOD,  toBN(130000)],
  [ID_M_PAINT, toBN(75000)],
  [ID_M_GLASS, toBN(40000)],
  [ID_M_METAL, toBN(60000)]
]);
const M_MINT_INITIAL_SUPPLY = 
M_MINT_INIT_SUPPLY_LIST.get(ID_M_NAIL) + 
M_MINT_INIT_SUPPLY_LIST.get(ID_M_WOOD) + 
M_MINT_INIT_SUPPLY_LIST.get(ID_M_PAINT) +
M_MINT_INIT_SUPPLY_LIST.get(ID_M_GLASS) +
M_MINT_INIT_SUPPLY_LIST.get(ID_M_METAL);

module.exports = {
  ID_M_NAIL,
  ID_M_WOOD,
  ID_M_PAINT,
  ID_M_GLASS,
  ID_M_METAL,
  NUM_ACCESSORIES,
  INITIAL_SUPPLY,
  M_MINT_INIT_SUPPLY_LIST,
  M_MINT_INITIAL_SUPPLY,

};
