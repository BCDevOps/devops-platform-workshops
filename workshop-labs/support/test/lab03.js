const { spawn, spawnSync } = require('child_process');
const path = require('path');
const assert = require('assert');
const config = Object.assign({},require('./properties.json'), require('./properties.local.json'));


describe('Lab 03', function() {
  describe('Rocket.Chat - Deployment', function() {
    //check that a build has been successful and an image was created
    [`DeploymentConfig/rocketchat-${config.username}`, `Service/rocketchat-${config.username}`, `Route/rocketchat-${config.username}`].forEach((resource) => {
      it(`${resource} created in namespace/${config.namespaces.deploy}`, function(done) {
        const ps = spawn('oc', [`--namespace=${config.namespaces.deploy}`, 'get',`${resource}`, '--output=name']);
        ps.on('close', function(code) {
          assert.equal(code == 0, true)
          done()
        })
      });
    });
  });

  describe('Permissions', function() {
    it(`Can "system:serviceaccount:${config.namespaces.deploy}:default" pull images from ${config.namespaces.tools}`, function(done) {
      const ps1 = spawnSync('oc', [`--namespace=${config.namespaces.tools}`,'policy','who-can','get','imagestreams/layers', '--output=json'], {'encoding': 'utf-8'});
      const permissions = JSON.parse(ps1.stdout);
      assert.equal(permissions.users.includes(`system:serviceaccount:${config.namespaces.deploy}:default`), true)
      done()
    });
  });

  describe('MongoDB - Deployment', function() {
    //check that a build has been successful and an image was created
    [`DeploymentConfig/mongodb-${config.username}`, `Service/mongodb-${config.username}`, , `Secret/mongodb-${config.username}`].forEach((resource) => {
      it(`${resource} created in namespace/${config.namespaces.deploy}`, function(done) {
        const ps = spawn('oc', [`--namespace=${config.namespaces.deploy}`, 'get',`${resource}`, '--output=name']);
        ps.on('close', function(code) {
          assert.equal(code == 0, true)
          done()
        })
      });
    });
  });

  // Check RocketChat MONGO_URL environment variable
  // mongodb://dbuser:dbpass@mongodb-dereks:27017/rocketchat
  describe('Rocket.Chat - DeploymentConfig', function() {
    const ps1 = spawnSync('oc', [`--namespace=${config.namespaces.deploy}`,'get',`DeploymentConfig/rocketchat-${config.username}`, '--output=json'], {'encoding': 'utf-8'});
    const dc = JSON.parse(ps1.stdout);
    const ps2 = spawnSync('oc', [`--namespace=${config.namespaces.deploy}`,'get',`Secret/mongodb-${config.username}`, '--output=json'], {'encoding': 'utf-8'});
    const secret = JSON.parse(ps2.stdout);

    it(`Environment Variable: MONGO_URL`, function(done) {
      const mongo_db_user = Buffer.from(secret.data["database-user"], 'base64');
      const mongo_db_pass = Buffer.from(secret.data["database-password"], 'base64');
      const mongo_db_name = Buffer.from(secret.data["database-name"], 'base64');
      const MONGO_URL = dc.spec.template.spec.containers[0].env.find(item => item.name == 'MONGO_URL')
      assert.equal((MONGO_URL || {}).value, `mongodb://${mongo_db_user}:${mongo_db_pass}@mongodb-${config.username}:27017/${mongo_db_name}`)
    });
  });
  // Check RocketChat Route is pointing to the right service
  // Check RocketChat deployment strategy is set to Rolling
  // Check MongoDB deployment strategy is set to Recretate
});
