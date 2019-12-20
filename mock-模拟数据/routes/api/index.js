/**
 * Created by liux on 2018/4/15.
 */
const express = require('express');
const router = express.Router();

const io = require('./io')

router.post('/add',add,err);
router.post('/rm',rm,err);
router.post('/update',update,err);
router.post('/query',query,err);



function add(req, res, next) {
  var {url,json,store,opt} = test('add',...arguments)
  io.add(url,json,store,opt).then((json)=>{
    res.json(Object.assign({code:0,msg:'ok'},json))
  },err=>{
    res.locals.err = err
    next()
  })
}
function rm(req, res, next) {
  var {url,store} = test('rm',...arguments);
  io.rm(url,store).then(()=>{
    res.json({code:0,msg:'ok'})
  },err=>{
    res.locals.err = err
    next()
  })
}

function update(req, res, next) {
  var {url,json,store,newUrl} = test('update',...arguments)
  io.update(url,json,store,newUrl).then((json)=>{
    res.json(Object.assign({code:0,msg:'ok'},json))
  },err=>{
    res.locals.err = err
    next()
  })
}
function query(req, res, next) {
  var {store,page}=test('query',...arguments);
  io.query(store,page).then(data=>{
    var json = {code:0,msg:'ok'};
    json = Object.assign(json, data)
    if(data.data.length === 0){
      Object.assign(json,{code:-1,msg:`当前页无数据`})
    }
    res.json(json)
  },err=>{
    res.locals.err = err
    next()
  })
}

function test(type,req,res,next) {
  var rule = {
    url(value) {
      return /^\/[^\s]+$/g.test(value)
    },
    newUrl(value){
      return !value || /^\/[^\s]+$/g.test(value)
    },
    store(value){
      return !value || /^[^\/\s]+$/g.test(value)
    },
    json(value){
      return value && typeof value === 'object'
    },
    page(value){
      return !value || /^\d+$/g.test(value)
    },
    opt(value){
      return !value.weight || /^\d+$/g.test(value.weight)
    },
  }
  var re = {
    store: req.body.store,
    url: req.body.url
  }
  switch (type){
    case 'add':
      re.json = req.body.data;
      if(req.body.weight){
        re.opt = {weight: req.body.weight};
      }
      break;
    case 'update':
      re.json = req.body.data;
      re.newUrl = req.body.newUrl||re.url;
      break;
    case 'query':
      re.page = req.body.page;
      delete re.url;
      break;
  }
  for(let key in re){
    if(!rule[key](re[key])){
      res.json({code:-1,msg:'参数格式错误'})
      return next()
    }
  }
  return re;
}

function err(req, res) {
    var msg = JSON.stringify(res.locals.err);
    res.json({code:-9,msg: msg || '文件操作错误',data:{}})
}
module.exports = router;