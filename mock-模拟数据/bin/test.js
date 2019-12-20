/**
 * Created by liux on 2017/9/3.
 */
var mysql = require('mysql');
var log = console.log;
var connection = mysql.createConnection({
  host:'localhost',
  userAgent:'root',
  password:'',
  database:'test',
  multipleStatements: true
})

console.log(connection.state)
 connection.connect(function () {
   log(connection.state,arguments)
 });

var arr = [{name:'a'},{name:'b'},{name:'c'}]

arr.forEach(function (item) {
  // connection.query('INSERT INTO user SET ?',item,function (err,result) {
  //   log(err, result)
  // })
})
// connection.query('delete from user where ?',{id:6},function () {
//   log(arguments)
// })

// connection.query('insert into user set ')
var user = {name:'liux',email:"lxcuso4",pwd:'123456'};
var id = {id: 4}
connection.query('update user set ? where ?',[user,id],function (err,result) {
  log(result)
})

connection.query('select name,email from user where id >= 4',function (err,result) {
 // log(result,typeof result,result.length)
})

var userId = 1;
var columns = ['name', 'email'];
var query = connection.query('SELECT ?? FROM ?? WHERE id = ?', [columns, 'user', userId], function(err, results) {
  log(results)
});
console.log(query.sql); // 打印 sql 语句

var sql = "SELECT * FROM ?? WHERE ?? = ?";
var inserts = ['user', 'id', 12];
sql = mysql.format(sql, inserts);
log(sql)

//流式查询
var query = connection.query('SELECT * FROM user');
query.on('error', function(err) {
    log(err)
    // 处理错误，这之后会触发 'end' 事件
  })
  .on('fields', function(fields) {
    // 字段信息
    log(fields)
  })
  .on('result', function(row) {
    // 暂停连接。如果你的处理过程涉及到 I/O 操作，这会很有用。
    connection.pause();
    setTimeout(function () {
      log(row)
      connection.resume();
    },100)
  })
  .on('end', function() {
    log(arguments)
    // 所有数据行都已经接收完毕
  });

connection.query('SELECT * from user where id = 1; SELECT * from user where id =2', function(err, results) {
  if (err) throw err;
  // `results` is an array with one element for every statement in the query:
  console.log(results[0]); // [{1: 1}]
  console.log(results[1]); // [{2: 2}]
});