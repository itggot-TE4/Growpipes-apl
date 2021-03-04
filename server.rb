require 'sinatra'
require 'serialport'
require 'sqlite3'
require 'sinatra/cross_origin'
require 'time'



# puts "How many times do you want it to blink?"
# amount = gets.chomp.to_i

# sp.write(amount)

sinatra_thread = Thread.new do
    class Server < Sinatra::Base

        class << self
            attr_reader :sinatra_thread
        end

        before do
            #content_type :json    
            headers 'Access-Control-Allow-Origin' => '*', 
                    'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']  
        end

        get '/' do
            @db = SQLite3::Database.new('db/data.db')
            
            latime = get_times_by_sensor(1).max
            response = get_sensor_data_by_time(latime)
            p response
            sleep 3
            return response.to_json
        end


        get '/exit' do
            exit!(0)
        end


        get '/sensor_data/:id' do
            @db = SQLite3::Database.new('db/data.db')
            id = params["id"].to_i

            # if id == 1
            #     response = [5,4,3,2,1]
            # elsif id == 2
            #     response = [1,2,3,4,5]
            # end
            response = @db.execute("SELECT data,date FROM daily_data where sensor_id = #{id}")

            return response.to_json
        end


        def get_times_by_sensor(sensor_id)
            new_time_list = []
            @db = SQLite3::Database.new('db/data.db') 
            dates = @db.execute("SELECT date FROM data_manager where sensor_id = #{sensor_id}")
            for date in dates do
                new_time_list << Time.parse(date[0])
            end
            return new_time_list
        end

        def get_sensor_data_by_time(time)
            
            @db = SQLite3::Database.new('db/data.db') 
            sensors = @db.execute('SELECT id FROM sensors')
            messurmentlist = @db.execute('SELECT id,type,data,date 
                                        FROM data_manager
                                        INNER JOIN sensors
                                        ON sensors.id = data_manager.sensor_id 
                                        WHERE date = ?', [time.to_s])
            

            return messurmentlist

        end


        run!
    end
end

class DataReceiver

    def initialize
        @port = SerialPort.new '/dev/tty.usbmodem1412401', 9600
        @db = SQLite3::Database.new('db/data.db') 
        @allow = true
    end

    def serve
        loop do
            
            
            input = @port.gets.strip
            input = input.split(":")

            if input[0] == "temp"   
                puts input[0] + ":sensor" + input[1] + " has the value of: " + input[2]
                time = Time.new
                time = time.to_s
                @db.execute("INSERT INTO data_manager (sensor_id,data , date) VALUES(?,?,?)", [input[1],input[2],time])
            end

            t = Time.new.strftime('%H:%M')
            if t == "23:59" && @allow
                @allow = false
                save_daily_data()
            elsif t == "0:00"
                @allow = true
            end

        end
    end

    def save_daily_data()
        
        sensors = @db.execute("SELECT id FROM sensors")
        for sensor in sensors do
            average = 0.0
            data = @db.execute("SELECT data FROM data_manager WHERE sensor_id = ?", [sensor[0]])
            
            for value in data do
                average += value[0]
            end
            average = average/data.length
            average = average.round(2)
            time = Time.new
            time = time.strftime("%d/%m/%Y")
            @db.execute("INSERT INTO daily_data (sensor_id,data, date) VALUES(?,?,?)", [sensor[0], average, time])
        end
        @db.execute("DROP TABLE IF EXISTS data_manager")
        @db.execute('CREATE TABLE data_manager(
                    "sensor_id" INTEGER NOT NULL,
                    "data" INTEGER NOT NULL,
                    "date" TEXT)')
    end


end

receiver_thread = Thread.new { DataReceiver.new.serve }


threads = [sinatra_thread, receiver_thread]
threads.each { |thread| thread.join }
