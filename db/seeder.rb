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
            "data_id" INTEGER NOT NULL,
            "sensor_id" INTEGER NOT NULL,
            "data" INTEGER NOT NULL,
            "date" TEXT,
            "time" TEXT,
            PRIMARY KEY ("data_id" AUTOINCREMENT))';



        db.execute('INSERT INTO sensors (id,type) VALUES(?,?)',[1,"th"])
        db.execute('INSERT INTO sensors (id,type) VALUES(?,?)',[2,"th"])

        db.execute('INSERT INTO daily_data (sensor_id, data, date) VALUES(?,?,?)',[1, 23, "23/4/2020"])
        db.execute('INSERT INTO daily_data (sensor_id, data, date) VALUES(?,?,?)',[1, 27, "24/4/2020"])
        db.execute('INSERT INTO daily_data (sensor_id, data, date) VALUES(?,?,?)',[1, 32, "25/4/2020"])
        db.execute('INSERT INTO daily_data (sensor_id, data, date) VALUES(?,?,?)',[2, 42, "23/4/2020"])
        db.execute('INSERT INTO daily_data (sensor_id, data, date) VALUES(?,?,?)',[2, 22, "24/4/2020"])
        db.execute('INSERT INTO daily_data (sensor_id, data, date) VALUES(?,?,?)',[2, 13, "25/4/2020"])
    end
end


