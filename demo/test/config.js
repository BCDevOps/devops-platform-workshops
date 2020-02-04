const config = {
  "name":"cvarjao",
  "namespace":{
    "tools": "ocp101a-tools",
    "dev": "ocp101a-dev"
  }
}
Object.assign(config, {"rocketchat":{"imageStream":`rocketchat-${config.name}`}})
module.exports = config