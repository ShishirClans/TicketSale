const path = require('path');
const fs = require('fs');
const solc = require('solc');

// Path to the Solidity file
const contractPath = path.resolve(__dirname, 'contracts', 'TicketSale.sol');
const source = fs.readFileSync(contractPath, 'utf8');

// Compile the contract
const input = {
    language: 'Solidity',
    sources: {
        'TicketSale.sol': {
            content: source,
        },
    },
    settings: {
        outputSelection: {
            '*': {
                '*': ['abi', 'evm.bytecode.object'],
            },
        },
    },
};

const output = JSON.parse(solc.compile(JSON.stringify(input)));

// Check for errors
if (output.errors) {
    output.errors.forEach((err) => {
        console.error(err.formattedMessage);
    });
}

// Extract ABI and bytecode
const abi = output.contracts['TicketSale.sol'].TicketSale.abi;
const bytecode = output.contracts['TicketSale.sol'].TicketSale.evm.bytecode.object;

// Write ABI and bytecode to separate files
fs.writeFileSync('TicketSale_ABI.txt', JSON.stringify(abi));
fs.writeFileSync('TicketSale_Bytecode.txt', bytecode);

console.log('ABI and Bytecode generated successfully');
