class FakeSensor

    def initialize(id, type, db)

        @sensor_id = id
        @sensor_type = type
        @db = db

    end


    def read_sensor()

        input = ["temp", @sensor_id.to_s, rand(20..25).to_s]
        
        if input[0] == "temp"   
            puts input[0] + ":sensor" + input[1] + " has the value of: " + input[2]
            
            if input[2].to_i >= 26
                warning_mailer('tintin.wihlborg@elev.ga.ntig.se', input[0] + ': Warning', input[0] + ":sensor" + input[1] + " Has a value of: " + input[2])
            end
            time = Time.new
            date = time.strftime("%d/%m/%Y")
            time = time.strftime("%H:%M:%S")
            @db.execute("INSERT INTO data_manager (sensor_id,data , date, time) VALUES(?,?,?,?)", [input[1],input[2],date,time])
        end

    end


end