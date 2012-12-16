Duration = require "Duration"

class Beat 
    MAX_VOICES:2;
    

    constructor:(factory)->
        @start = Duration.QUARTER_TIME
        @effect = factory.newBeatEffect()
        @voices = []
        for i in [0..Beat.MAX_VOICES]
            var voice = factory.newVoice(i)
            voice.beat = @
            @voices.push(voice)


    isRestBeat:()->
        for i in [0..@voices.length]
            voice = @voices[i]
            if(!@voice.isEmpty and !@voice.isRestVoice())
                return false
        return true
    
    getRealStart:()->
        offset = start - @measure.start()
        return @measure.header.realStart + offset
    
    setText:(text)->
        text.beat = @
        @.text = text

    setChord:(chord)->
        chord.beat = @
        @.effect.chord = chord
    
    ensureVoices:(count, factory)->
        while(@voices.length < count)
            var voice = factory.newVoice(@voices.length)
            voice.beat = @
            @.voices.push(voice)
    
    getNotes:()->
        var notes = []
        for note in @voice.notes
            notes.push(note)
        return notes

