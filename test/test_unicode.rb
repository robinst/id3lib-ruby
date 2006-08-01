
require 'test/unit'
require 'fileutils'
require 'id3lib'


class TestUnicode < Test::Unit::TestCase

  Sample = 'test/data/sample.mp3'
  Temp   = 'test/data/tmp.sample.mp3'

  def setup
    FileUtils.cp Sample, Temp
    @tag = ID3Lib::Tag.new(Temp)
  end

  def teardown
    FileUtils.rm Temp
  end

  # Failing because of id3lib.
  def dont_test_UTF16BE
    do_unicode_test :text => "\x4f\x60\x59\x7d", :textenc => 2
  end

  def test_UTF16LE
    do_unicode_test :text => "\x60\x4f\x7d\x59", :textenc => 1
  end

  # Failing because of id3lib.
  def dont_test_UTF16BE_with_BOM
    do_unicode_test :text => "\xfe\xff\x4f\x60\x59\x7d", :textenc => 1
  end

  def test_UTF16LE_with_BOM
    do_unicode_test :text => "\xff\xfe\x60\x4f\x7d\x59", :textenc => 1
  end

  # Failing because of id3lib.
  def dont_test_UTF16BE_above_127
    do_unicode_test :text => "\xfe\xffC\346", :textenc => 1
  end

  def test_UTF16LE_above_127
    do_unicode_test :text => "\xe6C", :textenc => 1
  end

  def test_UTF16LE_above_127_with_BOM
    do_unicode_test :text => "\xff\xfe\xe6C", :textenc => 1
  end

  def test_reading
    @tag = ID3Lib::Tag.new('test/data/unicode.mp3', ID3Lib::V2)
    assert_equal "\x4f\x60\x59\x7d", @tag.title
  end

  def test_invalid_data
    nonstr = 1
    @tag.reject!{ |f| f[:id] == :TIT2 }
    @tag << {:id => :TIT2, :text => nonstr, :textenc => 1}
    assert_raise(TypeError) { @tag.update!(ID3Lib::V2) }
  end

  def do_unicode_test(opts)
    frame = {:id => :TIT2}
    frame.update(opts)
    @tag.title = nil
    @tag << frame
    @tag.update!(ID3Lib::V2)
    assert_equal frame, @tag.frame(:TIT2)
    @tag = ID3Lib::Tag.new(Temp, ID3Lib::V2)
    assert_equal frame, @tag.frame(:TIT2)
  end

end
