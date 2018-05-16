class CurrencyController < ApplicationController
  CURRENCIES = %i[AED AFN ALL AMD ANG AOA ARS AUD AWG AZN BAM BBD BDT BGN BHD
                  BIF BMD BND BOB BRL BSD BTC BTN BWP BYN BYR BZD CAD CDF CHF
                  CLF CLP CNY COP CRC CUC CUP CVE CZK DJF DKK DOP DZD EGP ERN
                  ETB EUR FJD FKP GBP GEL GGP GHS GIP GMD GNF GTQ GYD HKD HNL
                  HRK HTG HUF IDR ILS IMP INR IQD IRR ISK JEP JMD JOD JPY KES
                  KGS KHR KMF KPW KRW KWD KYD KZT LAK LBP LKR LRD LSL LTL LVL
                  LYD MAD MDL MGA MKD MMK MNT MOP MRO MUR MVR MWK MXN MYR MZN
                  NAD NGN NIO NOK NPR NZD OMR PAB PEN PGK PHP PKR PLN PYG QAR
                  RON RSD RUB RWF SAR SBD SCR SDG SEK SGD SHP SLL SOS SRD STD
                  SVC SYP SZL THB TJS TMT TND TOP TRY TTD TWD TZS UAH UGX USD
                  UYU UZS VEF VND VUV WST XAF XAG XAU XCD XDR XOF XPF YER ZAR
                  ZMK ZMW ZWL]
  def index
  end

  def live
    target_currencies = target_currencies_string live_params['target_currencies']
    @exchanges = fetch_data(target_currencies, @date)
    @amount = live_params[:amount].to_i
    post_slack_message "```This is the live exchange rate of USD\n #{@exchanges.to_s}```" if @exchanges
  end

  def historical
    target_currencies = target_currencies_string historical_params['target_currencies']
    @date = Date.new(historical_params['date(1i)'].to_i, historical_params['date(2i)'].to_i, historical_params['date(3i)'].to_i).to_s
    @exchanges = fetch_data(target_currencies, @date)
    @amount = historical_params[:amount].to_i
    post_slack_message "```This was the exchange rate of USD on #{@date}\n #{@exchanges.to_s}```" if @exchanges
  end

  def best_rate
    date = Date.yesterday
    date_rate_pair = {}
    7.times do
      response = call_api 'historical', best_rate_param, date.to_s
      parsed_response = JSON.parse(response.body)
      unless parsed_response['success']
        error_handing(parsed_response['error'])
        return
      end
      rate = parsed_response['quotes'].values.first
      date_rate_pair[date] = rate
      date-=1 
    end
    @best_rate = date_rate_pair.values.max
    @best_date = date_rate_pair.key @best_rate
    post_slack_message "In past seven days best rate for USD to #{best_rate_param} was #{@best_rate} on #{@best_date}"
  end

  private

  def live_params
    params.permit(:amount, target_currencies: [])
  end

  def historical_params
    params.permit('date(1i)', 'date(2i)', 'date(3i)', :amount, target_currencies: [])
  end

  def best_rate_param
    params.require(:target_currency)
  end

  def fetch_data(currencies, date = nil)
    response = call_api params[:action], currencies, date
    parsed_response = JSON.parse(response.body)
    error_handing(parsed_response['error']) unless parsed_response['success']
    parsed_response['quotes']
  end

  def call_api(action, target_currencies, date)
    params = { currencies: target_currencies, date: date, access_key: Rails.application.secrets.api_key }
    HTTP.get("#{Rails.application.config.API_endpoint}/#{action}", params: params )
  end

  def target_currencies_string(target_currencies)
    target_currencies.reject(&:blank?).join ','
  end

  def error_handing(response)
    message = case response['code']
              when 404 then 'Resource does not exist'
              when 101 then 'empty or invalid access key'
              when 104 then 'monthly API request allowance is finished'
              end
    post_slack_message message
    render json: { status: response['code'], message: message }
  end

  def post_slack_message(message)
    Rails.application.config.slack_notifier.post "text": message, "mrkdown": true
  end
end
