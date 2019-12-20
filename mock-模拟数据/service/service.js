/**
 * Created by liux on 2018/4/11.
 */

const http = require('http');
const url = require('url');
const fs = require('fs');
const path = require('path');
const io = require('../routes/api/io')

const db = path.resolve(__dirname,'../db');

var serverList = {};

async function listen(store, port, opt={}) {
  if(serverList[port]){
    return Promise.resolve({code:-1,msg:`${port} 已被占用`})
  }
  var ROOT = path.join(db, store);
  var server = http.createServer(app);
  return new Promise(function(resolve, reject) {
    server.on('error', (e) => {
      resolve({code: -1, msg: e.toString()});
    })
    server.on('listening', (e) => {
      resolve({code: 0, msg: '已开启'});
    });
    serverList[port] = server.listen(port);
  });
  function app(req, res) {
    var pathname = url.parse(req.url).pathname;
    var filePath = pathname.replace(/\//g, '___');
    filePath = filePath.replace(/(.json)?$/, '.json');
    filePath = path.join(ROOT, filePath);
    fs.readFile(filePath, 'utf8', function(err, file) {
      if (err) {
        if(opt.host){
           proxy(req,res,store,opt)
        }else {
          res.writeHead(404);
          res.end('not found');
        }
        return
      }
      res.writeHead(200, {
        'Content-Type': 'application/json; charset=UTF-8',
        'Access-Control-Allow-Origin': '*',
        'Transfer-Encoding': 'chunked',
      });
      res.write(file, 'utf8');
      res.end();
    });
  }
}

function proxy(req,res,store,{host,port=80,cache=true}){
  var proxyReq = http.request({
    host: host,
    port: port,
    path: req.url,
    method:   req.method,
    headers: req.headers,
    timeout: 10000
  }, function(proxyRes){
    proxyRes.pipe(res);
    if(cache && proxyRes.statusCode == 200){
      io.addStream(req.url,proxyRes,store)
    }
  });
  proxyReq.on('error', (e) => {
    res.writeHead(500);
    res.end(`proxy:${e.toString()}`);
  });
  if (/POST|PUT/i.test(req.method)) {
    req.pipe(proxyReq);
  } else {
    proxyReq.end()
  }

}

async function close(port) {
  if (!serverList[port]) {
    return Promise.resolve({code: -1, msg: `${port} 端口未启用`})
  }
  return new Promise(function(resolve, reject) {
    serverList[port].on('error', (e) => {
      resolve({code: -1, msg: e.toString()});
    });
    serverList[port].close(function() {
      delete serverList[port]
      resolve({code: 0, msg: ` ${port} 已关闭`});
    });
  });

}
module.exports = {listen, close};