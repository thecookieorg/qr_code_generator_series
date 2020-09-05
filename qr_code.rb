require 'rqrcode'
require 'date'
require 'json'
require 'base64'
require 'securerandom'

class QrCode
  attr_reader :name, :description, :main_color, :fill_color, :url

  def initialize(name:, description:, main_color:, fill_color:, url:)
    @name = name
    @description = description
    @main_color = main_color
    @fill_color = fill_color
    @url = url
  end

  def generate_code
    qrcode = RQRCode::QRCode.new(@url)

    png = qrcode.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: @main_color,
      file: nil,
      fill: @fill_color,
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 480
    )

    image_file_name = "#{@name.downcase.split.join('_')}.png"
    IO.binwrite("./qrcodes/#{image_file_name}", png.to_s)

    converted_image = image_to_base64(image_file_name)
    update_json_db(converted_image)
  end

  private

  def image_to_base64(image_file_name)
    File.open("./qrcodes/#{image_file_name}") do |img|
      "data:image/png;base64,#{Base64.strict_encode64(img.read)}"
    end
  end

  def update_json_db(converted_image)
    uid = SecureRandom.uuid

    new_record = {
      uid: uid,
      name: @name,
      description: @description,
      image: converted_image,
      created_at: DateTime.now
    }

    existing_records = File.read('db.json')
    parsed_existing_records = JSON.parse(existing_records)

    new_records = parsed_existing_records.unshift(new_record)

    File.open("db.json", "w") do |f|
      f.write(new_records.to_json)
    end

    json_db = File.read("db.json")
    response = JSON.parse(json_db)
    # response.to_json
    {
      generated_qr_png: converted_image,
      all_qr_codes: response
    }.to_json
  end
end