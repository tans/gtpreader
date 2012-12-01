require 'fs'

class GTPInputStream
  constructor:(@stream)->

  init:()->
    @streamPosition=0

  getVersion:()->
    return @version 

  getVersionIndex:()->
    return @versionIndex

  isSupportVersion:()->
    return false #todo

  readVersion:()->
    len = @readByte()
    console.log len
    @version = @readStringByte(len)
    @streamPosition = 30
    return @version

  read:(len)->
    len = 1 if not len
    ret = @stream.slice(@streamPosition,@streamPosition+len).toString()
    @streamPosition +=len
    return ret

  skip:(len)->
    @streamPosition+=len

  readUnsignedByte:()->
    return (@read() & 0xff) is 0x01

  readByte:()->
    @streamPosition++
    return @stream[@streamPosition-1]

  readBoolean:()->
    @.readByte == 1

  readInt:()->
    ret = @stream[@streamPosition+3]<<24 | @stream[@streamPosition+2]<<16 |@stream[@streamPosition+1]<<8 |@stream[@streamPosition]
    @streamPosition+=3
    return ret

  readString:(size,len)->
    if Object.prototype.toString.call(len) isnt '[object Number]'
      return @readString(size,size)
    @read(if size>0 then size else len)

  readStringInteger:()->
    @readString(@readInt())

  readStringByte:(size)->
    @readString(size,@readUnsignedByte)

  readStringByteSizeOfByte:()->
    @readStringByte(@readUnsignedByte()-1)

  readStringByteSizeOfInteger:()->
    @readStringByte(@readInt()-1)

exports.GTPInputStream = GTPInputStream
