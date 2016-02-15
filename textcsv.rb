require "csv"
a = [12,2,13,4,5]
CSV.open("sample.csv", "a+") do |s|
  s << a
end