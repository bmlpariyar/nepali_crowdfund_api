# app/services/khalti_payment_service.rb
class KhaltiPaymentService
  include HTTParty
  base_uri "https://dev.khalti.com"

  def initialize(payment_data)
    @headers = {
      "Authorization" => "key #{ENV["KHALTI_KEY"]}",
      "Content-Type" => "application/json",
    }

    @body = {
      return_url: payment_data[:return_url],
      website_url: payment_data[:website_url],
      amount: (payment_data[:amount].to_f * 100).to_i, # Convert to paisa
      purchase_order_id: payment_data[:purchase_order_id],
      purchase_order_name: payment_data[:purchase_order_name],
      customer_info: payment_data[:customer_info],
      amount_breakdown: payment_data[:amount_breakdown],
      product_details: payment_data[:product_details],
      merchant_username: payment_data[:merchant_username],
      merchant_extra: payment_data[:merchant_extra],
    }
  end

  def initiate_payment
    response = self.class.post("/api/v2/epayment/initiate/", headers: @headers, body: @body.to_json)

    if response.success?
      response.parsed_response
    else
      {
        error: true,
        message: response.parsed_response["message"] || "Payment initiation failed",
        details: response.parsed_response,
      }
    end
  end
end
