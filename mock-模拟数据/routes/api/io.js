/**
 * Created by liux on 2018/4/15.
 * @param Object
 * {
 * store: 'default',
 * url: '/h5/commom/get_config'
 * data: {something: xxx}
 * }
 *
 */
const Fs = require('aw-fs');
const path = require('path');
var fs = new Fs([{name: 'access', module: 2}]);

const {getDbConfig,tag,pageCount,dbPath} = require('../config')

const defaultStore = getDbConfig().store;


function getUrlPath(url, store) {
  url = url.trim();
  url = url.replace(/\//g, tag);
  url = url + '.json';
  return path.resolve(dbPath, store, url);
}

module.exports = {
  async updateStoreConfig(type, url, store, opt){
    opt = Object.assign({weight: 0}, opt);
    var configPath = path.join(dbPath, store, 'config.json');
    var config = {data: []};
    var err = await fs.access(configPath);
    if (!err) {
      var jsonData = await fs.readFile(configPath, 'utf8');
      config = JSON.parse(jsonData);
    }
    var data = config.data;
    opt.updateTime = Date.now();
    switch (type) {
      case 'add':
        opt = Object.assign({url: url}, opt);
        data.push(opt);
        break;
      case 'update':
        data = data.map(item => {
          if (item.url === url) {
            Object.assign(item, opt);
          }
          return item;
        });
        break;
      case 'rm':
        data = data.filter(item => {
          if (item.url === url) {
            return false;
          }
          return true;
        });
        break;
      default:
        break;
    }
    config.data = data;
    await fs.writeFile(configPath, JSON.stringify(config, null, 2));
  },
  async add(url, json, store, opt){
    store = store || defaultStore;
    var filePath = getUrlPath(url, store);
    var hasFile = await fs.access(filePath);
    if (!hasFile) {
      return {code: -1, msg: `url:${url}已存在`};
    }
    var storePath = path.resolve(dbPath, store);
    var data = JSON.stringify(json, null, 2);
    var hasDir = await fs.access(storePath);
    if (hasDir) {
      await fs.mkdir(storePath);
    }
    await Promise.all([fs.writeFile(filePath, data), this.updateStoreConfig('add', url, store, opt)])
    return {
      data: {
        url: url,
        store: store,
        data: json
      }
    }
  },
  // 从转发响应添加一个 json
  async addStream(url,readStream,store){
    var filePath = getUrlPath(url, store);
    var writeStream = fs.createWriteStream(filePath)
    readStream.pipe(writeStream);
    readStream.on('end',()=> {
      this.updateStoreConfig('add', url, store)
    })
  },
  async rm(url, store, rmconfig){
    store = store || defaultStore;
    var filePath = getUrlPath(url, store);
    var err = await fs.access(filePath);
    if (!err) {
      if (!rmconfig) {
        this.updateStoreConfig('rm', url, store);
      }
      await fs.unlink(filePath);
    }
  },
  async update(url, json, store, newUrl){
    store = store || defaultStore;
    var filePath = getUrlPath(newUrl, store);
    var data = JSON.stringify(json, null, 2);
    fs.writeFile(filePath, data);
    await this.updateStoreConfig('update', url, store, {url: newUrl});
    if (url !== newUrl) {
      this.rm(url, store, true);
    }
    return {
      data: {
        url: newUrl,
        store: store,
        data: json
      }
    }
  },
  async query(store, page){
    store = store || defaultStore;
    page = page || 0;
    var config = '';
    var configPath = path.join(dbPath, store, 'config.json');
    config = await fs.readFile(configPath, 'utf8');
    config = JSON.parse(config);
    config = config.data.sort((a, b) => {
      return (b.weight + b.updateTime) - (a.weight + a.updateTime);
    });
    var start = pageCount * page;
    var result = config.slice(start, start + pageCount);
    result = await Promise.all(result.map(item => {
      return new Promise(function (reslove, reject) {
        fs.readFile(getUrlPath(item.url, store), 'utf8').then(json => {
          reslove({
            url: item.url,
            data: JSON.parse(json)
          })
        })
      })
    }));
    return {
      page: page,
      totalPage: Math.ceil(config.length/pageCount),
      data: result,
    };
  },
};