const express = require('express');
const bodyParser = require('body-parser');
const MongoClient = require('mongodb').MongoClient;
const app = express();

app.use(function(req, res, next) {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
  res.header('Cache-Control','no-cache');
  next();
});

app.use(bodyParser.urlencoded({
  extended: true
}));
app.use(bodyParser.json());

// Creds hard-coded for Demo only!
const mongoURL = "mongodb://root:password@mongo:27017";
const mongoClientOptions = { useNewUrlParser: true, useUnifiedTopology: true };
const dbName = "contacts-db";

app.get('/', function (req, res) {
  let response = [];
  
  MongoClient.connect(mongoURL, mongoClientOptions, function (err, client) {
    if (err) {
        console.log(err);
        throw err;
    }

    let db = client.db(dbName);
    db.collection("contacts").find({}).toArray(function (err, result) {
      if (err) {
        console.log(err);
        throw err;
      }

      response = result;
      client.close();

      res.send(response ? response : []);
    });
  });
});

app.listen(3000, function () {
  console.log("app listening on port 3000!");
});