const { spawn, spawnSync } = require('child_process');
const path = require('path');
const assert = require('assert');
const config = Object.assign({},require('./properties.json'), require('./properties.local.json'));


describe('Lab 02', function() {
  describe('Rocket.Chat - Tagging', function() {
    //check that a build has been successful and an image was created
    [`ImageStreamTag/rocketchat-${config.username}:dev`].forEach((resource) => {
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
