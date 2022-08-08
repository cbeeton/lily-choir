%{
   Lilypond code to create pdf and midi files, and also parts files (xxx-Alto.midi, xxx-Tenor.midi, xxx-Bass.midi) .
   Also creates a Lead sheet if guitar chords are included, and an Accomp pdf if organ music is provided.
   To use this file:
   Create variables as shown below.  Put tempo changes in the sop line only - it will be applied to all parts files.
   Then include at the bottom of the file:
   \include "lily-choir.ly"

OrigTempo = 120
OrigKey = d
TransposeToKey = d    % you can transpose the entire thing by changing this
Key = \key \OrigKey \major
Time = {
  \numericTimeSignature
  \time 4/4
  \tempo 4 = \OrigTempo
}

Chords <- optional chords (if defined, will produce a Lead sheet with just melody, lyrics, and chords)
SopranoMusic
DescantMusic   <- optional descant line
AltoMusic
TenorMusic
BassMusic
OrganRH <- optional separate accompaniment RH
OrganLH <- optional separate accompaniment LH
OrganDynamics -> optional dynamics for accomp

\include "lily-choir.ly"

 YMMV - This is still a work in progress
   TODO:
   - alto line doesn't play notes that are in the sop line at the right volume
   - I tweak this file sometimes to get or hide metronome marks, bar numbers, etc - should pass in a variable somehow
   - tweaks also required to adjust spacing for the specific piece...
   - dynamics?
   - have to edit this file to turn articulate on/off
%}

\include "articulate.ly"

SopranoMidiInstrument = "acoustic grand"
AltoMidiInstrument = "acoustic grand"
TenorMidiInstrument = "acoustic grand"
BassMidiInstrument = "acoustic grand"
SopranoInstrumentName = "Soprano"
SopranoShortInstrumentName = "S"

% kludgey way to exclude some stuff if the calling music doesn't include it
include-verse =
#(define-scheme-function (verse) (string?)
    (define sym (string->symbol verse))
      (if (null? (ly:parser-lookup sym))
          #f #t)
)

music = {
  \transpose \OrigKey \TransposeToKey
  \new GrandStaff <<
    #(if (include-verse "DescantMusic") #{
    % descant in the parts midi only
    % if you don't want to print the descant, remove print from the set of tags on the next line
    \tag #'(print play alto tenor bass) \new Staff 
      \with { 
%        midiInstrument = "flute" 
        instrumentName = \markup \smallCaps "Descant"
        shortInstrumentName = \markup \smallCaps "D"
      }
%    \articulate 
    <<  
      \Key
      \Time
      {
        \tag #'(accomp alto tenor bass) \set Staff.midiMaximumVolume = #0.4 % quieter melody in the parts files - keep the descant in to get any tempo changes in the (usually) last verse
        \DescantMusic % include enough skips to put it where you want it (i.e. last verse)
      }
    >>
    #})
    #(if (include-verse "Chords") #{
      \new ChordNames {
        \tag #'(print play lead) \Chords
      }
    #})

    \new ChoirStaff <<
    \tag #'(print play lead soprano alto tenor bass) \new Staff 
    \with { 
      \remove "Dynamic_engraver" 
      midiInstrument = "acoustic grand" 
      instrumentName = \markup { \right-column { \smallCaps "Soprano" \line { \smallCaps "Alto" } } }
      shortInstrumentName = \markup { \right-column { \smallCaps "S" \line { \smallCaps "A" } } }
    }
    <<
      \override Staff.TimeSignature #'style = #'()
%      \omit Score.MetronomeMark    % hide the tempo marking
      \new Voice = "sopranos" 
      \with { 
%        \remove "Dynamic_engraver" 
      } {
        % this makes the alto part quiet if it's the same note as the sop - can't figure out how to avoid this
        \tag #'(alto tenor bass) \set Voice.midiMaximumVolume = #0.6 % quieter melody in the parts files
        \tag #'(play) \set Voice.midiMaximumVolume = #1.5 % louder melody in the complete version
        \voiceOne
        << 
          \Key
          \Time
          {
            % all parts include the sop line so that timing can be put there and applied to all parts
            \tag #'(print play lead soprano alto tenor bass) \SopranoMusic
          }
        >>
      }
    #(if (include-verse "AltoMusic") #{
      \new Voice = "altos" \with { \remove "Dynamic_engraver" } {
        \tag #'(alto) \set Voice.midiMaximumVolume = #1.2  % louder when generating the alto part
        \voiceTwo
        << 
          \Key
          \Time
          {
            \tag #'(print play alto) \AltoMusic
          }
        >>
      }
    #})
    >>
    \new Lyrics = "lyricsOne"
    \new Lyrics = "lyricsTwo"
    \new Lyrics = "lyricsThree"
    \new Lyrics = "lyricsFour"
    \new Lyrics = "lyricsFive"
    \new Lyrics = "lyricsSix"
    \tag #'(print play tenor bass) \new Staff = "men" 
      \with {
        midiInstrument = "acoustic grand" 
        instrumentName = \markup { \right-column { \smallCaps "Tenor" \line { \smallCaps "Bass" } } }
        shortInstrumentName = \markup { \right-column { \smallCaps "T" \line { \smallCaps "B" } } }
      }
    <<
      \override Staff.TimeSignature #'style = #'()
      \tag #'(tenor bass) \set Staff.midiMaximumVolume = #1.2  % louder when generating the men's parts
      \clef bass
    #(if (include-verse "TenorMusic") #{
      \new Voice = "tenors" \with { \remove "Dynamic_engraver" } {
        \voiceOne
        << 
          \Key 
          \Time
          {
            \tag #'(print play tenor) \TenorMusic
          }
         >>
      }
    #})
      \new Voice = "basses" \with { \remove "Dynamic_engraver" } {
        \voiceTwo
        << 
          \Key
          \Time
          {
            \tag #'(print play bass) \BassMusic
          }
        >>
      }
    >>
    \tag #'(print lead) \context Lyrics = "lyricsOne" \lyricsto "sopranos" \VerseOne
     #(if (include-verse "VerseTwo") #{ \tag #'(print lead) \context Lyrics = "lyricsTwo" \lyricsto "sopranos" \VerseTwo#})
     #(if (include-verse "VerseThree") #{\tag #'(print lead) \context Lyrics = "lyricsThree" \lyricsto "sopranos" \VerseThree#})
     #(if (include-verse "VerseFour") #{\tag #'(print lead) \context Lyrics = "lyricsFour" \lyricsto "sopranos" \VerseFour#})
     #(if (include-verse "VerseFive") #{\tag #'(print lead) \context Lyrics = "lyricsFive" \lyricsto "sopranos" \VerseFive#})
     #(if (include-verse "VerseSix") #{\tag #'(print lead) \context Lyrics = "lyricsSix" \lyricsto "sopranos" \VerseSix#})
     #(if (include-verse "VerseSeven") #{\tag #'(print lead) \context Lyrics = "lyricsSeven" \lyricsto "sopranos" \VerseSeven#})
    >> % end of ChoirStaff

    #(if (include-verse "OrganRH") #{
    \tag #'(print accomp) \new PianoStaff 
      \with { midiInstrument = "acoustic grand" }
%    \articulate 
          <<
          \tag #'midi \new Dynamics = "dynamics" \OrganDynamics  % for the midi
        \new Staff {
          \clef "treble"
          \override Staff.NoteCollision.merge-differently-headed = ##t
          \set Staff.soloText = #""
          \set Staff.aDueText = #""
          \Key
          \Time
          <<
          \new Voice <<
            \OrganRH
            \tag #'midi \OrganDynamics   % for the midi
          >>
          \new NullVoice = "accompVoice" { \SopranoMusic } % not printed but used to align lyrics
          >>
        }
    \tag #'(accomp print) \context Lyrics = "lyricsOne" \lyricsto "accompVoice" \VerseOne
    \tag #'(accomp print) \context Lyrics = "lyricsTwo" \lyricsto "accompVoice" \VerseTwo
        \tag #'(accomp print lead) \new Dynamics {   % for the layout
          \OrganDynamics
        }
        \new Staff {
          \clef "bass"
          \set Staff.soloText = #""
          \set Staff.soloIIText = #""
          \set Staff.aDueText = #""
          \Key
          \Time
          \new Voice <<
            \OrganLH
            \tag #'midi \OrganDynamics   % for the midi
          >>
        }
      >> % organ

    #})
  >>
}

\score {
  \keepWithTag #'print \music
  \layout {
    \context {
      \ChordNames
      \consists "Stanza_number_engraver"
    }
    \context {
      \Score
      \RemoveAllEmptyStaves
      \override VerticalAxisGroup.remove-empty = ##t
      \omit BarNumber
    }
  }
}
\score {
  \keepWithTag #'play \unfoldRepeats \music
  \midi { }
}

% TODO - I can't figure out how to stop this from making a bogus .pdf (layout) when there is nothing tagged organRH...
\book {
    \bookOutputSuffix "Accomp"
    \score {
      \keepWithTag #'(accomp midi) \unfoldRepeats \music
#(if (include-verse "OrganLH") #{
      \midi { 
        \context { 
            \type "Performer_group" 
            \name Dynamics 
            \consists "Piano_pedal_performer" 
        } 
        \context { 
            \Staff 
            \accepts Dynamics 
        } 
        \context { 
            \PianoStaff 
            \accepts Dynamics 
        } 

        \context
        {
            \Voice
            \consists "Dynamic_performer"
        }
        \context
        {
            \Staff
            \consists "Dynamic_performer"
        }
      }
#})
    }
    \score {
      \keepWithTag #'(accomp) \keepWithTag #'(print) \music
#(if (include-verse "OrganRH") #{
      \layout { }
#})
    }
}


\book {
  \bookOutputSuffix "Lead"
    \paper {
      page-count = #1
      system-system-spacing.basic-distance = #22
    }
  \score {
    \keepWithTag #'(lead) \music
    \layout {
      indent = #0
      #(layout-set-staff-size 22)
      \context {
        \ChordNames
        \consists "Stanza_number_engraver"
      }
      \context {
        \Score
        \omit BarNumber
      }
      \context {
        \Staff
        \RemoveAllEmptyStaves
      }
    }
  }
}
\book {
  \bookOutputSuffix "Alto"
  \score {
    \keepWithTag #'(alto) \unfoldRepeats \music
    \midi { }
  }
}
\book {
  \bookOutputSuffix "Tenor"
  \score {
    \keepWithTag #'(tenor) \unfoldRepeats \music
    \midi { }
  }
}
\book {
  \bookOutputSuffix "Bass"
  \score {
    \keepWithTag #'(bass) \unfoldRepeats \music
    \midi { }
  }
}
