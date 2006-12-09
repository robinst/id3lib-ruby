
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
    
    #
    # Please note that these frames are not fully supported by id3lib:
    #   AENC, COMR, EQUA, ETCO, MCDI, MLLT,
    #   OWNE, POSS, RBUF, RVAD, RVRB, SYTC
    # And these are not supported at all (segfault on usage):
    #   ASPI, EQU2, RVA2, SEEK, SIGN, TDEN,
    #   TDOR, TDRC, TDRL, TDTG, TIPL, TMCL,
    #   TMOO, TPRO, TSOA, TSOP, TSOT, TSST
    #
    Frames = [
      # Special frames
      [0, :____, "No known frame", []],
      [1, :AENC, "Audio encryption", [:data]],
      [2, :APIC, "Attached picture", [:textenc, :imageformat, :mimetype, :picturetype, :description, :data]],
      [3, :ASPI, "Audio seek point index", []],
      [4, :COMM, "Comments", [:textenc, :language, :description, :text]],
      [5, :COMR, "Commercial frame", [:data]],
      [6, :ENCR, "Encryption method registration", [:owner, :identifier, :data]],
      [7, :EQU2, "Equalisation (2)", []],
      [8, :EQUA, "Equalization", [:data]],
      [9, :ETCO, "Event timing codes", [:data]],
      [10, :GEOB, "General encapsulated object", [:textenc, :mimetype, :filename, :description, :data]],
      [11, :GRID, "Group identification registration", [:owner, :identifier, :data]],
      [12, :IPLS, "Involved people list", [:textenc, :text]],
      [13, :LINK, "Linked information", [:identifier, :url, :text]],
      [14, :MCDI, "Music CD identifier", [:data]],
      [15, :MLLT, "MPEG location lookup table", [:data]],
      [16, :OWNE, "Ownership frame", [:data]],
      [17, :PRIV, "Private frame", [:owner, :data]],
      [18, :PCNT, "Play counter", [:counter]],
      [19, :POPM, "Popularimeter", [:email, :rating, :counter]],
      [20, :POSS, "Position synchronisation frame", [:data]],
      [21, :RBUF, "Recommended buffer size", [:data]],
      [22, :RVA2, "Relative volume adjustment (2)", []],
      [23, :RVAD, "Relative volume adjustment", [:data]],
      [24, :RVRB, "Reverb", [:data]],
      [25, :SEEK, "Seek frame", []],
      [26, :SIGN, "Signature frame", []],
      [27, :SYLT, "Synchronized lyric/text", [:textenc, :language, :timestampformat, :contenttype, :description, :data]],
      [28, :SYTC, "Synchronized tempo codes", [:data]],
      # Text information frames
      [29, :TALB, "Album/Movie/Show title", [:textenc, :text]],
      [30, :TBPM, "BPM (beats per minute)", [:textenc, :text]],
      [31, :TCOM, "Composer", [:textenc, :text]],
      [32, :TCON, "Content type", [:textenc, :text]],
      [33, :TCOP, "Copyright message", [:textenc, :text]],
      [34, :TDAT, "Date", [:textenc, :text]],
      [35, :TDEN, "Encoding time", []],
      [36, :TDLY, "Playlist delay", [:textenc, :text]],
      [37, :TDOR, "Original release time", []],
      [38, :TDRC, "Recording time", []],
      [39, :TDRL, "Release time", []],
      [40, :TDTG, "Tagging time", []],
      [41, :TIPL, "Involved people list", []],
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
      [52, :TMCL, "Musician credits list", []],
      [53, :TMED, "Media type", [:textenc, :text]],
      [54, :TMOO, "Mood", []],
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
      [66, :TPRO, "Produced notice", []],
      [67, :TPUB, "Publisher", [:textenc, :text]],
      [68, :TRCK, "Track number/Position in set", [:textenc, :text]],
      [69, :TRDA, "Recording dates", [:textenc, :text]],
      [70, :TRSN, "Internet radio station name", [:textenc, :text]],
      [71, :TRSO, "Internet radio station owner", [:textenc, :text]],
      [72, :TSIZ, "Size", [:textenc, :text]],
      [73, :TSOA, "Album sort order", []],
      [74, :TSOP, "Performer sort order", []],
      [75, :TSOT, "Title sort order", []],
      [76, :TSRC, "ISRC (international standard recording code)", [:textenc, :text]],
      [77, :TSSE, "Software/Hardware and settings used for encoding", [:textenc, :text]],
      [78, :TSST, "Set subtitle", []],
      [79, :TXXX, "User defined text information", [:textenc, :description, :text]],
      [80, :TYER, "Year", [:textenc, :text]],
      # Special frames again
      [81, :UFID, "Unique file identifier", [:owner, :data]],
      [82, :USER, "Terms of use", [:textenc, :language, :text]],
      [83, :USLT, "Unsynchronized lyric/text transcription", [:textenc, :language, :description, :text]],
      # URL link frames
      [84, :WCOM, "Commercial information", [:url]],
      [85, :WCOP, "Copyright/Legal infromation", [:url]],
      [86, :WOAF, "Official audio file webpage", [:url]],
      [87, :WOAR, "Official artist/performer webpage", [:url]],
      [88, :WOAS, "Official audio source webpage", [:url]],
      [89, :WORS, "Official internet radio station homepage", [:url]],
      [90, :WPAY, "Payment", [:url]],
      [91, :WPUB, "Official publisher webpage", [:url]],
      [92, :WXXX, "User defined URL link", [:textenc, :description, :url]]
    ]

    FramesByID = {
      :____ => Frames[0],
      :AENC => Frames[1],
      :APIC => Frames[2],
      :ASPI => Frames[3],
      :COMM => Frames[4],
      :COMR => Frames[5],
      :ENCR => Frames[6],
      :EQU2 => Frames[7],
      :EQUA => Frames[8],
      :ETCO => Frames[9],
      :GEOB => Frames[10],
      :GRID => Frames[11],
      :IPLS => Frames[12],
      :LINK => Frames[13],
      :MCDI => Frames[14],
      :MLLT => Frames[15],
      :OWNE => Frames[16],
      :PRIV => Frames[17],
      :PCNT => Frames[18],
      :POPM => Frames[19],
      :POSS => Frames[20],
      :RBUF => Frames[21],
      :RVA2 => Frames[22],
      :RVAD => Frames[23],
      :RVRB => Frames[24],
      :SEEK => Frames[25],
      :SIGN => Frames[26],
      :SYLT => Frames[27],
      :SYTC => Frames[28],
      :TALB => Frames[29],
      :TBPM => Frames[30],
      :TCOM => Frames[31],
      :TCON => Frames[32],
      :TCOP => Frames[33],
      :TDAT => Frames[34],
      :TDEN => Frames[35],
      :TDLY => Frames[36],
      :TDOR => Frames[37],
      :TDRC => Frames[38],
      :TDRL => Frames[39],
      :TDTG => Frames[40],
      :TIPL => Frames[41],
      :TENC => Frames[42],
      :TEXT => Frames[43],
      :TFLT => Frames[44],
      :TIME => Frames[45],
      :TIT1 => Frames[46],
      :TIT2 => Frames[47],
      :TIT3 => Frames[48],
      :TKEY => Frames[49],
      :TLAN => Frames[50],
      :TLEN => Frames[51],
      :TMCL => Frames[52],
      :TMED => Frames[53],
      :TMOO => Frames[54],
      :TOAL => Frames[55],
      :TOFN => Frames[56],
      :TOLY => Frames[57],
      :TOPE => Frames[58],
      :TORY => Frames[59],
      :TOWN => Frames[60],
      :TPE1 => Frames[61],
      :TPE2 => Frames[62],
      :TPE3 => Frames[63],
      :TPE4 => Frames[64],
      :TPOS => Frames[65],
      :TPRO => Frames[66],
      :TPUB => Frames[67],
      :TRCK => Frames[68],
      :TRDA => Frames[69],
      :TRSN => Frames[70],
      :TRSO => Frames[71],
      :TSIZ => Frames[72],
      :TSOA => Frames[73],
      :TSOP => Frames[74],
      :TSOT => Frames[75],
      :TSRC => Frames[76],
      :TSSE => Frames[77],
      :TSST => Frames[78],
      :TXXX => Frames[79],
      :TYER => Frames[80],
      :UFID => Frames[81],
      :USER => Frames[82],
      :USLT => Frames[83],
      :WCOM => Frames[84],
      :WCOP => Frames[85],
      :WOAF => Frames[86],
      :WOAR => Frames[87],
      :WOAS => Frames[88],
      :WORS => Frames[89],
      :WPAY => Frames[90],
      :WPUB => Frames[91],
      :WXXX => Frames[92],
    }
    
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
      [15, :identifier, "Identifier/Symbol field"],
      [16, :volumeadj, "Volume adjustment field"],
      [17, :numbits, "Number of bits field"],
      [18, :volchgright, "Volume chage on the right channel"],
      [19, :volchgleft, "Volume chage on the left channel"],
      [20, :peakvolright, "Peak volume on the right channel"],
      [21, :peakvolleft, "Peak volume on the left channel"],
      [22, :timestampformat, "SYLT Timestamp Format"],
      [23, :contenttype, "SYLT content type"]
    ]

    FieldsByID = {
      :nofield         => Fields[0],
      :textenc         => Fields[1],
      :text            => Fields[2],
      :url             => Fields[3],
      :data            => Fields[4],
      :description     => Fields[5],
      :owner           => Fields[6],
      :email           => Fields[7],
      :rating          => Fields[8],
      :filename        => Fields[9],
      :language        => Fields[10],
      :picturetype     => Fields[11],
      :imageformat     => Fields[12],
      :mimetype        => Fields[13],
      :counter         => Fields[14],
      :identifier      => Fields[15],
      :volumeadj       => Fields[16],
      :numbits         => Fields[17],
      :volchgright     => Fields[18],
      :volchgleft      => Fields[19],
      :peakvolright    => Fields[20],
      :peakvolleft     => Fields[21],
      :timestampformat => Fields[22],
      :contenttype     => Fields[23],
    }

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
      "Trash Metal", "Anime", "JPop", "Synthpop",
    ]

    
    #
    # Get information of frame specified by _id_.
    #
    #    ID3Lib::Info.frame(:TIT2)  #=> [47, :TIT2, "Title/songname/content description", [:textenc, :text]]
    #
    def self.frame(id)
      FramesByID[id]
    end

    def self.frame_num(num)
      Frames[num]
    end
    
    #
    # Get information of field specified by _id_.
    #
    #    ID3Lib::Info.field(:text)  #=> [2, :text, "Text field"]
    #
    def self.field(id)
      FieldsByID[id]
    end

    def self.field_num(num)
      Fields[num]
    end
            
  end
  
end
