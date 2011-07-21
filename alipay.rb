#支付宝接口类。能生成支付宝接口链接。
require 'md5'
require 'uri'

class Alipay
  def initialize(params)
    @partner = params[:partner]
    @key = params[:key]
  end

  def sign(params)
    params_kv = params.sort.map do |kv|
      kv.join('=')
    end
    sign = MD5.hexdigest(params_kv.join('&') + @key)
    params['sign_type'] = 'MD5'
    params['sign'] = sign
    return params
  end

  def direct_pay_link(params,link_msg)
    params['service'] = 'create_direct_pay_by_user'
    params['_input_charset'] = 'utf-8'
    params['payment_type'] = '1'
    params['partner'] = @partner
    all_params = sign(params)
    all_params_kv = all_params.map do |key,value|
      key + "=" + value
    end
    href = "https://www.alipay.com/cooperate/gateway.do?" + URI.encode(all_params_kv.join('&'))
    return "<a id=\"alipay\" href=\"#{href}\">#{link_msg}</a>"
  end

  def verify(notification)
    sign_type = notification.delete('sign_type')
    sign = notification.delete('sign')
    params_kv = notification.sort.map do |kv|
      kv.join('=')
    end
    return sign == MD5.hexdigest(params_kv.join('&') + @key)
  end
end
