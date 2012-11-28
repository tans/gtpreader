fs = require 'fs'
# _ = require 'underscore'
util = require 'util'


class GtpReader
  constructor: (@buffer) ->
    @position = 0
  readVersion:()->
    @position = 30;
    @buffer.slice(1,@buffer.readInt8(0)).toString()

  readInterger:()->
    ret = ((@buffer[@position+3] & 0xff) << 24) | ((@buffer[@position+2] & 0xff) << 16) | ((@buffer[@position+1] & 0xff) << 8) | (@buffer[@position+0] & 0xff);
    @buffer.readInt8(@buffer.position+3)*1000
    return ret
  readStringByteSizeOfInteger:()->
    console.log 'i'

fileStream = fs.createReadStream('FadeToBlack.gp4');

bufferArray = []

# console.log Buffer.prototype
Buffer.prototype.position=0

Buffer.prototype.readByte

Buffer.prototype.readUnsignedByte =()->
  ret = @.readInt8(@.position)
  @.position++
  console.log ret
  return ret

Buffer.prototype.readInt= (type)->
  type = 1 if not type
  ret = @.readInt8 @.position 
  @.position += type
  console.log ret
  return ret 

Buffer.prototype.readString = (size)->
  if size>0
    ret = @.slice(@.position,@.position+size).toString()
  else
    size = @.readUnsignedByte()
    ret = @.slice(@.position,@.position+size).toString()

  @.position +=size
  return ret

readBufferInt = (buffer,type)->
  type = 1 if type
  buffer.slice 0, type


fileStream.on 'data',(data)->
  bufferArray.push data

fileStream.on 'end',()->

  gtpBuffer = Buffer.concat bufferArray
  gtpReader = new GtpReader(gtpBuffer);
  console.log gtpBuffer[31]

  console.log gtpReader.position
  console.log gtpReader.readVersion()
  console.log gtpReader.position
  # console.log gtpBuffer[0]
  # console.log gtpBuffer.slice(1,24).toString() 
  # console.log gtpBuffer[31]
  # console.log gtpBuffer[32]
  # console.log gtpBuffer[33]
  # console.log gtpBuffer[34]
  # console.log gtpBuffer[35]
  # console.log gtpBuffer.slice(36,49).toString() 
  # console.log gtpBuffer[50]
  # console.log gtpBuffer[51]
  # console.log gtpBuffer[52]
  # console.log gtpBuffer[53]
  # console.log gtpBuffer.slice(54,58).toString()
  # console.log gtpBuffer[59]
  # console.log gtpBuffer[60]
  # console.log gtpBuffer[61]
  # console.log gtpBuffer[62]
  # console.log gtpBuffer[63]
  # console.log gtpBuffer[64]
  # console.log gtpBuffer[65]
  # console.log gtpBuffer[66]
  # console.log gtpBuffer[67]