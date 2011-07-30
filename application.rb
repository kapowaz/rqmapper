# encoding: utf-8
require 'rubygems'
require 'rest-client'
require 'sinatra'
require 'data_mapper'
require 'resque'

class Page
  include DataMapper::Resource
  
  property :id,       Serial
  property :url,      String
  property :data,     Text,       :required => false
  property :pending,  Boolean,    :default => true
  
  after :create do
    Resque.enqueue self
  end
  
  def perform
    begin
      self.data    = RestClient.get self.url
      self.pending = false
      self.save
    rescue => e
      # failed to open the url ...
    end
  end
end

before do
  @page = { :title => "RQMapper", :subtitle => "Resque + DataMapper (performed by Sinatra)" }
end


get "/" do
  erb :index
end

post "/" do
  if params[:url].match /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/
    page = Page.create :url => params[:url]
    redirect "/pages/#{page.id}"
  else
    @page[:requested] = params[:url]
    @page[:error]     = "That's not a valid URL."
  end
  erb :index
end

get "/pages/:page_id.json" do |page_id|
  content_type :json
  Page.get(page_id.to_i).to_json
end

get "/pages/:page_id" do |page_id|
  @page[:page]      = Page.get(page_id.to_i)
  @page[:requested] = @page[:page].url
  erb :index
end

configure :development do
  DataMapper.setup :default, YAML.load(File.new("config/database.yml"))[:development]
  uri          = URI.parse YAML.load(File.new("config/redis.yml"))[:development][:instance]
  Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
  uri          = URI.parse YAML.load(File.new("config/redis.yml"))[:production][:instance]
  Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

DataMapper.finalize
DataMapper.auto_upgrade!