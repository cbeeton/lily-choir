\version "2.20.0"
\include "english.ly"

\paper {
  line-width = 160\mm
  indent = 0\mm
}

\header {
  texidoc = "Melody and lyrics."
  title = "Amazing Grace"
  composer = "New Britain"
  poet = "John Newton"
  tagline=""
}

OrigKey = g
TransposeToKey = f
Key = \key \OrigKey \major
Time = {
  \time 3/4
  \tempo 4 = 100
  % beam only 2 eights together: \set Timing .beatExceptions, baseMoment, beatStructure
  \set Timing.beamExceptions = #'()
  \set Timing.baseMoment = #(ly:make-moment 1/4)
  \set Timing.beatStructure = 1,1,1
}

SopranoMusic = \relative c' {
  % intro
  \partial 4 b'4 | d4.( b8) d( b) | g2 d4
  e4.( g8) g e | d2 d4 | g2 b8( g) | b2 a4 g2. ~ g2

  \bar ".|:"
  \repeat volta 5 {
    d4 | g2 b8( g) | b2 a4 | g2 e4 | d2 d4
    g2 b8( g) | b2 a4 | d2. ~ d2 b4 | d4.( b8) d( b) | g2 d4
    e4.( g8) g( e) | d2 d4 | g2 b8( g) | b2 a4 g2. ~ g2
  \bar ":|."
  }
}

AltoMusic = \relative c' {
  \partial 4 fs4 | g2 d4 | e2 d4
  c2 c4 | b2 d4 | e2 e4 | g4.( e8) fs4 | g2. ~ g2
  \repeat volta 5 {
    d4 | b2 b4 | b4.( c8) d4 | e2 c4 | b2 d4
    e2 e4 | d2 e4 | fs2( g4 | a2) fs4 | g2 d4 | e2 d4
    c2 c4 | b2 d4 | e2 e4 | g4.( e8) fs4 | g2. ~ g2
  }
}

TenorMusic = \relative c {
  \partial 4 c'4 | b2 b4 | b2 g4
  g2 g4 | g2 a4 | b2 a4 | d2 c4 | b2. ~ b2
  \repeat volta 5 {
    d,4 | d2 d4 | g2 fs4 | e4.( fs8) g a | b2 a4
    b2 g4 | fs2 a4 | a2.( d2) c4 | b2 b4 | b2 g4
    g2 g4 | g2 a4 | b2 a4 | d2 c4 | b2. ~ b2
  }
}

BassMusic = \relative c {
  \partial 4 d4 | g2 g4 | e2 b4
  c2 e4 | g2 fs4 | e2 c4 | d2 d4 | g2. ~ g2
  \repeat volta 5 {
    d4 | g,2 g4 | g2 b4 | c4.( d8) e fs | g2 fs4
    e2 e4 | b2 c4| d2( e4 | fs2) d4 | g2 g4 | e2 b4
    c2 e4 | g2 fs4 | e2 c4 | d2 d4 | g2. ~ g2
  }
}

Chords = \chordmode {
   \set noChordSymbol=""
   s4 g2. e2:m g4
   c2. g2 d4 e2:m a4:m g2 d4:7 g2. g2
   \repeat volta 5 {
     s4 g2.\p g2 b4:m7 c2. g2 d4
     e2.:m b2:m a4:m d2. d2. g2. e2:m g4
     c2. g2 d4 e2:m a4:m g2 d4:7 g2. g2
   }
}

VerseOne = \lyricmode
{
  \repeat unfold 15 " " 
  A -- ma -- zing grace! How sweet the sound that
  saved a wretch like me!  I once was lost, but
  now am found: was blind, but now I see.
}
VerseTwo = \lyricmode
{
  \repeat unfold 15 " " 
  'Twas grace that taught my heart to fear,
  and grace my fears re -- lieved;
  how pre -- cious did that grace ap -- pear
  the hour I first be -- lieved!
}
VerseThree = \lyricmode
{
  \repeat unfold 15 " " 
   The Lord has pro -- mised good to me,
  his word my hope se -- cures;
  he will my shield and por -- tion be
  as long as life en -- dures.
}
VerseFour = \lyricmode
{
  \repeat unfold 15 " " 
   Through ma -- ny dan -- gers, toils, and snares
  I have al -- read -- y come;
  'tis grace that brought me safe thus far,
  and grace will lead me home.
}
VerseFive = \lyricmode
{
  \repeat unfold 15 " " 
  When we've been there ten thou -- sand years,
  bright shin -- ing as the sun,
  we've no less days to sing God's praise
  than when we'd first be -- gun.
}

\include "lily-choir.ly"
