require 'rest-client'
require 'oj'

class Jet::Client
  API_URL = 'https://merchant-api.jet.com/api'
  STATUS_CODES = {200 => 'success',
                  201 => 'created',
                  202 => 'accepted',
                  204 => 'no_content',
                  400 => 'bad_request',
                  401 => 'unauthorized',
                  403 => 'forbidden',
                  404 => 'not_found',
                  405 => 'method_not_allowed',
                  500 => 'internal_server_error',
                  503 => 'unavailable'
                 }

  def initialize(config = {})
    @api_user = config[:api_user]
    @secret = config[:secret]
    @merchant_id = config[:merchant_id]
  end

  def encode_json(data)
    data = format_dates(data)
    Oj.dump(data, mode: :compat)
  end

  def decode_json(json)
    Oj.load(json)
  end

  # Jet required all dates be in this format:
  # yyyy-MM-ddTHH:mm:ss.fffffff-HH:MM
  # 2009-06-15T13:45:30.0000000-07:00
  def format_dates(data)
    if data.is_a?(Hash)
      data.each do |k, v|
        data[k] = v.strftime("%Y-%m-%dT%H:%M:%S.%6N0%:z") if v.is_a?(Time) || v.is_a?(DateTime)
        data[k] = format_dates(v) if v.is_a?(Enumerable)
      end
    elsif data.is_a?(Array)
      data.map! { |h| format_dates(h) }
    else
      raise "json data must be a Hash or Array. Received #{data.class.name} : #{data.inspect}"
    end
    data
  end

  def decode_status(response)
    if response.body.blank? || response.code >= 300
      { status: STATUS_CODES[response.code],
        status_code: response.code
      }.merge(decode_json(response.body).to_h)
    else
      decode_json(response.body)
    end
  end

  def api_call_with_token(action, path, options={})
    headers = token
    headers.merge!(options[:headers]) if options[:headers].is_a?(Hash)

    args = ["#{API_URL}#{path}"]
    args << encode_json(options[:body]) unless options[:body].nil?
    args << headers

    begin
      response = RestClient.send(action, *args)
      decode_status(response)
    rescue RestClient::ExceptionWithResponse => e
      decode_status(e.response)
    end
  end

  def token
    unless (@id_token && @token_type && @expires_on > Time.now)
      body = {
        user: @api_user,
        pass: @secret
      }
      response = RestClient.post("#{API_URL}/token", encode_json(body))
      parsed_response = decode_json(response.body)
      @id_token = parsed_response['id_token']
      @token_type = parsed_response['token_type']
      @expires_on = Time.parse(parsed_response['expires_on'])
    end

    { Authorization: "#{@token_type} #{@id_token}" }
  end

  def rest_get_with_token(path, query_params = {})
    headers = query_params.empty? ? nil : { params: query_params }
    api_call_with_token(:get, path, headers: headers)
  end

  def rest_put_with_token(path, body = {})
    api_call_with_token(:put, path, body: body)
  end

  def rest_post_with_token(path, body = {})
    api_call_with_token(:post, path, body: body)
  end

  def orders
    Orders.new(self)
  end

  def returns
    Returns.new(self)
  end

  def products
    Products.new(self)
  end

  def taxonomy
    Taxonomy.new(self)
  end

  def files
    Files.new(self)
  end

  def refunds
    Refunds.new(self)
  end
end

require 'jet/client/orders'
require 'jet/client/returns'
require 'jet/client/products'
require 'jet/client/taxonomy'
require 'jet/client/files'
require 'jet/client/refunds'
