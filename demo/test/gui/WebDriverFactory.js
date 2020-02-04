const { Builder, Capabilities} = require('selenium-webdriver')
const chrome = require("selenium-webdriver/chrome");
const path = require('path');
const fs = require('fs');

class WebDriverFactory {
  constructor() {
  }
  build() {
    return Promise.resolve().then(() => {
      if (!global.singletonSeleniumWebDriver) {
        var chromeCapabilities = Capabilities.chrome();
        //setting chrome options to start the browser fully maximized
        //var chromeOptions = {
        //  'args': ['test-type', 'start-maximized']
        //};
        const chromeOptions = new chrome.Options()
        chromeOptions.addArguments("test-type");
        chromeOptions.addArguments('--start-maximized')
        chromeOptions.addArguments(`--user-data-dir=${path.resolve(__dirname, '../../.chrome')}`)
        chromeOptions.addArguments('--disable-infobars')
        //fs.mkdirSync(dataDir)
        //chromeCapabilities.set('chromeOptions', chromeOptions);
        return new Builder().forBrowser('chrome').setChromeOptions(chromeOptions).build().then((instance) => {
          //console.log('New Browser!!')
          global.singletonSeleniumWebDriver = instance;
          return global.singletonSeleniumWebDriver
        })

        
      }

      //console.log('Reusing Browser!!')
      return global.singletonSeleniumWebDriver
    })
  }

}

module.exports = WebDriverFactory;