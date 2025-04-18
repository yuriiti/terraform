module.exports = {
  testEnvironment: 'node',
  preset: 'ts-jest',
  //   setupFilesAfterEnv: ['./jest.setup.js'],
  testMatch: ['**/tests/**/*.test.ts'],
  transform: {
    '^.+\\.ts$': 'ts-jest',
  },
};
