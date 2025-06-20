# frozen_string_literal: true

RSpec.describe Fcmpush::HTTPX do
  let(:project_id) { "test-project" }
  let(:device_token) { "test-device-token" }
  let(:message) do
    {
      notification: {
        title: "Test Title",
        body: "Test Body"
      },
      token: device_token
    }
  end

  before do
    allow_any_instance_of(Fcmpush::Client).to receive(:v1_authorize).and_return(
      {
        "access_token" => "test-token",
        "expires_in" => 3600
      }
    )
  end

  it "has a version number" do
    expect(Fcmpush::HTTPX::VERSION).not_to be nil
  end

  describe "#initialize" do
    it "creates a client with project_id and access_token" do
      client = Fcmpush::HTTPX.new(project_id)
      expect(client.access_token).to eq("test-token")
    end
  end

  describe "#push" do
    before do
      allow_any_instance_of(Fcmpush::HTTPX::Client).to receive(:v1_authorize).and_return(
        "access_token" => "test-token",
        "expires_in" => 3600
      )
      allow_any_instance_of(Fcmpush::HTTPX::Client).to receive(:push).and_return(
        HTTPX::Response.new(HTTPX::Request.new("post", "http://example.com", HTTPX::Options.new), 200, "2.0", {})
      )
    end

    it "sends a push notification" do
      client = Fcmpush::HTTPX.new(project_id)
      response = client.push(message)

      expect(response).to be_a(HTTPX::Response)
    end
  end
end
