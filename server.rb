require 'sinatra'
require 'sinatra/cross_origin'
require 'json'
require_relative 'qr_code'

class Application < Sinatra::Base
  configure do
    enable :cross_origin
  end

  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
  end

  get '/all_qr_codes' do
    json_file = File.read("db.json")
    response = JSON.parse(json_file)
    if response.any?
      response.to_json
    else
      []
    end
  end

  post '/create_qr_code' do
    data = JSON.parse(request.body.read)
    
    name = data['name']
    description = data['description']
    main_color = data['main_color']
    fill_color = data['fill_color']
    url = data['url']

    qr_code = QrCode.new(name: name, description: description, main_color: main_color, fill_color: fill_color, url: url)

    qr_code.generate_code
  end

  options "*" do
    response.headers["Allow"] = "GET, PUT, POST, DELETE, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
    response.headers["Access-Control-Allow-Origin"] = "*"
    200
  end
end