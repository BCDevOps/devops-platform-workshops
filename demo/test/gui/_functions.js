const {By, Key, until } = require('selenium-webdriver')
const {spawn} = require('child_process')
const path = require('path')
const fs =require('fs');


const defaultWaitTimeout = Number.MAX_SAFE_INTEGER
const defaultDelayBeforeClickInMilliseconds = 2000
const defaultDelayBeforeSnapshot = 2000
const defaultDelayAfterClickInMilliseconds = 100
const defaultLongWaitForElement = Number.MAX_SAFE_INTEGER

module.exports = (driver)=>{
  function filterOverviewByName(name){
    return driver.wait(until.elementLocated(By.css("div.name-filter.ng-scope > form > div > div > input")), defaultWaitTimeout)
    .then(pointAndType(name))
  }

  async function say(sentence){
    await new Promise((resolve, reject)=>{
      const proc = spawn('echo', ['-v', 'Samantha', '--rate=20', sentence]);
      proc.on("exit", (code)=>{
        if (code != 0){
          return reject(new Error(`'say' failed with exit code ${code}`))
        }
        resolve(code)
      })
    })
  }

  async function delay(delayInMilliseconds){
    return new Promise((resolve)=>{
      setTimeout(()=>{resolve(true)}, delayInMilliseconds)
    })
  }

  async function clearPointer(element){
    return driver.executeScript("let pointer=document.getElementById('cursor-pointer'); if (pointer) {pointer.setAttribute('class', 'myHiddenSeleniumCursorMarker');}").then(()=>{return element})
  }
  async function pointHereToo(element){
    let hrTime = process.hrtime();
    let timestamp = hrTime[0] * 1000000 + parseInt(hrTime[1] / 1000);
    return Promise.resolve(element).then((element)=>{
      return driver.executeScript(`let pointer=document.createElement('div'); pointer.setAttribute('id', 'cursor-pointer-${timestamp}'); pointer.setAttribute('class', 'cursor-pointer'); document.body.appendChild(pointer)`, element).then(()=>{return element})
    })
    .then((element)=>{
      return driver.executeScript("let pointerStyles=document.getElementById('cursor-pointer-styles'); if (!pointerStyles){pointerStyles=document.createElement('style'); pointerStyles.setAttribute('id', 'cursor-pointer-styles'); pointerStyles.setAttribute('type', 'text/css'); pointerStyles.innerHTML='.myHiddenSeleniumCursorMarker { visibility: hidden; } .myVisibleSeleniumCursorMarker { pointer-events: none; animation: blink-animation 1s steps(5, start) infinite; }  @keyframes blink-animation { to { opacity: 0; } }'; document.body.appendChild(pointerStyles)}", element).then(()=>{return element})
    })
    .then((element)=>{
      return driver.executeScript(`let pointer=document.getElementById('cursor-pointer-${timestamp}'); pointer.classList.add('myVisibleSeleniumCursorMarker'); pointer.setAttribute('style', 'background-color: red; position: absolute; z-index: 5000; width: '+$(arguments[0]).width()+'px; height: '+$(arguments[0]).innerHeight()+'px; top: '+$(arguments[0]).offset().top+'px; left: '+$(arguments[0]).offset().left+'px; opacity: 0.3; /*border-radius: 50%;*/ pointer-events: none;')`, element).then(()=>{return element})
    })
  }

  async function pointAndWait(element){
    return pointHere(element)
    .then(()=>{return delay(defaultDelayBeforeClickInMilliseconds)})
    .then(()=>{return delay(defaultDelayAfterClickInMilliseconds)})
  }

  async function takeScreenshot(element){
    return driver.takeScreenshot()
    .then((base64EncodedPNG)=>{
      return new Promise((resolve, reject)=>{
        const hrTime = process.hrtime()
        const microseconds=hrTime[0] * 1000000 + hrTime[1] / 1000;
        const snapshotsDir = path.resolve(__dirname, './snapshots')
        const snapshotFile = path.resolve(snapshotsDir, `snapshot-${microseconds}.png`)
        fs.existsSync(snapshotsDir) || fs.mkdirSync(snapshotsDir)
        fs.writeFile(snapshotFile, base64EncodedPNG, 'base64', function(err) {
          if(err) {
            reject(err)
            return;
          }
          resolve(snapshotFile)
        });
      })
    })
    .then(()=>{return element;})
  }
  async function pointHere(element){
    return Promise.resolve(element)
    .then((element)=>{
      return driver.executeScript("let pointer=document.getElementById('cursor-pointer'); if (!pointer){pointer=document.createElement('div'); pointer.setAttribute('id', 'cursor-pointer'); document.body.appendChild(pointer)}", element).then(()=>{return element})
    })
    .then((element)=>{
      return driver.executeScript("let pointerStyles=document.getElementById('cursor-pointer-styles'); if (!pointerStyles){pointerStyles=document.createElement('style'); pointerStyles.setAttribute('id', 'cursor-pointer-styles'); pointerStyles.setAttribute('type', 'text/css'); pointerStyles.innerHTML='.myHiddenSeleniumCursorMarker { visibility: hidden; } .myVisibleSeleniumCursorMarker { pointer-events: none; animation: blink-animation 1s steps(5, start) infinite; }  @keyframes blink-animation { to { opacity: 0; } }'; document.body.appendChild(pointerStyles)}", element).then(()=>{return element})
    })
    .then((element)=>{
      return driver.executeScript("let pointer=document.getElementById('cursor-pointer'); pointer.setAttribute('class', ''); pointer.setAttribute('style', 'background-color: red; position: absolute; z-index: 5000; width: '+$(arguments[0]).width()+'px; height: '+$(arguments[0]).innerHeight()+'px; top: '+$(arguments[0]).offset().top+'px; left: '+$(arguments[0]).offset().left+'px; opacity: 0.3; /*border-radius: 50%;*/ pointer-events: none;')", element)
      .then(()=>{
        return driver.wait(until.elementLocated(By.id("cursor-pointer")), defaultWaitTimeout)
      })
    })
    .then((element)=>{return delay(defaultDelayBeforeSnapshot).then(()=>{return element})})
    .then(takeScreenshot)
    .then(()=>{
      return driver.executeScript("let pointer=document.getElementById('cursor-pointer'); pointer.setAttribute('class', 'myVisibleSeleniumCursorMarker'); pointer.setAttribute('style', 'background-color: red; position: absolute; z-index: 5000; width: '+$(arguments[0]).width()+'px; height: '+$(arguments[0]).innerHeight()+'px; top: '+$(arguments[0]).offset().top+'px; left: '+$(arguments[0]).offset().left+'px; opacity: 0.3; /*border-radius: 50%;*/ pointer-events: none;')", element)
    }).then(()=>{
      return element;
    })
  }

  function scrollIntoView(element){
    return Promise.resolve(element)
    .then((element)=>{return driver.executeScript("arguments[0].scrollIntoView()", element).then(()=>{return element})})
  }

  function pointAndClick(element){
    return Promise.resolve(element)
    .then((element)=>{
      return pointHere(element)
    })
    .then((element)=>{return delay(defaultDelayBeforeClickInMilliseconds).then(()=>{return element})})
    .then((element)=>{
      return clearPointer(element)
    })
    .then((element)=>{
      return element.click()
    })
    .then(()=>{return delay(defaultDelayAfterClickInMilliseconds)})
  }

  function pointAndType(text){
    return function(element){
      return Promise.resolve(element).then((element)=>{
        return pointHere(element)
      })
      .then((element)=>{return delay(defaultDelayBeforeClickInMilliseconds).then(()=>{return element})})
      .then((element)=>{ return element.sendKeys('').then(()=>{return element})})
      .then((element)=>{return element.clear().then(()=>{return element})})
      .then((element)=>{
        return element.sendKeys(text).then(()=>{return element})
      })
      .then(takeScreenshot)
      .then((element)=>{
        return clearPointer(element).then(()=>{return element})
      })
      .then((element)=>{return delay(defaultDelayBeforeClickInMilliseconds).then(()=>{return element})})
    }
  }

  function pointAndSelect(value){
    return function(element){
      return Promise.resolve(element)
      .then((element)=>{
        return pointHere(element)
      })
      .then((element)=>{return delay(defaultDelayBeforeClickInMilliseconds).then(()=>{return element})})
      .then((element)=>{
        return element.click()
      })
      .then((element)=>{
        return clearPointer(element)
      })
      .then(()=>{
        return driver.wait(until.elementLocated(By.css("body > div.ui-select-container.ui-select-bootstrap.dropdown.open > ul")), defaultWaitTimeout)
        .then((dropdown)=>{
          return driver.findElement(By.css(".open > .form-control")).sendKeys(value)
          .then(takeScreenshot)
          .then(()=>{
            return driver.findElement(By.css(".ui-select-highlight")).click()
          })
          .then(()=>{
            return driver.wait(until.elementIsNotVisible(dropdown), defaultWaitTimeout)
          })
        })
      })
    }
  }

  return {filterOverviewByName, say, delay, clearPointer, pointHere, pointHereToo, pointAndWait, pointAndSelect, pointAndType, pointAndClick}
}