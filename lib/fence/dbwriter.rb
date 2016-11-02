require 'sequel'

module Fence
  class DBWriter
    attr_reader :dbfile_name

    def self.open(dbfile_name, &block)
      begin
        writer = DBWriter.new(dbfile_name)
        block.call(writer)
      ensure
        writer.close
      end
    end

    def initialize(dbfile_name)
      @dbfile_name = dbfile_name
      @db = Sequel.sqlite(dbfile_name)
    end

    def write_data(title, data)
      schemas = data.columns.map do |schema|
        {name:schema.name, type:convert_sequel_type(schema.type)}
      end

      @db.create_table(title) do
        schemas.each do |schema|
          column schema[:name], schema[:type]
        end

        pks =
          data.columns
          .select(&:primary_key_index)
          .sort_by(&:primary_key_index)
          .map(&:name)

        primary_key pks
      end

      @db[title].import(data.columns.map(&:name), data.rows)
    end

    def close
      @db.disconnect
    end

    private

    def convert_sequel_type(data_type)
      case data_type
      when :int then :int
      when :float then :float
      when :bool then :bool
      when :string then :string
      when :time then :time
      else raise ArgumentError.new("Unknown type: #{type}")
      end
    end
  end
end
