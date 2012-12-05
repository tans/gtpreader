require 'fs'

class GTPInputStream
  constructor:(@stream)->

  init:()->
    @position=0

  getVersion:()->
    return @version 

  getVersionIndex:()->
    return @versionIndex

  isSupportVersion:()->
    return false #todo

  addPos:(num)->
    @position+=parseInt(num)

  readVersion:()->
    @version = @readStringByte(30)
    return @version

  read:(len)->
    len = 1 if not len
    ret = @stream.slice(@position,@position+len).toString()
    @addPos len
    return ret

  skip:(len)->
    @addPos len

  readUnsignedByte:()->
    return (@read() & 0xff) is 0x01

  readByte:()->
    @position++
    return @stream[@position-1]

  readBoolean:()->
    @.readByte == 1

  readInt:()->
    ret = @stream[@position+3]<<24 | @stream[@position+2]<<16 |@stream[@position+1]<<8 |@stream[@position]
    @addPos 4
    return ret

  readString:(size,len)->
    if Object.prototype.toString.call(len) isnt '[object Number]'
      return @readString(size,size)
    if size is 0
      return ''
    @read(if size>0 then size else len)

  readStringInteger:()->
    @readString(@readInt())

  readStringByte:(size)->
    @readString(size,@readUnsignedByte())

  readStringByteSizeOfByte:()->
    @readStringByte(@readUnsignedByte()-1)

  readStringByteSizeOfInteger:()->
    @readStringByte(@readInt()-1)

exports.GTPInputStream = GTPInputStream
