require 'enumerator'

file = ARGV.first || '/usr/local/include/id3/globals.h'

data = IO.read(file)

fields = []
frames = []
genres = []

data.scan(/ID3_ENUM\((\w+)\)\s+\{\s+(.+?)\s+\}/m) do |name, enum|
  case name
  when 'ID3_FieldID'
    id = 0
    enum.scan(/([^\s,]+)(?: = (\d+),|,)\s*\/\*\*< ([^*]+)\s+\*\//m) do |field, newid, description|
      id = newid.to_i if newid
      field.sub!('ID3FN_', '')
      field.downcase!
      fields << [id, field.to_sym, description]
      id += 1
    end
  when 'ID3_FrameID'
    id = 0
    enum.scan(/\/\* (\S+) \*\/ [^\s,]+(?: = (\d+),|,)\s*\/\*\*< ([^*]+)\s+\*\//m) do |frame, newid, description|
      id = newid.to_i if newid
      possible_fields =
      case frame.to_sym
      when :"????" : []
      when :AENC : [:owner, :data]
      when :APIC : [:textenc, :mimetype, :picturetype, :description, :data]
      when :ASPI, :COMR, :EQUA, :ETCO, :LINK,
        :MCDI, :MLLT, :OWNE, :POSS, :RBUF,
        :RVA2, :RVAD, :RVRB, :SEEK
        [:data]
      when :COMM : [:textenc, :language, :description, :text]
      when :ENCR : [:owner, :id, :data]
      when :EQU2 : [:id, :text]
      when :GEOB : [:textenc, :mimetype, :filename, :description, :data]
      when :GRID : [:owner, :id, :data]
      when :IPLS : [:textenc, :text]
      when :PRIV : [:owner, :data]
      when :PCNT : [:counter]
      when :POPM : [:email, :rating, :counter]
      when :SIGN : [:id, :data]
      when :SYLT : [:textenc, :language, :timestampformat, :contenttype, :description, :data]
      when :SYTC : [:timestampformat, :data]
      when :UFID : [:owner, :data]
      when :USER : [:textenc, :language, :text]
      when :USLT : [:textenc, :language, :description, :text]
      when :WCOM, :WCOP, :WOAF, :WOAR, :WOAS, :WORS, :WPAY, :WPUB : [:text]
      when :WXXX : [:textenc, :description, :url]
      else [:textenc, :text]
      end
      frames << [id, frame.to_sym, description, possible_fields]
      id += 1
    end
  end
end

data.scan(/(ID3_v1_genre_description).+?\{(.+?)\}/m) do |name, list|
  id = 0
  list.scan(/"(.+?)"/) do |genre|
    genres << genre.first
    id += 1
  end
end


def indent level, text
  puts ' ' * level + text
end

indent 4, "Frames = ["
frames.each do |f|
  comment = case f[1]
  when :"????" : "# Special frames"
  when :TALB : "# Text information frames"
  when :UFID : "# Special frames again"
  when :WCOM : "# URL link frames"
  end
  indent 6, comment if comment
  indent 6, f.inspect + ","
end
indent 4, "]"

indent 4, "FramesByID = {"
frames.each do |f|
  indent 6, f[1].inspect + " => Frames[" + f[0].to_s + "],"
end
indent 4, "}"

indent 4, "Fields = ["
fields.each do |f|
  indent 6, f.inspect + ","
end
indent 4, "]"

indent 4, "FieldsByID = {"
fields.each do |f|
  indent 6, f[1].inspect.ljust(16) + " => Fields[" + f[0].to_s + "],"
end
indent 4, "}"

indent 4, "Genres = ["
genres.each_slice(4) do |gs|
  indent 6, "# Winamp extensions" if gs.first == "Folk"
  indent 6, gs.map{ |g| g.inspect }.join(", ") + ","
end
indent 4, "]"
