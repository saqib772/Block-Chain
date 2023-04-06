module.exports = {
  // React only allows importing the built smart contract code (abis) from the src directory
  contracts_build_directory: path.join(__dirname, 'src/abis'),
  networks: {
    development: {
      host: '127.0.0.1', // localhost
      port: 7545, // default port for ganache dev server
      network_id: '*', // matches any network id
    },
  },
  compilers: {
    solc: {
      version: '0.8.1', // solidity version
    },
  },
};