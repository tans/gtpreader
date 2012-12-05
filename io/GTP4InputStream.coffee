{GTPInputStream} = require './GTPInputStream'
fs = require 'fs'
util = require 'util'

class TGMeasureHeader
	@TRIPLET_FEEL_NONE = 1
	@TRIPLET_FEEL_EIGHTH = 2
	@TRIPLET_FEEL_SIXTEENTH = 3

class Song
	@measureHeaders = []
	@tracks = []
class GP4InputStream extends GTPInputStream 
	song = new Song
	readSong:()->
		song.version = @readVersion()

		if(not /FICHIER GUITAR PRO v4.*/.test(song.version))
			return console.log 'not suport format'
		song.Info = @readInfo()

		@tripletFeel = if @readBoolean() then TGMeasureHeader.TRIPLET_FEEL_EIGHTH else TGMeasureHeader.TRIPLET_FEEL_NONE

		lyricTrack = @readInt()
		lyric = @readLyrics()

		tempoValue = @readInt()

		song.key = @readInt() #key

		song.octave = @readByte() #octave

		channels = @readChannels()

		measures = @readInt()

		tracks = @readInt()

		song.measureHeaders = @readMeasureHeaders measures
		song.tracks = @readTracks tracks,channels,lyric,lyricTrack
		song.measures = @readMeasures measures,tracks,tempoValue
		return song

	readInfo:()->
		song.name = @readStringByteSizeOfInteger()
		song.subtitle = @readStringByteSizeOfInteger()
		song.artist = @readStringByteSizeOfInteger()
		song.album = @readStringByteSizeOfInteger()
		song.author = @readStringByteSizeOfInteger()
		song.copyright = @readStringByteSizeOfInteger()
		song.writer = @readStringByteSizeOfInteger()
		song.afterWriter = @readStringByteSizeOfInteger()

		comments = @readInt()
		song.comments = []
		while comments>0
			song.comments.push(@readStringByteSizeOfInteger())
			comments--
	readLyrics:()->
		console.log 'fuck lyric'

	readMeasureHeaders:(count)->
		measureHeaders = []
		while count>0
			measureHeaders.push @readMeasureHeader(count+1)
			count--
		song.measureHeaders = measureHeaders
	readTracks:(count)->
		song.tracks = []
		while count>0
			song.tracks.push @readTrack(number+1)
			count--

	readMeasures:(measures,tracks,tempoValue)->
		tempo = {}
		tempo.value = tempoValue

		track = []
		while measures > 0 
			i = tracks
			while i>0
				track[tracks - i] = [] unless track[tracks-1]
				track[tracks - i].push @readMeasure(tempo)
				i-- 
			measures--
		song.track = track

	readLyrics:()->
		lyric = {}
		lyric.form = @readInt()
		lyric.lyrics = @readStringInteger()
		i = 4
		while i>0
			@readInt()
			@readStringInteger()
			i--
		song.lyric = lyric


	readChannels:()->
		channels = []
		i=0
		while i<64
			channel = {}
			channel.channel = i
			channel.effectChannel =i
			channel.instrument = @readInt()
			channel.volume = @readByte()
			channel.balance = @readByte()
			channel.chorus = @readByte()
			channel.reverb = @readByte()
			channel.phaser = @readByte()
			channel.tremolo = @readByte()
			channels.push channel
			i++
		return channels

	readBeat:(start,measure,track,tempo)->
		flags = @readUnsignedByte()
		if parseInt(flags & 0x40) isnt 0
			@readUnsignedByte()
		beat = {}
		voice = beat.getVoice 0 #todo
		duration = readDuration flags

			
	readText:()->

	readDuration:()->

	getTiedNoteValue:()->

	readColor:()->

	readMarker:()->

	readMeasureHeader:()->

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

fileStream = fs.createReadStream('../sample/FadeToBlack.gp4');
bufferArray=[]
fileStream.on 'data',(data)->
  	bufferArray.push data
fileStream.on 'end',()->
	gtpBuffer=Buffer.concat bufferArray
	gtpReader=new GP4InputStream(gtpBuffer);
	gtpReader.init()
	console.log gtpReader.readSong()

