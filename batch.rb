# -*- coding:utf-8 -*-
# How to use
#
# $ bundle ex ruby builder.rb -u username -p password -f csv file name

require 'bundler/setup'

require 'readline'
require 'open-uri'
require 'optparse'
require 'csv'
require 'geocoder'
require 'faraday'
require 'json'

PREFECTURE = "東京都"
OPTION = {}
GTT_URL = 'http://beta.shirasete.jp/'
PROJECT_ID = 22
CATEGORY_URL = GTT_URL + 'projects/22/issue_categories.json'

conn = Faraday::Connection.new(:url => GTT_URL) do |builder|
  builder.use Faraday::Request::UrlEncoded  # リクエストパラメータを URL エンコードする
  builder.use Faraday::Response::Logger     # リクエストを標準出力に出力する
  builder.use Faraday::Adapter::NetHttp     # Net/HTTP をアダプターに使う
end

args = {}
OptionParser.new do |parser|
  parser.on('-u', '--user shirasete.jp user') { |v| args[:user] = v }
  parser.on('-p', '--password shirasete.jp password') { |v| args[:password] = v }
  parser.on('-f', '--file csv file path') { |v| args[:file] = v }
  parser.parse!(ARGV)
end

# ガードしとくかな...
raise "ユーザー名設定してー＾ー＾ 'batch.rb -u ユーザー名' " unless args[:user]
raise "パスワード設定してー＾ー＾# 'batch.rb -u パスワード' " unless args[:password]
raise "ファイル名指定してーーーー！ 'batch.rb -f ファイル名' " unless args[:file]

user = args[:user].to_s
password = args[:password].to_s

# get categories
categories_json = open(CATEGORY_URL, {:http_basic_authentication => [user, password]}).read
issue_categories = JSON.parser.new(categories_json).parse['issue_categories']
categories = {}
issue_categories.each_with_index { |c, idx| categories[idx+1] = c["name"] }

puts 'カテゴリー番号を指定してね♥'
line_count = 0
categories.map do |k, v|
  print "No.#{k}: #{v}".ljust(15, ' ') 
  line_count += 1
  if line_count == 3
    puts
    line_count = 0
  end
end

puts
category_no = Readline.readline("No.? > ", true)
final_category_name = categories[category_no.to_i].to_s

answer = Readline.readline("#{final_category_name} で入力を始めます (y/n) ", true)
if answer.downcase != "y"
  puts "終了します"
  exit
end

conn.basic_auth user, password

path = File.absolute_path(args[:file].to_s)

# csv format 
# 投票区,掲示場番号,住所,場所の名称（建物名など）,設置位置
number_tmp = ""
CSV.foreach(path, :headers => true ) do |row|
  number = row[0].to_s
  number_tmp = number if number_tmp != number and number != ""
  board_name = row[1].to_s
  address = PREFECTURE + final_category_name + row[2].to_s
  subject = final_category_name + number_tmp + '-' + board_name + " " + row[3].to_s
  lat, lng = Geocoder.coordinates(address)
  geometry = {:type => 'Point', :coordinates => [lng, lat]}.to_json
  p geometry
  conn.post do |req|
    req.url '/issues.json'
    req.headers['Content-Type'] = 'application/json'
    req.body = {
      :issue => {
        :subject => subject, 
        :description => address,
        :geometry => geometry, 
        :project_id => PROJECT_ID
      }
    }.to_json
  end 
  puts
end

