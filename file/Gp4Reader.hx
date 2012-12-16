/*
 * This file is part of alphaTab.
 *
 *  alphaTab is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  alphaTab is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with alphaTab.  If not, see <http://www.gnu.org/licenses/>.
 */
package alphatab.file.guitarpro;
import alphatab.file.FileFormatException;
import alphatab.io.Byte;
import alphatab.io.SByte;
import alphatab.model.effects.BendEffect;
import alphatab.model.effects.BendPoint;
import alphatab.model.effects.GraceEffect;
import alphatab.model.effects.GraceEffectTransition;
import alphatab.model.effects.HarmonicEffect;
import alphatab.model.effects.HarmonicType;
import alphatab.model.effects.TremoloPickingEffect;
import alphatab.model.effects.TrillEffect;
import alphatab.model.Beat;
import alphatab.model.BeatEffect;
import alphatab.model.BeatStrokeDirection;
import alphatab.model.BeatText;
import alphatab.model.Chord;
import alphatab.model.Color;
import alphatab.model.Duration;
import alphatab.model.GuitarString;
import alphatab.model.HeaderFooterElements;
import alphatab.model.LyricLine;
import alphatab.model.Lyrics;
import alphatab.model.Marker;
import alphatab.model.Measure;
import alphatab.model.MeasureHeader;
import alphatab.model.MidiChannel;
import alphatab.model.MixTableChange;
import alphatab.model.Note;
import alphatab.model.NoteEffect;
import alphatab.model.PageSetup;
import alphatab.model.SlideType;
import alphatab.model.Song;
import alphatab.model.SongFactory;
import alphatab.model.Tempo;
import alphatab.model.TimeSignature;
import alphatab.model.Track;
import alphatab.model.Tuplet;
import alphatab.model.TripletFeel;
import alphatab.model.Velocities;
import alphatab.model.Voice;
import alphatab.model.Point;
import alphatab.model.Rectangle;
import alphatab.model.SongManager;

/**
 * A reader for GuitarPro 4 files. 
 */
 
class Gp4Reader extends Gp3Reader
{
    public function new() 
    {
        super();
        initVersions(["FICHIER GUITAR PRO v4.00", "FICHIER GUITAR PRO v4.06", "FICHIER GUITAR PRO L4.06"]);
    }
    
    public override function readSong() : Song
    {
        if (!readVersion())
        {
            throw new FileFormatException("Unsupported Version");
        }
        
        var song:Song = factory.newSong();
        
        readInfo(song);
        
        _tripletFeel = data.readBool() ? TripletFeel.Eighth : TripletFeel.None;
        
        readLyrics(song);
        
        readPageSetup(song);
        
        song.tempoName = "";
        song.tempo = data.readInt();
        song.hideTempo = false;
        
        song.key = data.readInt();
        song.octave = data.readSignedByte();
        
        var channels:Array<MidiChannel> = readMidiChannels();
        
        var measureCount = data.readInt();
        var trackCount = data.readInt();
        
        readMeasureHeaders(song, measureCount);
        readTracks(song, trackCount, channels);
        readMeasures(song);
        
        return song;
    }
    
    override private function readLyrics(song:Song) : Void
    {
        song.lyrics = factory.newLyrics();
        song.lyrics.trackChoice = data.readInt();
        for (i in 0 ... Lyrics.MAX_LINE_COUNT) 
        {
            var line:LyricLine = factory.newLyricLine();            
            line.startingMeasure = data.readInt();
            line.lyrics = readIntSizeString(); 
            song.lyrics.lines.push(line);
        }
    }


    override private function readBeat(start:Int, measure:Measure, track:Track, voiceIndex:Int) : Int
    {
        var flags:SByte = data.readSignedByte();
        
        var beat:Beat = getBeat(measure, start);
        var voice:Voice = beat.voices[voiceIndex];
        
        if ((flags & 0x40) != 0) {
            var beatType:SByte = data.readSignedByte();
            voice.isEmpty = ((beatType & 0x02) == 0);
        }
        
        var duration:Duration = readDuration(flags);
        if ((flags & 0x02) != 0) {
            readChord(track.stringCount(), beat);
        }
        if ((flags & 0x04) != 0) {
            readText(beat);
        }
        if ((flags & 0x08) != 0) {
            readBeatEffects(beat, null);
        }
        if ((flags & 0x10) != 0) {
            var mixTableChange:MixTableChange = readMixTableChange(measure);
            beat.effect.mixTableChange = mixTableChange;
        }
        var stringFlags:Int = data.readSignedByte();
        for (j in 0 ... 7)
        {
            var i:Int = 6 - j;
            if ((stringFlags & (1 << i)) != 0 && (6 - i) < track.stringCount()) {
                var guitarString = track.strings[6 - i].clone(factory);
                var note = readNote(guitarString, track, factory.newNoteEffect());
                voice.addNote(note);
            }
            duration.copy(voice.duration);
        }
        
        return (!voice.isEmpty) ? duration.time() : 0;
    }
    
    override private function readNoteEffects(noteEffect:NoteEffect) : Void
    {
        var flags1:SByte = data.readSignedByte();
        var flags2:SByte = data.readSignedByte();
        if ((flags1 & 0x01) != 0) {
            readBend(noteEffect);
        }
        if ((flags1 & 0x10) != 0) {
            readGrace(noteEffect);
        }
        if ((flags2 & 0x04) != 0) {
            readTremoloPicking(noteEffect);
        }
        if ((flags2 & 0x08) != 0) {
            noteEffect.slide = (true);
            var type:SByte = data.readSignedByte();
            switch (type) {
                case 1:
                    noteEffect.slideType = SlideType.FastSlideTo;
                case 2:
                    noteEffect.slideType = SlideType.SlowSlideTo;
                case 4:
                    noteEffect.slideType = SlideType.OutDownWards;
                case 8:
                    noteEffect.slideType = SlideType.OutUpWards;
                case 16:
                    noteEffect.slideType = SlideType.IntoFromBelow;
                case 32:
                    noteEffect.slideType = SlideType.IntoFromAbove;
            }
        }
        if ((flags2 & 0x10) != 0) {
            readArtificialHarmonic(noteEffect);
        }
        if ((flags2 & 0x20) != 0) {
            readTrill(noteEffect);
        }
        noteEffect.letRing = (flags1 & 0x08) != 0;
        noteEffect.hammer = (((flags1 & 0x02) != 0));
        noteEffect.vibrato = (((flags2 & 0x40) != 0) || noteEffect.vibrato);
        noteEffect.palmMute = (((flags2 & 0x02) != 0));
        noteEffect.staccato = (((flags2 & 0x01) != 0));
    }
    
    private function readTrill(noteEffect:NoteEffect) : Void
    {
        var fret:SByte = data.readSignedByte();
        var period:SByte = data.readSignedByte();
        var trill:TrillEffect = factory.newTrillEffect();
        trill.fret = (fret);
        switch (period) {
            case 1:
                trill.duration.value = Duration.SIXTEENTH;
                noteEffect.trill = (trill);
            case 2:
                trill.duration.value = (Duration.THIRTY_SECOND);
                noteEffect.trill = (trill);
            case 3:
                trill.duration.value = (Duration.SIXTY_FOURTH);
                noteEffect.trill = (trill);
        }
    }
    
    private function readArtificialHarmonic(noteEffect:NoteEffect) : Void
    {
        var type:SByte = data.readSignedByte();
        var oHarmonic:HarmonicEffect = factory.newHarmonicEffect();
        oHarmonic.data = 0;
        switch (type) {
            case 1:
                oHarmonic.type = (HarmonicType.Natural);
                noteEffect.harmonic = (oHarmonic);
            case 3:
                skip(1); // Key?
                oHarmonic.type = (HarmonicType.Tapped);
                noteEffect.harmonic = (oHarmonic);
            case 4:
                oHarmonic.type = (HarmonicType.Pinch);
                noteEffect.harmonic = (oHarmonic);
            case 5:
                oHarmonic.type = (HarmonicType.Semi);
                noteEffect.harmonic = (oHarmonic);
            case 15:
                oHarmonic.data = 2;
                oHarmonic.type = (HarmonicType.Artificial);
                noteEffect.harmonic = (oHarmonic);
            case 17:
                oHarmonic.data = 3;
                oHarmonic.type = (HarmonicType.Artificial);
                noteEffect.harmonic = (oHarmonic);
            case 22:
                oHarmonic.data = 0;
                oHarmonic.type = (HarmonicType.Artificial);
                noteEffect.harmonic = (oHarmonic);
        }
    }
    
    private function readTremoloPicking(noteEffect:NoteEffect) : Void
    {
        var value:SByte = data.readSignedByte();
        var tp:TremoloPickingEffect = factory.newTremoloPickingEffect();
        switch (value) {
            case 1:
                tp.duration.value = (Duration.EIGHTH);
                noteEffect.tremoloPicking = (tp);
            case 2:
                tp.duration.value = (Duration.SIXTEENTH);
                noteEffect.tremoloPicking = (tp);
            case 3:
                tp.duration.value = (Duration.THIRTY_SECOND);
                noteEffect.tremoloPicking = (tp);
        }
    }
    
    override private function readMixTableChange(measure:Measure) : MixTableChange
    {
        var tableChange:MixTableChange = factory.newMixTableChange();
        tableChange.instrument.value = data.readSignedByte();
        tableChange.volume.value = data.readSignedByte();
        tableChange.balance.value = data.readSignedByte();
        tableChange.chorus.value = data.readSignedByte();
        tableChange.reverb.value = data.readSignedByte();
        tableChange.phaser.value = data.readSignedByte();
        tableChange.tremolo.value = data.readSignedByte();
        tableChange.tempoName = "";
        tableChange.tempo.value = data.readInt();
        
        if (tableChange.instrument.value < 0) 
            tableChange.instrument = null;
        
        if (tableChange.volume.value >= 0) 
            tableChange.volume.duration = data.readSignedByte();
        else 
            tableChange.volume = null;
        if (tableChange.balance.value >= 0) 
            tableChange.balance.duration = data.readSignedByte();
        else 
            tableChange.balance = null;
        if (tableChange.chorus.value >= 0) 
            tableChange.chorus.duration = data.readSignedByte();
        else 
            tableChange.chorus = null;
        if (tableChange.reverb.value >= 0) 
            tableChange.reverb.duration = data.readSignedByte();
        else
            tableChange.reverb = null;
        if (tableChange.phaser.value >= 0) 
            tableChange.phaser.duration = data.readSignedByte();
        else
            tableChange.phaser = null;
        if (tableChange.tremolo.value >= 0) 
            tableChange.tremolo.duration = data.readSignedByte();
        else 
            tableChange.tremolo = null;
        if (tableChange.tempo.value >= 0) {
            tableChange.tempo.duration = data.readSignedByte();
            measure.tempo().value = tableChange.tempo.value;
            tableChange.hideTempo = false;
        }
        else 
            tableChange.tempo = null;
        
        
        var allTracksFlags:SByte = data.readSignedByte();
        if (tableChange.volume != null) 
            tableChange.volume.allTracks = (allTracksFlags & 0x01) != 0;
        if (tableChange.balance != null) 
            tableChange.balance.allTracks = (allTracksFlags & 0x02) != 0;
        if (tableChange.chorus != null) 
            tableChange.chorus.allTracks = (allTracksFlags & 0x04) != 0;
        if (tableChange.reverb != null) 
            tableChange.reverb.allTracks = (allTracksFlags & 0x08) != 0;
        if (tableChange.phaser != null) 
            tableChange.phaser.allTracks = (allTracksFlags & 0x10) != 0;
        if (tableChange.tremolo != null) 
            tableChange.tremolo.allTracks = (allTracksFlags & 0x20) != 0;
        if (tableChange.tempo != null) 
            tableChange.tempo.allTracks = true;

        return tableChange;
    }
    
    override private function readBeatEffects(beat:Beat, effect:NoteEffect)  : Void
    {
        var flags1:SByte = data.readSignedByte();
        var flags2:SByte = data.readSignedByte();
        beat.effect.fadeIn = (((flags1 & 0x10) != 0));
        beat.effect.vibrato = (((flags1 & 0x02) != 0)) || beat.effect.vibrato;
        if ((flags1 & 0x20) != 0) {
            var slapEffect:SByte = data.readSignedByte();
            beat.effect.tapping = (slapEffect == 1);
            beat.effect.slapping = (slapEffect == 2);
            beat.effect.popping = (slapEffect == 3);
        }
        if ((flags2 & 0x04) != 0) {
            readTremoloBar(beat.effect);
        }
        if ((flags1 & 0x40) != 0) {
            var strokeUp:SByte = data.readSignedByte();
            var strokeDown:SByte = data.readSignedByte();
            if (strokeUp > 0) {
                beat.effect.stroke.direction = BeatStrokeDirection.Up;
                beat.effect.stroke.value = (Gp3Reader.toStrokeValue(strokeUp));
            } 
            else 
                if (strokeDown > 0) {
                    beat.effect.stroke.direction = BeatStrokeDirection.Down;
                    beat.effect.stroke.value = (Gp3Reader.toStrokeValue(strokeDown));
                }
        }
        beat.effect.hasRasgueado = (flags2 & 0x1) != 0;
        if ((flags2 & 0x02) != 0) {
            beat.effect.pickStroke = data.readSignedByte();
            beat.effect.hasPickStroke = true;
        }
    }
    
    override private function readTremoloBar(effect:BeatEffect) : Void 
    {
        var barEffect:BendEffect = factory.newBendEffect();
        barEffect.type = data.readSignedByte();
        barEffect.value = data.readInt();
        var pointCount = data.readInt();
        for (i in 0 ... pointCount) {
            var pointPosition = Math.round(data.readInt() * BendEffect.MAX_POSITION / GpReaderBase.BEND_POSITION);
            var pointValue = Math.round(data.readInt() / (GpReaderBase.BEND_SEMITONE * 2.0));
            var vibrato = data.readBool();
            barEffect.points.push(new BendPoint(pointPosition, pointValue, vibrato));
        }
        
        if (pointCount > 0) 
            effect.tremoloBar = barEffect;
    }
    
    
    
    override private function readChord(stringCount:Int, beat:Beat)
    {
        var chord:Chord = factory.newChord(stringCount);
        if ((data.readSignedByte() & 0x01) == 0) {
            chord.name = (readIntSizeCheckByteString());
            chord.firstFret = (data.readInt());
            if (chord.firstFret != 0) {
                for (i in 0 ... 6) {
                    var fret = data.readInt();
                    if (i < chord.strings.length) {
                        chord.strings[i] = fret;
                    }
                }
            }
        }
        else {
            skip(16);
            chord.name = (readByteSizeString(21));
            skip(4);
            chord.firstFret = (data.readInt());
            for (i in 0 ... 7) {
                var fret = data.readInt();
                if (i < chord.strings.length) {
                    chord.strings[i] = fret;
                }
            }
            skip(32);
        }
        if (chord.noteCount() > 0) {
            beat.setChord(chord);
        }
    }
}