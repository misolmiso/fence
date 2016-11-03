require 'google_drive'

module Fence
  class Spreadsheet
    def self.parse(spreadsheet, comment_sign)
      worksheets = spreadsheet.worksheets.map do |worksheet|
        Worksheet.new(worksheet, comment_sign)
      end
      
      worksheets.reject(&:is_comment_sheet?)
    end
  end

  class Worksheet
    def initialize(worksheet, comment_sign)
      @worksheet = worksheet
      @comment_sign = comment_sign
    end

    def is_comment_sheet?
      @worksheet.title.start_with?(@comment_sign)
    end

    def title
      @worksheet.title.to_sym
    end

    def columns
      rows = raw_rows
      names = rows[0].drop(1)
      types = rows[1].drop(1)
      primary_key_indexes = rows[2].drop(1)

      names.zip(types, primary_key_indexes).map do |name, type, pki|
        pki = pki.nil? || pki.empty? ? nil : Integer(pki)  
        Column.new(name: name.to_sym, type: type.to_sym, primary_key_index: pki)
      end
    end

    def rows
      raw_rows
        .drop(3)
        .reject {|row| row[0].nil? || row[0].empty? }
        .map {|row| row.drop(1)}
    end

    private

    def raw_rows
      @cache ||= @worksheet.rows
    end
  end
end
