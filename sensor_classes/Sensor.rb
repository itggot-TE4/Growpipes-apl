require_relative '../credentials'



class Sensor

    def initialize(id, type, port, db, arduino_id)
        @sensor_id = id
        @sensor_type = type
        @port = port
        @db = db
        @arduino_id = arduino_id
    end



    def test()
        puts @sensor_id
        puts @sensor_type
    end

    def read_sensor()

        @port.write("readsensor;dallas;#{@arduino_id};potatis/")

        input = @port.gets.strip
        input = input.split(":")
        
        if input[0] == "temp"   
            puts input[0] + ":sensor" + input[1] + " has the value of: " + input[2]
            puts @sensor_id
            if input[2].to_i >= 26
                warning_mailer('tintin.wihlborg@elev.ga.ntig.se', input[0] + ': Warning', input[0] + ":sensor" + input[1] + " Has a value of: " + input[2])
            end
            time = Time.new
            date = time.strftime("%d/%m/%Y")
            time = time.strftime("%H:%M:%S")
            @db.execute("INSERT INTO data_manager (sensor_id,data , date, time) VALUES(?,?,?,?)", [input[1],input[2],date,time])
        end
    end


    def warning_mailer(recipient,subjects,body_message)

        
        Mail.defaults do
            delivery_method :smtp, @@credentials
        end

        Mail.deliver do
                    to recipient
                from 'grunka.test@gmail.com'
            subject subjects
                body body_message
        end

    end

end