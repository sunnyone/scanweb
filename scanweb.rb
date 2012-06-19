#!/usr/bin/ruby

##require 'rubygems'
require 'sinatra'
require 'zip/zipfilesystem'

## Configuration
SCANWEB_HOME = File.dirname(__FILE__)
SCRIPT_FILE = SCANWEB_HOME + "/scan.sh"
OUTPUT_DIR = '/export/work/scan'
#OUTPUT_DIR = 'c:/temp/scan'
#OUTPUT_DIR='/tmp/scan'

set :port, 10080

## 
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
  ##basename = "base"
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
  else
    @success = false
    @message = 'スキャンに失敗しました。'
  end

  @basename = basename
  if File.exists?(path_table[:log_path]) then
    @log_text = File.read(path_table[:log_path])
  else
    @log_text = 'ログファイルが見つかりません。'
  end
  
  @thumb_count = get_thumb_count(path_table[:thumbs_path])
  
  erb :scan
end

def get_thumb_count(thumbs_path)
  filelist = get_zip_filelist(thumbs_path)
  
  count = 0
  (1..9999).each do |i|
    unless filelist.member?("thumb%04d.jpg" % i)
       break
    end
    
    count = i
  end

  count
end

def get_zip_filelist(zip_filename)
  filelist = []
  
  Zip::ZipInputStream.open(zip_filename) do |stream|
    while entry = stream.get_next_entry()
      filelist << entry.name
    end
  end
  
  filelist
end

def get_zip_data(zip_filename, entry_filename)
  data = nil
  
  Zip::ZipInputStream.open(zip_filename) do |stream|
    while entry = stream.get_next_entry()
      next unless entry_filename == entry.name
    
      data = stream.read()
    end
  end

  data
end

get '/image/:basename/:number' do
  basename = params[:basename]
  number = params[:number]
  
  unless basename =~ /^[a-zA-Z0-9]+$/ &&
              number =~ /^[0-9]+$/ then
    redirect '/invalid'
  end
  
  path_table = create_path_table(basename)
  unless File.exists?(path_table[:thumbs_path]) then
     return "サムネイルファイルが見つかりません"
  end
  
  image_filename = "thumb%04d.jpg" % number
  image_bytes = get_zip_data(path_table[:thumbs_path], image_filename)

  unless image_bytes then
    return "指定番号がありません"
  end
  
  content_type 'image/jpeg'
  image_bytes
end

