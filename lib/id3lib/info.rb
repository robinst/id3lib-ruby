
module ID3Lib
  
  #
  # Use this module to obtain information about ID3 frames, fields and genres.
  #
  # === Frame information
  #
  # Access the information through the #frame function or
  # through direct access on the Frames array.
  #
  # For example to get all the frames which take a :textenc and a :text field:
  #
  #    ID3Lib::Info::Frames.select{ |f| f[3] == [:textenc, :text] }
  #
  # The frame information is stored in an array. Let's have a look at it:
  #
  #    f = ID3Lib::Info.frame(:AENC)
  #
  #    f[0]  #=> 1
  #          #=> internal ID for id3lib
  #
  #    f[1]  #=> :AENC
  #          #=> frame ID as specified in ID3 standard
  #
  #    f[2]  #=> "Audio encryption"
  #          #=> description according to id3lib
  #
  #    f[3]  #=> [:owner, :data]
  #          #=> IDs of fields allowed in that frame
  #
  # === Field information
  #
  # Use the #field function or the Fields array to access field information.
  #
  # The array for a field is:
  #
  #    f = ID3Lib::Info.field(:text)
  #
  #    f[0]  #=> 2
  #          #=> internal ID
  #
  #    f[1]  #=> :text
  #          #=> field ID
  #
  #    f[2]  #=> "Text field"
  #          #=> description
  #
  # === Genre information
  #
  # Genre information is useful if you want to set the genre of an ID3v1 tag
  # or to get an overview of genres.
  #
  #    ID3Lib::Info::Genres.index("Pop")   #=> 13
  #
  module Info
    
    Frames = [
      # Special frames
      [1, :AENC, "Audio encryption", [:owner, :data]], # not fully supported by id3lib
      [2, :APIC, "Attached picture", [:textenc, :mimetype, :picturetype, :description, :data]],
      [3, :ASPI, "Audio seek point index", [:data]], # not fully supported by id3lib
      [4, :COMM, "Comments", [:textenc, :language, :description, :text]],
      [5, :COMR, "Commercial frame", [:data]], # not fully supported by id3lib
      [6, :ENCR, "Encryption method registration", [:owner, :id, :data]],
      [7, :EQU2, "Equalisation (2)", [:id, :text]],
      [8, :EQUA, "Equalization", [:data]], # not fully supported by id3lib
      [9, :ETCO, "Event timing codes", [:data]], # not fully supported by id3lib
      [10, :GEOB, "General encapsulated object", [:textenc, :mimetype, :filename, :description, :data]],
      [11, :GRID, "Group identification registration", [:owner, :id, :data]],
      [12, :IPLS, "Involved people list", [:textenc, :text]],
      [13, :LINK, "Linked information", [:data]], # not fully supported by id3lib
      [14, :MCDI, "Music CD identifier", [:data]],
      [15, :MLLT, "MPEG location lookup table", [:data]], # not fully supported by id3lib
      [16, :OWNE, "Ownership frame", [:data]], # not fully supported by id3lib
      [17, :PRIV, "Private frame", [:owner, :data]],
      [18, :PCNT, "Play counter", [:counter]],
      [19, :POPM, "Popularimeter", [:email, :rating, :counter]],
      [20, :POSS, "Position synchronisation frame", [:data]], # not fully supported by id3lib
      [21, :RBUF, "Recommended buffer size", [:data]], # not fully supported by id3lib
      [22, :RVA2, "Relative volume adjustment (2)", [:data]], # not fully supported by id3lib
      [23, :RVAD, "Relative volume adjustment", [:data]], # not fully supported by id3lib
      [24, :RVRB, "Reverb", [:data]], # not fully supported by id3lib
      [25, :SEEK, "Seek frame", [:data]], # not fully supported by id3lib
      [26, :SIGN, "Signature frame", [:id, :data]],
      [27, :SYLT, "Synchronized lyric/text", [:textenc, :language, :timestampformat, :contenttype, :description, :data]],
      [28, :SYTC, "Synchronized tempo codes", [:timestampformat, :data]],
      # Text information frames
      [29, :TALB, "Album/Movie/Show title", [:textenc, :text]],
      [30, :TBPM, "BPM (beats per minute)", [:textenc, :text]],
      [31, :TCOM, "Composer", [:textenc, :text]],
      [32, :TCON, "Content type", [:textenc, :text]],
      [33, :TCOP, "Copyright message", [:textenc, :text]],
      [34, :TDAT, "Date", [:textenc, :text]],
      [35, :TDEN, "Encoding time", [:textenc, :text]],
      [36, :TDLY, "Playlist delay", [:textenc, :text]],
      [37, :TDOR, "Original release time", [:textenc, :text]],
      [38, :TDRC, "Recording time", [:textenc, :text]],
      [39, :TDRL, "Release time", [:textenc, :text]],
      [40, :TDTG, "Tagging time", [:textenc, :text]],
      [41, :TIPL, "Involved people list", [:textenc, :text]],
      [42, :TENC, "Encoded by", [:textenc, :text]],
      [43, :TEXT, "Lyricist/Text writer", [:textenc, :text]],
      [44, :TFLT, "File type", [:textenc, :text]],
      [45, :TIME, "Time", [:textenc, :text]],
      [46, :TIT1, "Content group description", [:textenc, :text]],
      [47, :TIT2, "Title/songname/content description", [:textenc, :text]],
      [48, :TIT3, "Subtitle/Description refinement", [:textenc, :text]],
      [49, :TKEY, "Initial key", [:textenc, :text]],
      [50, :TLAN, "Language(s)", [:textenc, :text]],
      [51, :TLEN, "Length", [:textenc, :text]],
      [52, :TMCL, "Musician credits list", [:textenc, :text]],
      [53, :TMED, "Media type", [:textenc, :text]],
      [54, :TMOO, "Mood", [:textenc, :text]],
      [55, :TOAL, "Original album/movie/show title", [:textenc, :text]],
      [56, :TOFN, "Original filename", [:textenc, :text]],
      [57, :TOLY, "Original lyricist(s)/text writer(s)", [:textenc, :text]],
      [58, :TOPE, "Original artist(s)/performer(s)", [:textenc, :text]],
      [59, :TORY, "Original release year", [:textenc, :text]],
      [60, :TOWN, "File owner/licensee", [:textenc, :text]],
      [61, :TPE1, "Lead performer(s)/Soloist(s)", [:textenc, :text]],
      [62, :TPE2, "Band/orchestra/accompaniment", [:textenc, :text]],
      [63, :TPE3, "Conductor/performer refinement", [:textenc, :text]],
      [64, :TPE4, "Interpreted, remixed, or otherwise modified by", [:textenc, :text]],
      [65, :TPOS, "Part of a set", [:textenc, :text]],
      [66, :TPRO, "Produced notice", [:textenc, :text]],
      [67, :TPUB, "Publisher", [:textenc, :text]],
      [68, :TRCK, "Track number/Position in set", [:textenc, :text]],
      [69, :TRDA, "Recording dates", [:textenc, :text]],
      [70, :TRSN, "Internet radio station name", [:textenc, :text]],
      [71, :TRSO, "Internet radio station owner", [:textenc, :text]],
      [72, :TSIZ, "Size", [:textenc, :text]],
      [73, :TSOA, "Album sort order", [:textenc, :text]],
      [74, :TSOP, "Performer sort order", [:textenc, :text]],
      [75, :TSOT, "Title sort order", [:textenc, :text]],
      [76, :TSRC, "ISRC (international standard recording code)", [:textenc, :text]],
      [77, :TSSE, "Software/Hardware and settings used for encoding", [:textenc, :text]],
      [78, :TSST, "Set subtitle", [:textenc, :text]],
      [79, :TXXX, "User defined text information", [:textenc, :text]],
      [80, :TYER, "Year", [:textenc, :text]],
      # Special frames again
      [81, :UFID, "Unique file identifier", [:owner, :data]],
      [82, :USER, "Terms of use", [:textenc, :language, :text]],
      [83, :USLT, "Unsynchronized lyric/text transcription", [:textenc, :language, :description, :text]],
      # URL link frames
      [84, :WCOM, "Commercial information", [:text]],
      [85, :WCOP, "Copyright/Legal infromation", [:text]],
      [86, :WOAF, "Official audio file webpage", [:text]],
      [87, :WOAR, "Official artist/performer webpage", [:text]],
      [88, :WOAS, "Official audio source webpage", [:text]],
      [89, :WORS, "Official internet radio station homepage", [:text]],
      [90, :WPAY, "Payment", [:text]],
      [91, :WPUB, "Official publisher webpage", [:text]],
      [92, :WXXX, "User defined URL link", [:textenc, :description, :url]]
    ]
    
    Fields = [
      [0, :nofield, "No field"],
      [1, :textenc, "Text encoding (unicode or ASCII)"],
      [2, :text, "Text field"],
      [3, :url, "A URL"],
      [4, :data, "Data field"],
      [5, :description, "Description field"],
      [6, :owner, "Owner field"],
      [7, :email, "Email field"],
      [8, :rating, "Rating field"],
      [9, :filename, "Filename field"],
      [10, :language, "Language field"],
      [11, :picturetype, "Picture type field"],
      [12, :imageformat, "Image format field"],
      [13, :mimetype, "Mimetype field"],
      [14, :counter, "Counter field"],
      [15, :id, "Identifier/Symbol field"],
      [16, :volumeadj, "Volume adjustment field"],
      [17, :numbits, "Number of bits field"],
      [18, :volchgright, "Volume chage on the right channel"],
      [19, :volchgleft, "Volume chage on the left channel"],
      [20, :peakvolright, "Peak volume on the right channel"],
      [21, :peakvolleft, "Peak volume on the left channel"],
      [22, :timestampformat, "SYLT Timestamp Format"],
      [23, :contenttype, "SYLT content type"]
    ]
    
    FieldType = {
      0 => :integer, 
      1 => :binary, 
      2 => :text
    }
    
    Genres = [
      "Blues", "Classic Rock", "Country", "Dance",
      "Disco", "Funk", "Grunge", "Hip-Hop",
      "Jazz", "Metal", "New Age", "Oldies",
      "Other", "Pop", "R&B", "Rap",
      "Reggae", "Rock", "Techno", "Industrial",
      "Alternative", "Ska", "Death Metal", "Pranks",
      "Soundtrack", "Euro-Techno", "Ambient", "Trip-Hop",
      "Vocal", "Jazz+Funk", "Fusion", "Trance",
      "Classical", "Instrumental", "Acid", "House",
      "Game", "Sound Clip", "Gospel", "Noise",
      "AlternRock", "Bass", "Soul", "Punk",
      "Space", "Meditative", "Instrumental Pop", "Instrumental Rock",
      "Ethnic", "Gothic", "Darkwave", "Techno-Industrial",
      "Electronic", "Pop-Folk", "Eurodance", "Dream",
      "Southern Rock", "Comedy", "Cult", "Gangsta",
      "Top 40", "Christian Rap", "Pop/Funk", "Jungle",
      "Native American", "Cabaret", "New Wave", "Psychadelic",
      "Rave", "Showtunes", "Trailer", "Lo-Fi",
      "Tribal", "Acid Punk", "Acid Jazz", "Polka",
      "Retro", "Musical", "Rock & Roll", "Hard Rock",
      # Winamp extensions
      "Folk", "Folk-Rock", "National Folk", "Swing",
      "Fast Fusion", "Bebob", "Latin", "Revival",
      "Celtic", "Bluegrass", "Avantgarde", "Gothic Rock",
      "Progressive Rock", "Psychedelic Rock", "Symphonic Rock", "Slow Rock",
      "Big Band", "Chorus", "Easy Listening", "Acoustic",
      "Humour", "Speech", "Chanson", "Opera",
      "Chamber Music", "Sonata", "Symphony", "Booty Bass",
      "Primus", "Porn Groove", "Satire", "Slow Jam",
      "Club", "Tango", "Samba", "Folklore",
      "Ballad", "Power Ballad", "Rhythmic Soul", "Freestyle",
      "Duet", "Punk Rock", "Drum Solo", "A capella",
      "Euro-House", "Dance Hall", "Goa", "Drum & Bass",
      "Club-House", "Hardcore", "Terror", "Indie",
      "Britpop", "Negerpunk", "Polsk Punk", "Beat",
      "Christian Gangsta Rap", "Heavy Metal", "Black Metal", "Crossover",
      "Contemporary Christian", "Christian Rock ", "Merengue", "Salsa",
      "Trash Metal", "Anime", "JPop", "Synthpop"
    ]
    
    #
    # Get information of frame specified by _id_.
    #
    #    ID3Lib::Info.frame(:TIT2)  #=> [47, :TIT2, "Title/songname/content description", [:textenc, :text]]
    #
    def self.frame(id)
      index = id.is_a?(Integer) ? NUM : ID
      Frames.find{ |f| f[index] == id }
    end
    
    #
    # Get information of field specified by _id_.
    #
    #    ID3Lib::Info.field(:text)  #=> [2, :text, "Text field"]
    #
    def self.field(id)
      index = id.is_a?(Integer) ? NUM : ID
      Fields.find{ |f| f[index] == id }
    end
            
  end
  
end
