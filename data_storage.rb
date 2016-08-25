class DataStorage
  attr_accessor :data, :csv
  attr_reader :file

  def initialize
    @file = "./#{Time.now.to_i}.csv"
    @data = []
    open_csv
  end

  def open_csv
    if exists?
      CSV.read(@file, headers: true)
    else
      CSV.open(@file, 'w') do |csv|
        # csv << %{Name Location Image Link}.split # add headers
      end
      CSV.read(@file, headers: true)
    end
  end

  def save_data(data)
    if data.empty?
      puts "Nothing to save. Exiting"
      abort
    else
      @data = data.to_a
      @data.each do |row|
        CSV.open(@file, 'a+') do |csv|
          csv << row.to_a
        end
      end
    end
  end

  def exists?
    File.exist?(@file)
  end
end
