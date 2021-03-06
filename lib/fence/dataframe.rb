require 'time'

module Fence 
  class Column
    attr_reader :name, :type, :primary_key_index

    def initialize(name:, type:, primary_key_index:nil)
      @name = name.to_sym
      @type = type.to_sym
      @primary_key_index = primary_key_index
    end
  end

  class DataFrame
    attr_reader :title, :rows, :columns

    def initialize(title, columns, data)
      @title = title
      @columns = columns

      @rows = data.map do |row|
        @columns.map.with_index do |column, index|
          cast(column.type, row[index])
        end
      end
    end

    private

    def cast(type, str)
      return nil if str.nil? || str.empty?

      case type
      when :int then Integer(str)
      when :float then Float(str)
      when :bool
      if str.casecmp('true') == 0 then
        true
      elsif str.casecmp('false') == 0 then
        false
      else
        raise ArgumentError.new('Boolean parse error')
      end
      when :time then Time.parse(str).getutc
      when :string then str
      else raise ArgumentError.new("Unknown type: #{type}")
      end
    end
  end
end
