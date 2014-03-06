# -*- coding:utf-8 -*-
# How to use
#
# $ bundle ex ruby category.rb -u username -p password -f csv file name

require 'bundler/setup'

require 'optparse'
require 'csv'
require 'faraday'
require 'json'


OPTION = {}
GTT_URL = 'http://beta.shirasete.jp/'
PROJECT_ID = 32

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

conn.basic_auth user, password

path = File.absolute_path(args[:file].to_s)

# csv format 
CSV.foreach(path, :headers => false ) do |row|
  puts row[0].to_s
  conn.post do |req|
    req.url "/projects/#{PROJECT_ID}/issue_categories.json"
    req.headers['Content-Type'] = 'application/json'
    req.body = {
      :issue_category => {
        :name => row[0].to_s
      }
    }.to_json
  end 
  puts
end
