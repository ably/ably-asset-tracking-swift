require 'time'
require 'csv'

lines = File.read("subscriber-logs.txt").lines

Entry = Struct.new(:happened_at, :distance)

line_marker = " info Distance from animatedLocation to lastReceivedLocation is "
entries = lines.map do |line|
  if line =~ /^(.*)#{Regexp.escape(line_marker)}(.*)\. $/
    Entry.new(Time.parse($1), $2.to_f)
  end
end.compact

CSV.open("subscriber-logs.csv", "w") do |csv|
  csv << ["Seconds elapsed", "Metres from animatedLocation to lastReceivedLocation"]
  entries.each do |entry|
    csv << [entry.happened_at - entries[0].happened_at, entry.distance]
  end
end
