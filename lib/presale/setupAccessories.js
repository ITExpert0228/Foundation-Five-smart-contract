const init_values = require('./constants.js');

// A function in case we need to change this relationship
const between=(x, min, max)=>{
  return x >= min && x <= max;
}
const f =(id)=>{
  let ff = 0;
  for(let i = 1; i <= id; i++)
  {
    let i_num = init_values.M_MINT_INIT_SUPPLY_LIST.get(i);
    if(i_num)
      ff+= i_num;
  }
  return ff;
}
const tokenIndexToId = a => {
  for(let i = 1; i<= init_values.NUM_ACCESSORIES; i++){
    if(
      between(a, f(i-1) + 1, f(i))
      ) 
      return i;
    }
  return 0;
}
const indexToTokenTypeId = a => a;
// Configure the nfts

const setupAccessory = async (
  accessories,
  owner
) => {
  for (let i = 0; i < init_values.NUM_ACCESSORIES; i++) {
    const id = indexToTokenTypeId(i);
    if(id == 0) continue;
    await accessories.create(owner, id, init_values.M_MINT_INIT_SUPPLY_LIST.get(id), "", "0x0");
  }
};


// Deploy and configure everything

const setupBuildingAccessories = async(accessories, provider, owner) => {
  await setupAccessory(accessories, owner);
  await accessories.setApprovalForAll(provider.address, true, { from: owner });
  await accessories.transferOwnership(provider.address);
};


module.exports = {
  setupAccessory,
  setupBuildingAccessories
};
