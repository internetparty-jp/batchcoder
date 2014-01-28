# -*- coding:utf-8 -*-
# How to use
#
# $ ruby builder.rb USERNAME PASSWORD CSVFILEPATH
#

require 'rubygems'
require 'bundler/setup'

require 'optparse'
require 'csv'
require 'geocoder'
require 'faraday'

OPTION = {}
GTT_URL = 'http://beta.shirasete.jp/'
PROJECT_ID = 22

conn = Faraday::Connection.new(:url => GTT_URL) do |builder|
  builder.use Faraday::Request::UrlEncoded  # リクエストパラメータを URL エンコードする
  builder.use Faraday::Response::Logger     # リクエストを標準出力に出力する
  builder.use Faraday::Adapter::NetHttp     # Net/HTTP をアダプターに使う
end

args = {}
OptionParser.new do |parser|
  parser.on('-a', '--address-prefix Address prefix') { |v| args[:address_prefix] = v}
  parser.on('-u', '--user shirasete.jp user') { |v| args[:user] = v }
  parser.on('-p', '--password shirasete.jp password') { |v| args[:password] = v }
  parser.on('-f', '--file csv file path') { |v| args[:file] = v }
  parser.parse!(ARGV)
end

# ガードしとくかな...
raise "住所がないですよ 'batch.rb -a 住所' で入力。" unless args[:address_prefix]
raise "ユーザー名設定してー＾ー＾ 'batch.rb -u ユーザー名' " unless args[:user]
raise "パスワード設定してー＾ー＾# 'batch.rb -u パスワード' " unless args[:password]
raise "ファイル名指定してーーーー！ 'batch.rb -f ファイル名' " unless args[:file]

user = args[:user].to_s
password = args[:password].to_s
conn.basic_auth user, password

path = File.absolute_path(args[:file].to_s)

# csv format 
# 投票区,掲示場番号,住所,場所の名称（建物名など）,設置位置
CSV.foreach(path, :headers => true ) do |row|
  p row
  number = row[0].to_s
  board_name = row[1].to_s
  address = row[2].to_s
  subject = "掲示板番号: #{board_name} " + args[:address_prefix] + row[3].to_s
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

