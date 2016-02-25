var net         = require('net');
var util = require('util');
var Protobuf  = require('protobufjs');

var sampleBuilder    = Protobuf.loadProtoFile('proto/sample.proto');
var sample           = sampleBuilder.build();

var Person = sample.Person;


var sock = net.Socket();      

var port = 8080;
var host = "127.0.0.1";

sock.connect(port, host, function(){
	console.log("connected to "+port+" "+host);
	setTimeout(function(){
		var msg = new Person({name:"123", id:123, email: "aaa"}).toBuffer();
		var buf = new Buffer(2+4+msg.length);
		buf.writeUInt16LE(10, 0);
		buf.writeUInt32LE(msg.length, 2);
		msg.copy(buf, 6);
		var ret = sock.write(buf);
		console.log(ret);
	}, 1000);
});

sock.on('data', function (data){
    	console.log(">>>>>>>>>>"+' data recv ' + data.length);
		//console.log(data.toString());
    	console.log(util.inspect(data));
		var buf = data;
		var op = buf.readUInt16LE(0)
		console.log(op);
		var length = buf.readUInt32LE(2)
		console.log(length);
		var bufBody = new Buffer(length);
		buf.copy(bufBody, 0, 6, buf.length);
		var ins = Person.decode(bufBody);
		console.log(ins);
});
    
sock.on('close', function (data){
	console.log("close");
});
    
sock.on('error', function (data){
	console.log("error");
});