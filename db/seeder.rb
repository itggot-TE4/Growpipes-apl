require 'sqlite3'

class Seeder

    def self.seed!

        db = SQLite3::Database.new 'db/data.db'
        db.execute 'DROP TABLE IF EXISTS sensors'
        db.execute 'DROP TABLE IF EXISTS daily_data'
        db.execute 'DROP TABLE IF EXISTS data_manager'
        db.execute 'CREATE TABLE sensors(
            "id" INTEGER NOT NULL UNIQUE,
            "type" STRING NOT NULL, 
            PRIMARY KEY("id"))';
        db.execute 'CREATE TABLE daily_data(
            "sensor_id" INTEGER NOT NULL,
            "data" INTEGER NOT NULL,
            "date" TEXT)';
        db.execute 'CREATE TABLE data_manager(
            "sensor_id" INTEGER NOT NULL,
            "data" INTEGER NOT NULL,
            "date" TEXT)';
    end
end


