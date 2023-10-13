# frozen_string_literal: true

RSpec.shared_context 'an API Resource' do
  let(:api)                  { OpenAI::API.new(api_client) }
  let(:api_client)           { OpenAI::API::Client.new('sk-123', http:) }
  let(:http)                 { class_spy(HTTP)                               }
  let(:response_status_code) { 200                                           }

  let(:response) do
    instance_double(
      HTTP::Response,
      status: HTTP::Response::Status.new(response_status_code),
      body: JSON.dump(response_body)
    )
  end

  before do
    allow(http).to receive(:post).and_return(response)
    allow(http).to receive(:get).and_return(response)
    allow(http).to receive(:delete).and_return(response)
  end
end
