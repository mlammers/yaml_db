namespace :db do
  desc "Dump schema and data to db/schema.rb and db/data.yml"
  task(:dump => [ "db:schema:dump", "db:data_seedomatic:dump" ])

  desc "Load schema and data from db/schema.rb and db/data.yml"
  task(:load => [ "db:schema:load", "db:data_seedomatic:load" ])

  namespace :data_seedomatic do
    desc "Dump contents of database to db/data.extension (defaults to yaml)"
    task :dump => :environment do
      SeedomaticYamlDb::RakeTasks.data_dump_task
    end

    desc "Dump contents of database to curr_dir_name/tablename.extension (defaults to yaml)"
    task :dump_dir, [:table_name] => :environment do |t, args|
      SeedomaticYamlDb::RakeTasks.data_dump_dir_task(args[:table_name])
    end

    desc "Load contents of db/data.extension (defaults to yaml) into database"
    task :load => :environment do
      SeedomaticYamlDb::RakeTasks.data_load_task
    end

    desc "Load contents of db/data_dir into database"
    task :load_dir  => :environment do
      SeedomaticYamlDb::RakeTasks.data_load_dir_task
    end
  end
end
