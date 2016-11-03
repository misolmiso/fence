require "minitest/autorun"
require 'fence/dataframe'

class DataFrameTest < Minitest::Test
  def setup
    @sample_schema = [
      Fence::Column.new(name: :c1, type: :string, primary_key_index: 0),
      Fence::Column.new(name: :c2, type: :int, primary_key_index: 1),
      Fence::Column.new(name: :c3, type: :float, primary_key_index: nil),
      Fence::Column.new(name: :c4, type: :bool),
      Fence::Column.new(name: :c5, type: :time)
    ]

    @sample_data = [
      ['hoge', '0', '3.14', 'true', '2016-11-02T17:20:00+09:00'],
      ['fuga', '1', '2.72', 'false', '2016-11-02']
    ]
  end

  def test_that_dataframe_is_created
    frame = Fence::DataFrame.new(:sample, @sample_schema, @sample_data)

    assert_equal 5, frame.columns.length

    assert_equal 0, frame.columns[0].primary_key_index
    assert_nil frame.columns[2].primary_key_index

    assert_equal 2, frame.rows.length
  end

  def test_that_data_is_casted
    frame = Fence::DataFrame.new(:sample, @sample_schema, @sample_data)
    row = frame.rows.first

    assert_equal 'hoge', row[0]
    assert_equal 0, row[1]
    assert_in_epsilon 3.14, row[2]
    assert_includes [true, false], row[3]
    assert_equal Time.new(2016, 11, 2, 17, 20, 00, "+09:00"), row[4]

    assert_equal Time.new(2016, 11, 2, 0, 0, 0), frame.rows.last[4]
  end

  def test_tath_empty_data_is_converted_to_nil
    nil_data = [['', '', '', '', '']]

    frame = Fence::DataFrame.new(:sample, @sample_schema, nil_data)

    row = frame.rows.first

    assert_nil row[0]
    assert_nil row[1]
    assert_nil row[2]
    assert_nil row[3]
    assert_nil row[4]
  end

  def test_unparsable_data_raise_exceptions
    assert_raises ArgumentError do
      Fence::DataFrame.new(
        :sample,
        [ Fence::Column.new(name: :column, type: :int)],
        [['hoge']]
      )
    end

    assert_raises ArgumentError do
      Fence::DataFrame.new(
        :sample,
        [ Fence::Column.new(name: :column, type: :float)],
        [['hoge']]
      )
    end

    assert_raises ArgumentError do
      Fence::DataFrame.new(
        :sample,
        [Fence::Column.new(name: :column, type: :bool)],
        [['0']]
      )
    end

    assert_raises ArgumentError do
      Fence::DataFrame.new(
        :sample,
        [Fence::Column.new(name: :column, type: :time)],
        [['piyo']]
      )
    end
  end
end
