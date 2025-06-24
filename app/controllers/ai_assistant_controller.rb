class AiAssistantController < ApplicationController
  before_action :authorized
  AI_SERVICE_URL = "http://localhost:8000"

  def analyze
    story_text = params.require(:text)

    # For now, we only have one type of analysis
    analysis_type = "checklist"

    begin
      # Forward the request to the Python service
      response = HTTParty.post(
        "#{AI_SERVICE_URL}/analyze/#{analysis_type}",
        body: { text: story_text }.to_json,
        headers: { "Content-Type" => "application/json" },
      )

      if response.success?
        render json: response.parsed_response, status: :ok
      else
        render json: { error: "AI Assistant service failed.", details: response.parsed_response }, status: response.code
      end
    rescue Errno::ECONNREFUSED => e
      render json: { error: "Could not connect to the AI Assistant service. Please try again later." }, status: :service_unavailable
    end
  end
end
