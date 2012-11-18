fs = require 'fs'
buffer =new Buffer 100
# fs.open 'kisstherain.gp4' ,'r',(err,fd)->
#	console.log(err) if err
#	fs.fstat fd,(err,fstats)->
#		console.log(err) if err
#		size = fstats.size
		
#		read = (i)->
#			fs.read fd,buffer,0,100,i,(err, bytesRead, buffer)->
#				console.log err
#				console.log bytesRead
#				console.log buffer.toString()

#		read(i) for i in [0..size] by 100 

#		fs.read fd,buffer,


			
stream = fs.createReadStream('kisstherain.gp5');

buffer_array = []
stream.on 'data', (data)->
	buffer_array.push data

stream.on 'end', (data)->
	file_b = Buffer.concat(buffer_array)
	size1= file_b.readUInt8 0
	console.log size1
 
	name = file_b.toString 'utf8',1,size1

	size2 = file_b.readUInt8 35
	console.log size2

	console.log name 
	name = file_b.toString 'utf8',36,50
 
	console.log name
	
	size2 = file_b.readUInt8 51
	console.log size2

	size2 = file_b.readUInt8 52
	console.log size2

	size2 = file_b.readUInt8 53
	console.log size2

	name = file_b.toString 'utf8',54,58
 
	console.log name

	size2 = file_b.readUInt8 59
	console.log size2

	size2 = file_b.readUInt8 60
	console.log 

	size2 = file_b.readUInt8 51
	console.log size2

	size2 = file_b.readUInt8 62
	console.log size2
	name = file_b.toString 'utf8',63,105
 
	console.log name



