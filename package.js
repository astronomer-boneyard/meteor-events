Package.describe({
  name: 'usercycle:events',
  summary: 'Usercycle Events',
  version: '0.0.2'
});

Package.onUse(function(api) {
  api.versionsFrom('1.0.1');

  api.use([
    'coffeescript',
    'underscore',
    'tracker',
    'iron:router@1.0.0',
    'meteorhacks:inject-initial@1.0.2'
    ], ['client', 'server']);

  api.addFiles([
    'injectHead.coffee'
  ], 'server')

  api.addFiles([
    'usercycle.coffee',
  ], 'client');

});
