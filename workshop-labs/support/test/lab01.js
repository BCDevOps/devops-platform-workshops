const { spawn, spawnSync } = require('child_process');
const path = require('path');
const assert = require('assert');
const config = Object.assign({},require('./properties.json'), require('./properties.local.json'));


describe('Lab 01', function() {
  describe('Permissions', function() {
    it('Can I create RoleBinding', function(done) {
      const ps = spawn('oc', [`--namespace=${config.namespaces.tools}`,'auth','can-i','create','RoleBinding']);
      ps.on('close', function(code) {
        assert.equal(code, 0)
        done()
      })
    });
    it('Can I create BuildConfig', function(done) {
      const ps = spawn('oc', [`--namespace=${config.namespaces.tools}`, 'auth','can-i','create','BuildConfig']);
      ps.on('close', function(code) {
        assert.equal(code, 0)
        done()
      })
    });
  });

  describe('Rocket.Chat - Build', function() {
    ["ImageStream/nodejs-8-rhel7", `ImageStream/rocketchat-${config.username}`, `BuildConfig/rocketchat-${config.username}`].forEach((resource) => {
      it(`${resource} created in namespace/${config.namespaces.tools}`, function(done) {
        const ps = spawn('oc', [`--namespace=${config.namespaces.tools}`, 'get',`${resource}`, '--output=name']);
        ps.on('close', function(code) {
          assert.equal(code == 0, true)
          done()
        })
      });
    });

    it(`BuildConfig/rocketchat-${config.username}`, function(done) {
      const ps1 = spawnSync(
        'oc',
        [`--namespace=${config.namespaces.tools}`, 'process',`--filename=${path.join(path.join(__dirname, "resources"), 'BuildConfig.yaml')}`, '--output=json', `--param=USERNAME=${config.username}`, `--param=TRIGGER_SECRET=auto_generated`],
        {'encoding': 'utf-8'}
      );
      const template = JSON.parse(ps1.stdout);
      const ps = spawnSync('oc',
        [`--namespace=${config.namespaces.tools}`, 'get',`BuildConfig/rocketchat-${config.username}`, '--output=json', '--export=true'],
        {'encoding': 'utf-8'}
      );
      const resource = JSON.parse(ps.stdout);
      delete resource.metadata.selfLink;
      resource.status = {"lastVersion": 0}
      resource.spec.triggers.forEach(trigger => {
        if (trigger.github) trigger.github.secret = 'auto_generated'
        if (trigger.generic) trigger.generic.secret = 'auto_generated'
      })
      assert.deepEqual(resource, template.items[0]);
      done()
    });

    //check that a build has been successful and an image was created
    [`ImageStreamTag/rocketchat-${config.username}:latest`].forEach((resource) => {
      it(`${resource} created in namespace/${config.namespaces.tools}`, function(done) {
        const ps = spawn('oc', [`--namespace=${config.namespaces.tools}`, 'get',`${resource}`, '--output=name']);
        ps.on('close', function(code) {
          assert.equal(code == 0, true)
          done()
        })
      });
    });
  })
});
