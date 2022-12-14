%{
   Lilypond code to create pdf and midi files, and also parts files (xxx-Alto.midi, xxx-Tenor.midi, xxx-Bass.midi) .
   Also creates a Lead sheet if guitar chords are included, and an Accomp pdf if Piano music is provided.
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

ChordMusic <- optional chords (if defined, will produce a Lead sheet with just melody, lyrics, and chords)
SopranoMusic   <- included (quietly) in all parts, so tempo changes apply to all
DescantMusic   <- optional descant line.  included (quietly) in all parts, so tempo changes apply to all
AltoMusic
TenorMusic
BassMusic
PianoRHMusic <- optional separate accompaniment RH (will create a pdf file with just accomp)
PianoLHMusic <- optional separate accompaniment LH
PianoDynamics -> optional dynamics for accomp

\include "lily-choir.ly"

 YMMV - This is still a work in progress
   TODO:
   - alto line doesn't play notes that are in the sop line at the right volume
   - dynamics?
   - have to edit this file to turn articulate on/off (it's good for flute descants, but not for sung ones)
   - haven't tested the Piano part lately
   - ability to change midiInstruments
%}

\include "articulate.ly"

% kludgey way to exclude some stuff if the calling music doesn't include it
include-verse =
#(define-scheme-function (verse) (string?)
    (define sym (string->symbol verse))
      (if (null? (ly:parser-lookup sym))
          #f #t)
)

% cribbed from base-tkit.ly
#(define (define-missing-variable! id)
  "Check if the identifier listed in the argument is
   known to the parser.  If not, define it and set
   its value to #f"
        (define sym (string->symbol id))
        (if (null? (ly:parser-lookup sym))
            (ly:parser-define! sym #f)
        )
)

#(define-missing-variable! "HideMetronome")
#(define-missing-variable! "HideBarNumbers")
#(define-missing-variable! "Layout")
#(define-missing-variable! "LeadLayout")
#(define-missing-variable! "LeadSystemSpacing")
#(define-missing-variable! "PianoRHMusic")

music = {
  \transpose \OrigKey \TransposeToKey
  \new GrandStaff <<
    #(if (include-verse "DescantMusic") #{
    % if you don't want to print the descant, remove print from the set of tags on the next line
    \tag #'(print play alto tenor bass) \new Staff 
      \with { 
%        midiInstrument = "flute" 
        instrumentName = \markup \smallCaps "Descant"
        shortInstrumentName = \markup \smallCaps "D"
      }
%    \articulate   % articulate is nicer with flute, not so nice for singers
    <<  
      \Key
      \Time
      {
        \tag #'(accomp alto tenor bass) \set Staff.midiMaximumVolume = #0.4 % quieter melody in the parts files - keep the descant in to get any tempo changes in the (usually) last verse
        \DescantMusic % include enough skips to put it where you want it (e.g. last verse)
      }
    >>
    #})
    #(if (include-verse "ChordMusic") #{
      \new ChordNames {
        \tag #'(print play lead) \ChordMusic
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
         #(if HideMetronome #{ \omit Score.MetronomeMark #} )
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

    #(if PianoRHMusic #{
    \tag #'(print accomp) \new PianoStaff 
      \with { midiInstrument = "acoustic grand" }
%    \articulate 
          <<
          \tag #'midi \new Dynamics = "dynamics" \PianoDynamics  % for the midi
        \new Staff {
          \clef "treble"
          \override Staff.NoteCollision.merge-differently-headed = ##t
          \set Staff.soloText = #""
          \set Staff.aDueText = #""
          \Key
          \Time
          <<
          \new Voice <<
            \PianoRHMusic
            \tag #'midi \PianoDynamics   % for the midi
          >>
          \new NullVoice = "accompVoice" { \SopranoMusic } % not printed but used to align lyrics
          >>
        }
    \tag #'(accomp print) \context Lyrics = "lyricsOne" \lyricsto "accompVoice" \VerseOne
    \tag #'(accomp print) \context Lyrics = "lyricsTwo" \lyricsto "accompVoice" \VerseTwo
        \tag #'(accomp print lead) \new Dynamics {   % for the layout
          \PianoDynamics
        }
        \new Staff {
          \clef "bass"
          \set Staff.soloText = #""
          \set Staff.soloIIText = #""
          \set Staff.aDueText = #""
          \Key
          \Time
          \new Voice <<
            \PianoLHMusic
            \tag #'midi \PianoDynamics   % for the midi
          >>
        }
      >> % Piano

    #})
  >>
}

\layout {
  \context {
    \Staff
    \override VerticalAxisGroup.remove-empty = ##t
    \override VerticalAxisGroup.remove-first = ##t
  }
  \context {
    \Score
    #(if HideBarNumbers #{ \omit BarNumber #} )
  }
}

\score {
  \keepWithTag #'print \music
  \layout { $(if Layout Layout) }
}
\score {
  \keepWithTag #'play \unfoldRepeats \music
  \midi { }
}

% only create accomp files if PianoRHMusic is defined
#(if PianoRHMusic (print-book-with-defaults #{
  \book {
    \bookOutputSuffix "Accomp"
    \score {
      \keepWithTag #'(accomp midi) \unfoldRepeats \music
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
    }
    \score {
      \keepWithTag #'(accomp) \keepWithTag #'(print) \music
      \layout { }
    }
  }
 #})
)


\book {
  \bookOutputSuffix "Lead"
  \paper {
    system-system-spacing.basic-distance = #(if LeadSystemSpacing LeadSystemSpacing)
  }
  \score {
    \keepWithTag #'(lead) \music
    \layout { $(if LeadLayout LeadLayout) }
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
