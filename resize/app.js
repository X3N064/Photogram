var AWS = require('aws-sdk')
  , Sequelize = require('sequelize')
  , im = require('imagemagick')
  , mime = require('mime')
  , s3 = new AWS.S3({ region: 'ap-northeast-1' })
  , sqs = new AWS.SQS({ region: 'ap-northeast-1' });

var s3Bucket = 'photogram-image';
var sqsQueueUrl = 'https://sqs.ap-northeast-1.amazonaws.com/891377001852/PhotogramQueue';
var rdsEndpoint = {
  host: 'photogram.chwwmiousmy2.ap-northeast-1.rds.amazonaws.com',
  port: 3306
};

// MySQL DB Name, Account, Password
var sequelize = new Sequelize('photogram', 'admin', 'Qwer1234**', {
  host: rdsEndpoint.host,
  port: rdsEndpoint.port
});

// MySQL DB Name Table
var Photo = sequelize.define('Photo', {
  filename: { type: Sequelize.STRING, allowNull: false, unique: true }
});

// SQS delete message
function deleteMessage(ReceiptHandle) {
  sqs.deleteMessage({
    QueueUrl: sqsQueueUrl,
    ReceiptHandle: ReceiptHandle
  }, function (err, data) {
    if (err)
      console.log(err, err.stack);
    else
      console.log(data);
  });
}

// SQS recieve message
function receiveMessage() {
  sqs.receiveMessage({
    QueueUrl: sqsQueueUrl,
    MaxNumberOfMessages: 1,
    VisibilityTimeout: 10,
    WaitTimeSeconds: 10
  }, function (err, data) {
    if (!err && data.Messages && data.Messages.length > 0)
      resizeImage(data.Messages[0]);
    else if (err)
      console.log(err, err.stack);
    receiveMessage();
  });
}

// image-resizer
function resizeImage(Message) {
  var filename = Message.Body;
  s3.getObject({
    Bucket: s3Bucket,
    Key: 'original/' + filename
  }, function (err, data) {
    im.resize({
      srcData: data.Body,
      width: 800
    }, function (err, stdout, stderr) {
      s3.putObject({
        Bucket: s3Bucket,
        Key: 'resized/' + filename,
        Body: new Buffer(stdout, 'binary'),
        ACL: 'public-read',
        ContentType: mime.lookup(filename)
      }, function (err, data) {
        console.log('Complete resize ' + filename);
        deleteMessage(Message.ReceiptHandle);
        insertPhoto(filename);
      });
    });
  });
}

receiveMessage();