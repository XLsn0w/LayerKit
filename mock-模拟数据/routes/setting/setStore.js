/**
 * @功能名称:
 * @文件名称: setStore.js
 * @Date: 2018/6/18 下午7:15.
 * @Author: liux
 * @Copyright（C）: 2014-2018 X-Financial Inc.   All rights reserved.
 */

const Fs = require('aw-fs');
const path = require('path');
var fs = new Fs([{name: 'access', module: 2}]);

const {listen, close} = require('../../service');
const {dbPath, test, getDbConfig, writeDbConfig, copyDir,rmdir} = require('../config');
const store = getDbConfig().store;

const log = console.log.bind(console)



module.exports = {
  async addStore (store,forkStore){
    var service = getDbConfig().service;
    if (test(store)) {
      return {code: -1, msg: `${store}已存在`};
    }
    if(forkStore && !test(forkStore)){
        return {code: -1, msg: `${forkStore}不存在`};
    }
    service.push({store: store});
    await writeDbConfig({service: service});
    var storePath = path.join(dbPath, store);
    await fs.mkdir(storePath);
    if (forkStore) {
      var sourcePath = path.join(dbPath,forkStore)
      await copyDir(sourcePath, storePath);
    }
    return {data:service}
  },
  async listenStore(store, port, opt={}){
    var re = await listen(store, port, opt);
    if(re.code == 0){
      var service = getDbConfig().service;
      service.forEach(item=>{
        if(item.store == store){
          item.port = port;
          item.state = true;
          item.opt = opt;
        }
      })
      await writeDbConfig({service:service})
      return {data:service}
    }else {
      return re
    }
  },
  async closeStore(port){
    var re = await close(port);
    if(re.code == 0){
      var service = getDbConfig().service;
      service.forEach(item=>{
        if(item.port == port){
          item.state = false
        }
      })
      await writeDbConfig({service:service})
      return {data: service}
    }else {
      return re
    }
  },
  async queryStore(){
    var service = getDbConfig().service;
    return {data: service};
  },
  async rmStore(store){
    var service = getDbConfig().service;
    if (test(store)) {
      service = service.filter(item => {
        return item.store != store;
      });
      await writeDbConfig({service: service});
      var storePath = path.join(dbPath, store);
      await rmdir(storePath);
      return {data:service}
    } else {
      return {code: -1, msg: `store:${store}不存在`};
    }
  },
  async reStore(store, newStore){
    var service = getDbConfig().service;
    var t1 = test(store)
    var t2 = service.every(item => {
      return item.store != newStore;
    });
    if (!t1) {
      return {code: -1, msg: `store:${store}不存在`};
    }
    if (!t2) {
      return {code: -1, msg: `newStore:${newStore}已存在`};
    }
    service = service.map(item => {
      if (item.store == store) {
        item.store = newStore;
      }
      return item;
    });
    await writeDbConfig({service: service});
    var storePath = path.join(dbPath, store);
    var newStorePath = path.join(dbPath, newStore);
    await fs.rename(storePath, newStorePath);
    return {data:service}
  },
};
