const express = require('express');
const router = express.Router();
const bodyParser = require('body-parser');

const api = require('./api/index');
const setting = require('./setting/index');
const home = require('./users');


router.use('/api',[bodyParser.json(),bodyParser.urlencoded({ extended: true }),api]);
router.use('/setting',[bodyParser.json(),bodyParser.urlencoded({ extended: true }),setting]);
router.use(home);


module.exports = router;
