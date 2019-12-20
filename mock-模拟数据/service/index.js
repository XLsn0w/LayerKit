/**
 * @功能名称:
 * @文件名称: index.js
 * @Date: 2018/6/18 下午5:10.
 * @Author: liux
 * @Copyright（C）: 2014-2018 X-Financial Inc.   All rights reserved.
 */



const {listen, close} = require('./service');
const {getDbConfig} = require('../routes/config')

function init() {
  var service = getDbConfig().service;
  if (service && Array.isArray(service)) {
    service.forEach(item => {
      if (item.store && item.port && item.state) {
        listen(item.store, item.port, item.opt);
      }
    });
  }
}

init()

module.exports = {init, listen, close}

