
class SongFactory
	new:()->

	newSong:()->
		new Song()

	newLyrics:()->
		new Lyrics(0)

	newLyricLine:()->
		new LyricLine 0,""

	newPageSetup:()->
		new PageSetup()

	newTimeSignature:()->
		new TimeSignature @

	newDuration:()->
		new Duration @

	newMeasureHeader:()->
		new MeasureHeader @

	newTempo:()->
		new Tempo()

	newMarker:()->
		new Marker()

	newStroke:()->
		new BeatStroke()

	newVoice:(index)->
		new Voice @,index

	newNoteEffect:()->
		new NoteEffect()

	newBeatEffect:()->
		new BeatEffect @

	newTrack:()->
		new Track @

	newString:()->
		new GuitarString()

	newMeasure:(header)->
		new Measure header

	newTuplet:()->
		new Tuplet()

	newBeat:()->
		new Beat @

	newBendEffect:()->
		new BendEffect()

	newHarmonicEffect:()->
		new HarmonicEffect()

	newGraceEffect:()->
		new GraceEffect()

	newTrillEffect:()->
		new TrillEffect @

	newTremoloPickingEffect:()->
		new TremoloPickingEffect @

	newChord:(stringCount)->
		new Chord stringCount

	newText:()->
		new BeatText()

	newMixTableChange:()->
		new MixTableChange()

	newNote:()->
		new Note @


exports.SongFactory = SongFactory