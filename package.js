Package.describe({
  name: 'usercycle:events',
  summary: 'Usercycle Events',
  version: '0.0.1'
});

Package.onUse(function(api) {
  api.versionsFrom('1.0.1');

  api.use([
    'coffeescript',
    'underscore',
    'percolatestudio:segment.io@1.1.0_1',
    'iron:router@1.0.0'
    ], ['client', 'server']);

  api.addFiles('usercycle.coffee');

  api.imply('percolatestudio:segment.io');
});
