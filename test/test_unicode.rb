
require 'test/unit'
require 'fileutils'
require 'id3lib'


class TestWriting < Test::Unit::TestCase

  Sample = 'test/data/sample.mp3'
  Temp   = 'test/data/tmp.sample.mp3'

  def setup
    FileUtils.cp Sample, Temp
    reload!
  end

  def teardown
    FileUtils.rm Temp
  end

  def reload!(*args)
    @tag = ID3Lib::Tag.new(Temp, *args)
  end

  def test_unicode
    nihao = "\x4f\x60\x59\x7d"
    frame = {
      :id          => :COMM,
      :text        => nihao,
      :description => nihao,
      :language    => "zho",
      :textenc     => 1
    }
    @tag.comment = nil
    @tag << frame
    @tag.update!(ID3Lib::V2)
    assert_equal frame, @tag.frame(:COMM)
    reload!(ID3Lib::V2)
    assert_equal frame, @tag.frame(:COMM)
  end

  def test_unicode_invalid_data
    nonstr = 1
    @tag.reject!{ |f| f[:id] == :TIT2 }
    @tag << {:id => :TIT2, :text => nonstr, :textenc => 1}
    assert_raise(TypeError) { @tag.update!(ID3Lib::V2) }
  end

end
