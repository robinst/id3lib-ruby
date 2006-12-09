#!/usr/bin/ruby

require 'enumerator'
require 'pathname'


id3lib_dir = Pathname.new(ARGV.first || '/home/robin/tmp/id3lib-3.8.3')

globals_file = File.read(id3lib_dir + 'include/id3/globals.h')
field_file   = File.read(id3lib_dir + 'src/field.cpp')

def field_symbol(enum_name)
  f = enum_name[/ID3FN_(.*)/, 1].downcase
  if f == 'id'
    :identifier
  else
    f.to_sym
  end
end


field_groups   = {}
allowed_fields = {}

field_file.scan(/ID3_FieldDef (\w+)[^\{]+\{(.+?)\};/m) do |group, body|
  fields = []
  body.scan(/\{\W+(\w+)/) do |field_name, _|
    next if field_name == "ID3FN_NOFIELD"
    fields << field_name
  end
  fields.uniq!
  fields.map!{ |f| field_symbol(f) }
  field_groups[group] = fields
end

field_file.scan(/ID3_FrameDef ID3_FrameDefs[^\{]+\{(.+?)\};/m) do |body, _|
  body.each_line do |line|
    values = line.split(/\s*,\s*/)
    next unless values.size > 1
    frame = values[2].delete('"')
    group = values[5]
    next if frame.empty?
    allowed_fields[frame.to_sym] = field_groups[group]
  end
end


field_info = []
frame_info = []
genre_info = []

globals_file.scan(/ID3_ENUM\((\w+)\)\s+\{\s+(.+?)\s+\}/m) do |name, enum|
  case name
  when 'ID3_FieldID'
    id = 0
    enum.scan(/([^\s,]+)(?: = (\d+),|,)\s*\/\*\*< ([^*]+)\s+\*\//m) do |field, newid, description|
      id = newid.to_i if newid

      field = field_symbol(field)
      field_info << [id, field, description]

      id += 1
    end
  when 'ID3_FrameID'
    id = 0
    enum.scan(/\/\* (\S+) \*\/ [^\s,]+(?: = (\d+),|,)\s*\/\*\*< ([^*]+)\s+\*\//m) do |frame, newid, description|
      id = newid.to_i if newid
      frame = (frame == '????') ? :____ : frame.to_sym

      fields = allowed_fields[frame] || []

      frame_info << [id, frame, description, fields]
      id += 1
    end
  end
end

globals_file.scan(/(ID3_v1_genre_description).+?\{(.+?)\}/m) do |name, list|
  id = 0
  list.scan(/"([^"]+)"/) do |genre|
    genre_info << genre.first
    id += 1
  end
end


def indent level, text
  puts ' ' * level + text
end

indent 4, "Frames = ["
frame_info.each do |f|
  comment = case f[1]
  when :____ : "# Special frames"
  when :TALB : "# Text information frames"
  when :UFID : "# Special frames again"
  when :WCOM : "# URL link frames"
  end
  indent 6, comment if comment
  indent 6, f.inspect + ","
end
indent 4, "]"

indent 4, "FramesByID = {"
frame_info.each do |f|
  indent 6, f[1].inspect + " => Frames[" + f[0].to_s + "],"
end
indent 4, "}"

indent 4, "Fields = ["
field_info.each do |f|
  indent 6, f.inspect + ","
end
indent 4, "]"

indent 4, "FieldsByID = {"
field_info.each do |f|
  indent 6, f[1].inspect.ljust(16) + " => Fields[" + f[0].to_s + "],"
end
indent 4, "}"

indent 4, "Genres = ["
genre_info.each_slice(4) do |gs|
  indent 6, "# Winamp extensions" if gs.first == "Folk"
  indent 6, gs.map{ |g| g.inspect }.join(", ") + ","
end
indent 4, "]"
