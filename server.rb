require 'sinatra'
require 'serialport'
require 'sqlite3'
require 'sinatra/cross_origin'
require 'time'
require 'mail'
require_relative './credentials'
require_relative 'sensor_classes/Sensor'
require_relative 'sensor_classes/FakeSensor'


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
            
            response = get_latest_record_of_each_sensor()
            sleep 3
            return response.to_json
        end


        get '/exit' do
            exit!(0)
        end


        get '/sensor_data/:id' do
            @db = SQLite3::Database.new('db/data.db')
            id = params["id"].to_i

        
            response = @db.execute("SELECT data,date FROM daily_data where sensor_id = #{id}")

            return response.to_json
        end


        def get_latest_record_of_each_sensor()

            @db = SQLite3::Database.new('db/data.db')
            sensors = @db.execute('SELECT * FROM sensors')
            sensor_list = []
            for sensor in sensors do 
                sensor_value = @db.execute('SELECT id,type,data,date,time
                                            FROM data_manager
                                            INNER JOIN sensors
                                            ON sensors.id = data_manager.sensor_id
                                            WHERE sensor_id = ?
                                            ORDER BY data_id DESC LIMIT 1', [sensor[0]])
                sensor_list << sensor_value[0]
            end
            return sensor_list
        end


        # def get_times_by_sensor(sensor_id)
        #     new_time_list = []
        #     @db = SQLite3::Database.new('db/data.db') 
        #     dates = @db.execute("SELECT date FROM data_manager where sensor_id = #{sensor_id}")
        #     for date in dates do
        #         new_time_list << Time.parse(date[0])
        #     end
        #     return new_time_list
        # end

        # def get_sensor_data_by_time(time)
            
        #     @db = SQLite3::Database.new('db/data.db') 
        #     sensors = @db.execute('SELECT id FROM sensors')
        #     messurmentlist = @db.execute('SELECT id,type,data,date 
        #                                 FROM data_manager
        #                                 INNER JOIN sensors
        #                                 ON sensors.id = data_manager.sensor_id 
        #                                 WHERE date = ?', [time.to_s])
            

        #     return messurmentlist

        # end


        run!
    end
end

class DataReceiver

    def initialize()

        @db = SQLite3::Database.new('db/data.db') 
        @allow = true


        if serial_checker()
            @port = SerialPort.new '/dev/tty.usbmodem1412401', 9600
            @port.read_timeout = 3000
            # @sensor0 = Sensor.new(0,"ph", @port, @db, ard_id)
            @sensor1 = Sensor.new(1,"th", @port, @db, 0)
            @sensor2 = Sensor.new(2,"th", @port, @db, 1)
        else
          
            @sensor1 = FakeSensor.new(1,"th", @db)
            @sensor2 = FakeSensor.new(2,"th", @db)
            
        end

        
      
    end

    def serve
        loop do 
            sleep 3

            # fetch_temp(1)
            # fetch_temp(2)
            
            

            @sensor1.read_sensor()
            @sensor2.read_sensor()
            

            t = Time.new.strftime('%H:%M')
              if t == "23:59" && @allow
                @allow = false
                save_daily_data()
            elsif t == "0:00"
                @allow = true
            end

        end
    end

    def serial_checker()

        begin
            port_to_check = SerialPort.new '/dev/tty.usbmodem1412401', 9600
            return true
        rescue => exception
            return false
        end

    end

    # def fetch_temp(id)
    #     @port.write("temp#{id}/")
    #     input = @port.gets.strip
    #     input = input.split(":")
        
    #     if input[0] == "temp"   
    #         puts input[0] + ":sensor" + input[1] + " has the value of: " + input[2]
    #         if input[2].to_i >= 26
    #             warning_mailer('tintin.wihlborg@elev.ga.ntig.se', input[0] + ': Warning', input[0] + ":sensor" + input[1] + " Has a value of: " + input[2])
    #         end
    #         time = Time.new
    #         date = time.strftime("%d/%m/%Y")
    #         time = time.strftime("%H:%M:%S")
    #         @db.execute("INSERT INTO data_manager (sensor_id,data , date, time) VALUES(?,?,?,?)", [input[1],input[2],date,time])
    #     end
    # end

    def save_daily_data()
        
        sensors = @db.execute("SELECT id FROM sensors")
        for sensor in sensors do
            average = 0.0
            data = @db.execute("SELECT data FROM data_manager WHERE sensor_id = ? AND date = ?", [sensor[0], Time.new.strftime("%d/%m/%Y")])

            for value in data do
                average += value[0]
            end
            average = average/data.length
            average = average.round(2)
            time = Time.new
            time = time.strftime("%d/%m/%Y")
            @db.execute("INSERT INTO daily_data (sensor_id,data, date) VALUES(?,?,?)", [sensor[0], average, time])
        end
    end

    # def warning_mailer(recipient,subjects,body_message)

        
    #     Mail.defaults do
    #         delivery_method :smtp, @@credentials
    #     end

    #     Mail.deliver do
    #                 to recipient
    #             from 'grunka.test@gmail.com'
    #         subject subjects
    #             body body_message
    #     end

    # end

end

receiver_thread = Thread.new { DataReceiver.new.serve }


threads = [sinatra_thread, receiver_thread]
threads.each { |thread| thread.join }
