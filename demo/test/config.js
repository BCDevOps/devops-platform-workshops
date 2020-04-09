const config = {
  "name":"cvarjao",
  "namespace":{
    "prefix":"ocp101b",
    "tools": "ocp101b-tools",
    "dev": "ocp101b-dev"
  }
}
Object.assign(config, {"rocketchat":{"imageStream":`rocketchat-${config.name}`}})
module.exports = config