require "minitest/autorun"
require 'minitest/mock'
require 'fence'

class WorksheetTest < Minitest::Test
  FakeWorksheet = Struct.new(:title, :rows)
  FakeSpreadsheet = Struct.new(:worksheets)
  def setup
    @sample_cells = [
      %W(name   c1      c2  c3      c4      c5),
      %W(type   string  int float   bool    time),
      %W(pk     0       1   #{}     #{}     #{}),
      %W(x      hoge    3   2.5     true    2016-11-02T17:20:00),
      %W(x      fuga    5   3.1     #{}     2016-11-02T17:10:00),
      %W(#{}    piyo    7   2.9     true    2016-11-02)
    ]
  end

  def test_that_rows_is_coverted_to_dataframe
    ws1 = FakeWorksheet.new('sample', @sample_cells)
    ws2 = FakeWorksheet.new('#sample', @sample_cells)

    ss = FakeSpreadsheet.new([ws1, ws2])

    worksheets = Fence::Spreadsheet.parse(ss, '#')

    assert_equal 1, worksheets.size

    worksheet = worksheets.first

    assert_equal :sample, worksheet.title

    rows = worksheet.rows
    columns = worksheet.columns
    
    assert_equal 2, rows.size
    assert_equal 5, columns.size

    row = rows.last
    assert_equal 'fuga', row[0]
    assert_equal '3.1', row[2]
    assert row[3].empty?
  end
end
