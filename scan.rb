#!/usr/bin/ruby

##require 'rubygems'
require 'sinatra'

SCANWEB_HOME = File.dirname(__FILE__)
SCRIPT_FILE = SCANWEB_HOME + "/scan.sh"
OUTPUT_DIR = '/export/work/scan'
#OUTPUT_DIR = 'c:/temp/scan'

def create_path_table(basename)
  { 
    :pdf_path => "#{OUTPUT_DIR}/#{basename}.pdf",
    :log_path => "#{OUTPUT_DIR}/#{basename}.log",
    :thumbs_path => "#{OUTPUT_DIR}/#{basename}_thumbs.zip",
  }
end

# too ad-hoc implementation. sleep 1 if it conflicts...
def create_basename
  time_str = Time.now.strftime("%Y%m%d-%H%M%S")
  
  basename = "scan-#{time_str}"
  
  path_table = create_path_table(basename)
  if File.exists?(path_table[:pdf_path]) ||
     File.exists?(path_table[:log_path]) ||
     File.exists?(path_table[:thumbs_path]) then
     sleep 1
     return create_basename()
  end
  
  return basename
end


helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  alias_method :u, :escape
end

get '/' do
  erb :index
end

get '/invalid' do
  return 'パラメータの指定が不正です。'
end

post '/scan' do
  source = params[:source]
  mode = params[:mode]
  resolution = params[:resolution]

  unless source =~ /^[a-zA-Z ]+$/ &&
     mode =~ /^[a-zA-Z]+$/ &&
     resolution =~ /^[0-9]+$/ then
     redirect '/invalid'
  end

  basename = create_basename()
  path_table = create_path_table(basename)
  
  ##File.open(path_table[:log_path], "w") do |fp|
  ##  fp.puts("TEXT!")
  ##end
  system(%Q(#{SCRIPT_FILE} "#{path_table[:pdf_path]}" "#{path_table[:log_path]}" "#{path_table[:thumbs_path]}" "#{source}" "#{mode}" "#{resolution}"))
  
  # If output exists, treat as scanning is succeeded.
  if File.exists?(path_table[:pdf_path]) then
  ##if true
    @success = true
    @message = 'スキャンが完了しました。'
    @basename = basename
  else
    @success = false
    @message = 'スキャンに失敗しました。'
    if File.exists?(path_table[:log_path]) then
      @log_text = File.read(path_table[:log_path])
    else
      @log_text = 'ログファイルが見つかりません。'
    end
  end
  
  erb :scan
end

get '/image/:basename' do
  basename = params[:basename]
  
  unless basename =~ /^[a-zA-Z0-9]+$/ then
    redirect '/invalid'
  end
  
  return basename
end

