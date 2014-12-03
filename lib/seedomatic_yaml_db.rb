require 'rubygems'
require 'yaml'
require 'active_record'
require 'serialization_helper'
require 'active_support/core_ext/kernel/reporting'
require 'rails/railtie'
require 'seedomatic_yaml_db/rake_tasks'
require 'seedomatic_yaml_db/version'

module SeedomaticYamlDb
  module Helper
    def self.loader
      SeedomaticYamlDb::Load
    end

    def self.dumper
      SeedomaticYamlDb::Dump
    end

    def self.extension
      "yml"
    end
  end


  module Utils
    def self.chunk_records(records)
      yaml = [ records ].to_yaml
      yaml.sub!(/---\s\n|---\n/, '')
      yaml.sub!('- - -', '  - -')
      yaml
    end

    def self.map_attributes(record_hash, columns)
      mapped_attributes = {}
      columns.map {|key| mapped_attributes.merge!(key => record_hash[key])}
      p mapped_attributes
      mapped_attributes
    end

    def self.prepare_records(records, column_names)
      records.each_with_index do |record, index|
        #each record will be a hash at this point
        p record
        p index
        records[index] = map_attributes(record, column_names)
      end
    end

  end

  class Dump < SerializationHelper::Dump

    def self.dump_table_columns(io, table)
#      io.write("\n")
#      io.write({ table => { 'columns' => table_column_names(table) } }.to_yaml)
    end

    def self.dump_table_records(io, table)
      table_record_header(io)

      column_names = table_column_names(table)

      each_table_page(table) do |records|
        rows = SeedomaticYamlDb::Utlis.prepare_records(records.to_a, column_names)
        io.write(SeedomaticYamlDb::Utils.chunk_records(rows))
      end
    end

    def self.table_record_header(io)
      io.write("  items: \n")
    end

  end

  class Load < SerializationHelper::Load
    def self.load_documents(io, truncate = true)
        YAML.load_documents(io) do |ydoc|
          ydoc.keys.each do |table_name|
            next if ydoc[table_name].nil?
            load_table(table_name, ydoc[table_name], truncate)
          end
        end
    end
  end

  class Railtie < Rails::Railtie
    rake_tasks do
      load File.expand_path('../tasks/seedomatic_yaml_db_tasks.rake',
__FILE__)
    end
  end

end
