const { composePlugins, withNx } = require('@nx/webpack');
const ZipPlugin = require('zip-webpack-plugin');

// Nx plugins for webpack.
module.exports = composePlugins(withNx(), (config) => {
  // Note: This was added by an Nx migration. Webpack builds are required to have a corresponding Webpack config file.
  // See: https://nx.dev/recipes/webpack/webpack-config-setup
  config.devtool = 'source-map';
  config.output.filename = 'main.js';

  config.plugins.push(
    new ZipPlugin({
      filename: 's3-lambda.zip',
      path: '../../lambdas',
      pathPrefix: '',
      include: [/\.js$/, /\.json$/],
    })
  );

  return config;
});
