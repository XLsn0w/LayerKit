/**
 * @功能名称:
 * @文件名称: index.js.js
 * @Date: 2018/6/18 下午7:15.
 * @Author: liux
 * @Copyright（C）: 2014-2018 X-Financial Inc.   All rights reserved.
 */

const express = require('express');
const router = express.Router();
const set = require('./setStore')
const log = console.log.bind(console)
router.post('/addStore',addStore,err)
router.post('/queryStore',queryStore,err)
router.post('/reStore',reStore,err);
router.post('/rmStore',rmStore,err);
router.post('/listenStore',listenStore,err);
router.post('/closeStore',closeStore,err);

function addStore(req,res,next) {
  var {store,forkStore} = test(1,...arguments);
  set.addStore(store,forkStore).then(json=>{
    res.json(Object.assign({code:0,msg:'ok'},json))
  },err=>{
    res.locals.err = err
    next()
  })
}
function queryStore(req, res, next) {
  set.queryStore().then(json=>{
    res.json(Object.assign({code:0,msg:'ok'},json))
  },err=>{
    res.locals.err = err
    next()
  })
}

function rmStore(req, res, next) {
  var {store}=test(1,...arguments)
  set.rmStore(store).then(json=>{
    res.json(Object.assign({code:0,msg:'ok'},json))
  },err=>{
    res.locals.err = err
    next()
  })
}
function reStore(req, res,next) {
  var {store,newStore}=test(1,...arguments);
  if(!(store||newStore)){
    res.json({code:-3,msg:'参数错误'})
  }
  set.reStore(store,newStore).then(json=>{
    res.json(Object.assign({code:0,msg:'ok'},json))
  },err=>{
    res.locals.err = err
    next()
  })
}

function listenStore(req,res,next) {
  var {store,port,opt} = test(2,...arguments);
  set.listenStore(store,port,opt).then(json=>{
    res.json(Object.assign({code:0,msg:'ok'},json))
  },err=>{
    res.locals.err = err
    next()
  })
}
function closeStore(req,res,next) {
  var {port} = test(2,...arguments);
  set.closeStore(port).then(json=>{
    res.json(Object.assign({code:0,msg:'ok'},json))
  },err=>{
    res.locals.err = err
    next()
  })
}

function test(type,req,res,next) {
  var rule = {
    store(value){
      var reg = true;
      if(type == 1){
        reg = value != 'default'
      }
      return this.newStore(value) && reg
    },
    forkStore(value){
      return !value || /^\w+$/g.test(value)
    },
    newStore(value){
      return value && /^\w+$/g.test(value)
    },
    port(value){
      return (value>=8080 && value<=9000)
    },
  }
  var re = req.body;
  for(let key in re){
    if(re.hasOwnProperty(key) && rule[key]){
      if(!rule[key](re[key])){
        res.json({code:-3,msg:'参数错误'})
        return next()
      }
    }
  }
  return re;
}

function err(req, res) {
  var msg = JSON.stringify(res.locals.err);
  res.json({code:-8,msg:  '文件操作错误',data:{}})
}
module.exports = router;