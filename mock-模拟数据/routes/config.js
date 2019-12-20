/**
 * @功能名称: 全局工具函数
 * @文件名称: utils.js
 * @Date: 2018/6/18 下午7:19.
 * @Author: liux
 * @Copyright（C）: 2014-2018 X-Financial Inc.   All rights reserved.
 */
const Fs = require('aw-fs');
const path = require('path');
const rmDir = require('rmdir');

var fs = new Fs([{name: 'access', module: 2}]);

const dbPath = path.resolve(__dirname, '../db');
const dbConfigPath = path.join(dbPath, 'config.json');

function rmdir(path) {
  return new Promise(function(reslove, reject) {
    rmDir(path , function (err, dirs, files) {
      if(err){
        reject(err)
      }else {
        reslove(dirs)
      }
    });
  })
}
function getDbConfig() {
  var hasConfig = fs.existsSync(dbConfigPath);
  if (!hasConfig) {
    var config = {
      store: 'default',
      service: [
        {
          'store': 'default',
          'port': 8084,
          'state': true,
        }],
    };
    return config;
  }
  var config = fs.readFileSync(dbConfigPath, 'utf8');
  return JSON.parse(config);
}
async function  writeDbConfig(conf){
  var defaultConfig = getDbConfig();
  var config = Object.assign(defaultConfig,conf);
  await fs.writeFile(dbConfigPath,JSON.stringify(config,null,2))
}
function test(store) {
  var service = getDbConfig().service;
  return service.some(item => {
    return item.store == store;
  })
}
async function copyDir(sourcePath, targetPath) {
  var re = await fs.access(targetPath);
  if(re){
    await fs.mkdir(targetPath)
  }
  var list = await fs.readdir(sourcePath);
  var arr = list.map(item=>{
    return fs.copyFile(path.join(sourcePath,item), path.join(targetPath,item))
  })
  return  Promise.all(arr);
}
module.exports = {
  dbPath: dbPath,
  dbConfigPath: dbConfigPath,
  tag:'___',
  pageCount:100,
  getDbConfig,
  writeDbConfig,
  test,
  copyDir,
  rmdir
};

// copyDir("/Users/liux/node/express-test/db/a", "/Users/liux/node/express-test/db/bbb").then(json=>{
//   console.log(1,json)
// },err=>{
//   console.log(2,err)
// })