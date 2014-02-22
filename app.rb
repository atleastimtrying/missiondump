require 'sinatra'
require 'json'
require 'uri'
require 'pry'
require 'pg'
require 'data_mapper'
require 'dm-serializer'
require 'sanitize'

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == [ENV['UN'], ENV['PWD']]
  end
end

DataMapper.setup(:default, ENV['HEROKU_POSTGRESQL_WHITE_URL'] || ENV['LOCAL_URL'])

class Company
  include DataMapper::Resource
  property :id, Serial 
  property :company_name, String
  property :mission_statement, Text
  property :mission_statement_proof, Text
  property :mission_statement_investigator, String
end

class NewsSource
  include DataMapper::Resource
  property :id, Serial
  property :company_id, Integer
  property :name, String
  property :headline, String
  property :polarity, Float  
  belongs_to :company
end  

DataMapper.finalize
DataMapper.auto_upgrade!

get '/' do
  send_file 'sample.html'
end

get '/script.js' do
  send_file 'script.js'
end

get '/style.css' do
  send_file 'style.css'
end

# get '/company/new' do
#   #protected!
#   send_file 'new_company.html'
# end

# post '/company' do
#   #protected!
#   Company.create({
#     company_name: Sanitize.clean(params[:company_name]),
#     mission_statement: Sanitize.clean(params[:mission_statement]),
#     mission_statement_proof: Sanitize.clean(params[:mission_statement_proof]),
#     mission_statement_investigator: Sanitize.clean(params[:mission_statement_investigator])
#   })

#   redirect to('/')
# end

# get '/companies.json' do
#   Company.all.to_json
# end

get '/sample.json' do
  [{
    company_name: 'Coca-Cola' || params[:company_name],
    mission_statement: 'Coca-Cola is awesome x approx 150 words',
    mission_statement_proof: 'Coca cola IS awesome for realz',
    mission_statement_investigator: 'John Smith - WHO',
    news_sources: [
      { 
        name: "Al Jazeera",
        headline: 'Coke killed 15 people today',
        polarity: 0.1
      },
      {
        name: 'New York Times',
        headline: 'Coke have found a cure for cancer',
        polarity: 0.9
      }
    ]
  },
  {
    company_name: 'Coca-Cola' || params[:company_name],
    mission_statement: 'Coca-Cola is awesome x approx 150 words',
    mission_statement_proof: 'Coca cola IS awesome for realz',
    mission_statement_investigator: 'John Smith - WHO',
    news_sources: [
      { 
        name: "Al Jazeera",
        headline: 'Coke killed 15 people today',
        polarity: 0.1
      },
      {
        name: 'New York Times',
        headline: 'Coke have found a cure for cancer',
        polarity: 0.9
      }
    ]
  }].to_json
end