require 'time'

module Fence 
  class DataFrame
    attr_reader :rows
    attr_reader :columns

    class Column
      attr_reader :name, :type, :primary_key_index

      def initialize(name, type, primary_key_index=nil)
        @name = name
        @type = type
        @primary_key_index = primary_key_index
      end
    end

    def initialize(schemas, data)
      @columns = schemas.map do |column|
        Column.new(column[:name], column[:type], column[:primary_key_index])
      end

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
      if str == 'true' then
        true
      elsif str == 'false' then
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
