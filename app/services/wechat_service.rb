class WechatService < ApplicationService
  def initialize(url)
    @url = url
    @client = WeixinAuthorize::Client.new(ENV['WECHAT_APPID'], ENV['WECHAT_APPSECRET'])
  end

  def call
    if ENV['WECHAT_APPID'].blank? || ENV['WECHAT_APPSECRET'].blank?
      return error_result('WeChat AppID or AppSecret not configured')
    end

    begin
      # Get jsapi_ticket from weixin_authorize gem
      ticket_result = @client.jsapi_ticket

      if ticket_result.is_a?(Hash) && ticket_result['ticket'].present?
        signature_data = generate_signature(ticket_result['ticket'])
        { success: true, data: signature_data }
      else
        Rails.logger.error("Failed to get jsapi_ticket: #{ticket_result.inspect}")
        error_result('Failed to get jsapi_ticket')
      end
    rescue StandardError => e
      Rails.logger.error("WechatService error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      error_result(e.message)
    end
  end

  private

  def generate_signature(jsapi_ticket)
    timestamp = Time.now.to_i.to_s
    nonce_str = SecureRandom.hex(8)

    # Remove fragment (#) from URL as per WeChat requirements
    url = @url.split('#')[0]

    # Build signature string: jsapi_ticket=XXX&noncestr=XXX&timestamp=XXX&url=XXX
    string_to_sign = "jsapi_ticket=#{jsapi_ticket}&noncestr=#{nonce_str}&timestamp=#{timestamp}&url=#{url}"
    signature = Digest::SHA1.hexdigest(string_to_sign)

    {
      appId: ENV['WECHAT_APPID'],
      timestamp: timestamp,
      nonceStr: nonce_str,
      signature: signature,
      url: url
    }
  end

  def error_result(message)
    {
      success: false,
      error: message
    }
  end
end
