require 'fence/dbwriter'
require 'tempfile'


class DBWriterTest < Minitest::Test
  def setup
    @sample_schema = [
      {name: :c1, type: :string, primary_key_index: 0},
      {name: :c2, type: :int, primary_key_index: 1},
      {name: :c3, type: :float, primary_key_index: nil},
      {name: :c4, type: :bool},
      {name: :c5, type: :time}
    ]

    @sample_data = [
      ['hoge', '0', '3.14', 'true', '2016-11-02T17:20:00+09:00'],
      ['fuga', '1', '2.72', 'false', '2016-11-02T17:20:00+09:00']
    ]

    @sample_frame = Fence::DataFrame.new(@sample_schema, @sample_data)

    tempfile = Tempfile.create(['fence-test', '.db'])
    @tempfile_path = tempfile.path
    tempfile.close
  end

  def teardown
    if File.exist?(@tempfile_path)
      File.delete(@tempfile_path)
    end
  end

  def test_dbfile_is_written
    Fence::DBWriter.open(@tempfile_path) do |writer|
      writer.write_data(:test, @sample_frame)
    end

    assert File.exist?(@tempfile_path)

    Sequel.sqlite(@tempfile_path) do |db|
      row = db[:test][c1: 'fuga', c2: 1]

      assert_in_epsilon 2.72, row[:c3]
      assert_equal Time.new(2016, 11, 2, 17, 20, 00, "+09:00"), row[:c5]
    end
  end

  def test_primary_key_is_set
    Fence::DBWriter.open(@tempfile_path) do |writer|
      writer.write_data(:test, @sample_frame)
    end

    Sequel.sqlite(@tempfile_path) do |db|
      schema = db.schema(:test)

      name, column = schema.find {|row| row.first == :c1}
      assert column[:primary_key]

      name, column = schema.find {|row| row.first == :c3}
      assert ! column[:primary_key]
    end
  end
end
