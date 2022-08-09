A template for [Lilypond](http://lilypond.org/) that produces midi tracks for each voice in a SATB choir.

As well as the usual beautifully typeset music, this template creates "voice louder" tracks for the Alto, Tenor, and Bass parts, which include a quiet Soprano for reference.  The midi files are suitable for recording voices and then mixing together for perfect timing and harmony.

The entire piece can be transposed by one single command (set the desired `TransposeToKey`).

This template also allows guitar chords, and creates a Lead sheet with just the Soprano, lyrics, and chords.

It makes use of the `tag` feature of Lilypond, expanding the SATB `print` and `play` tags with ones for alto, tenor, bass, and lead.  (This happens in the background, but you can use the tags in your music code as well to get the results you want).  

Loosely based off the [SATB template](https://lilypond.org/doc/v2.22/Documentation/learning/satb-template), define your SopranoMusic, AltoMusic, etc and put lyrics in VerseOne etc.  Use `\repeat volta` sections and alternative endings to make the midi sound as required.  Put as the last line:
```
\include "lily-choir.ly"
```

A descant line can also be included.  If you want it only in some verses, put enough "\skips" in to move it to the last verse for the midi recording (tagged with `\tag #'(play alto tenor bass)` so it will display in the print version).

As an example, Amazing Grace with a descant in the fifth verse is included.  Running through lilypond produces:
- amazingGrace.pdf
- amazingGrace.midi (with repeats played out)
- amazingGrace-Alto.midi (alto line louder, just a bit of soprano)
- amazingGrace-Tenor.midi (tenor line louder, just a bit of soprano)
- amazingGrace-Bass.midi (bass line louder, just a bit of soprano)
- amazingGrace-Lead.pdf (just soprano, chords, and lyrics)
- amazingGrace-Accomp.pdf (just the piano parts - this song doesn't have any)
