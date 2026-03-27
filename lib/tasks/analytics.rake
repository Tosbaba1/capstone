namespace :analytics do
  desc "Print a basic Nouvelle experimentation report"
  task experiment_report: :environment do
    days = ENV.fetch("DAYS", 14).to_i
    range = days.days.ago..Time.current
    report = Analytics::ExperimentReport.new(range: range).call

    puts "Nouvelle experimentation report"
    puts "Range: #{range.begin.iso8601} to #{range.end.iso8601}"
    puts
    puts "Overview"
    report[:overview].each do |metric, value|
      puts "  #{metric}: #{value}"
    end
    puts

    report[:by_flag].each do |flag_name, rows|
      puts flag_name
      rows.each do |row|
        puts "  variant=#{row[:variant]}"
        row.except(:variant).each do |metric, value|
          puts "    #{metric}: #{value}"
        end
      end
      puts
    end
  end
end
