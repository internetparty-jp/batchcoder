#
# How to use
#
# $ ruby builder.rb USERNAME PASSWORD CSVFILEPATH
#

require 'rubygems'
require 'bundler/setup'

require 'csv'
require 'geocoder'
require 'faraday'

GTT_URL = 'http://beta.shirasete.jp/'
PROJECT_ID = 22

conn = Faraday::Connection.new(:url => GTT_URL) do |builder|
  builder.use Faraday::Request::UrlEncoded  # リクエストパラメータを URL エンコードする
  builder.use Faraday::Response::Logger     # リクエストを標準出力に出力する
  builder.use Faraday::Adapter::NetHttp     # Net/HTTP をアダプターに使う
end

user = ARGV[0]
password = ARGV[1]
conn.basic_auth user, password

path = File.absolute_path(ARGV[2])

CSV.foreach(path) do |row|
  p row
  number = row[0]
  name = row[1]
  address = row[2]
  lat, lng = Geocoder.coordinates(address)
  geometry = {:type => 'Point', :coordinates => [lng, lat]}.to_json
  p geometry
  conn.post do |req|
    req.url '/issues.json'
    req.headers['Content-Type'] = 'application/json'
    req.body = {:issue => {:subject => "#{number} #{name} #{address}", :geometry => geometry, :project_id => PROJECT_ID}}.to_json
  end 
  puts
end

