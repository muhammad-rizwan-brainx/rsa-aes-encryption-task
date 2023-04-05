require('@nomiclabs/hardhat-waffle');
require('@nomiclabs/hardhat-etherscan');


module.exports = {

  'etherscan': {
    'apiKey': 'VTJJ86VD6ZKVE3WQBMRE1CGP7HUM4Z8KRC', // Testnet Binance
  },
  'mocha': {
    'timeout': 20000,
  },
  'networks': {
    'hardhat': {},
    'bsc': {
      'accounts': ['af1b890709e530e57d040e1bec8358ffaf112007521219670c4fc971e996bb0c'],
      'url': 'https://data-seed-prebsc-1-s1.binance.org:8545',
    },
  },
  'paths': {
    'sources': './contracts',
    'artifacts': './artifacts',
    'cache': './cache',
    'tests': './test',
  },
  'solidity': {
    'version': '0.8.4',
    'settings': {
      'optimizer': {
        'enabled': true,
        'runs': 200,
      },
    },
  },
  'watcher': {
    'ci': {
      'tasks': [
        'clean',
        {'command': 'compile',
          'params': {'quiet': true}},
        {
          'command': 'test',
          'params': {'noCompile': true,
            'testFiles': ['testfile.ts']},
        },
      ],
    },
    'compilation': {
      'tasks': ['compile'],
      'files': ['./contracts'],
      'verbose': true,
    },
  },
};