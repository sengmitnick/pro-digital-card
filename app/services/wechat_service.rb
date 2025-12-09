class WechatService < ApplicationService
  def initialize(url)
    @url = url
  end

  def call
    if ENV['WECHAT_APPID'].blank? || ENV['WECHAT_APPSECRET'].blank?
      return error_result('WeChat AppID or AppSecret not configured')
    end

    begin
      # Create client instance
      client = WeixinAuthorize::Client.new(ENV['WECHAT_APPID'], ENV['WECHAT_APPSECRET'])
      
      # Get sign package using get_jssign_package method
      sign_package = client.get_jssign_package(@url)

      Rails.logger.info("WeChat sign_package result: #{sign_package.inspect}")

      if sign_package.is_a?(Hash) && sign_package['signature'].present?
        # Convert keys to symbols for consistency
        signature_data = {
          appId: sign_package['appId'],
          timestamp: sign_package['timestamp'],
          nonceStr: sign_package['nonceStr'],
          signature: sign_package['signature'],
          url: @url.split('#')[0]
        }
        { success: true, data: signature_data }
      else
        Rails.logger.error("Failed to get sign package: #{sign_package.inspect}")
        error_result('Failed to get WeChat signature')
      end
    rescue StandardError => e
      Rails.logger.error("WechatService error: #{e.class.name} - #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      error_result(e.message)
    end
  end

  private

  def error_result(message)
    {
      success: false,
      error: message
    }
  end
end
