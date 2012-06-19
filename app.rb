#!/usr/bin/ruby

require 'rubygems'
require 'sinatra'

get '/' do
  erb :scanweb
end

post '/doscan' do
  sleep 10
  erb :doscan
end