{GTPInputStream} = require './GTPInputStream'
fs = require 'fs'
util = require 'util'

class TGMeasureHeader
	@TRIPLET_FEEL_NONE = 1
	@TRIPLET_FEEL_EIGHTH = 2
	@TRIPLET_FEEL_SIXTEENTH = 3

class Song
	@ measureHeaders = []
    @tracks = []
class GP4InputStream extends GTPInputStream 
	song = new Song
	readSong:()->
		song.version =  @readVersion()
		if(not /FICHER GUITAR PRO v4*/.match(song.version))
			return console.log 'not suport format'
		song.Info = readInfo()

		@tripletFeel = if readBoolean() then TGMeasureHeader.TRIPLET_FEEL_EIGHTH else TGMeasureHeader.TRIPLET_FEEL_NONE

		lyricTrack = readInt()
		lyric = readLyrics()

		tempoValue = readInt()

		readInt() #key

		beadByte() #octave

		channels = readChannels()

		measures = readInt()
		tracks = readInt()

		song.measureHeaders = readMeasureHeaders measures
		song.tracks = readTracks tracks,channels,lyric,lyricTrack
		song.measures = readMeasures measures,tracks,tempoValue
		return song

	readInfo:()->
		song.name = readStringByteSizeOfInteger()

	readLyrics:()->
		console.log 'fuck lyric'

	readMeasureHeaders:()->

	readTracks:()->

	readMeasures:()->

	readLyrics:()->

	readChannels:()->

	readBeat:()->

	readText:()->

	readDuration:()->

	getTiedNoteValue:()->

	readColor:()->

	readMarker:()->

	readMeasureHeaders:()->

	readMeasure:()->

	readNote:()->

	readTrack:()->

	readChanel:()->

	parseRepeatAlternative:()->

	readChord:()->

	readGrace:()->

	readBend:()->

	readTremoloBar:()->

	readTremoloPicking:()->

	readNoteEffects:()->

	readBeatEffects:()->

	readMixChange:()->

	toStrokeValue:()->

	toChanelShort:()->

	getClef:()->

debugger
fileStream = fs.createReadStream('sample/FadeToBlack.gp4');
bufferArray=[]
fileStream.on 'data',(data)->
  	bufferArray.push data
fileStream.on 'end',()->
	gtpBuffer=Buffer.concat bufferArray
	gtpReader=new GP4InputStream(gtpBuffer);
	gtpReader.init()
	gtpReader.readSong()

	console.log SONG
