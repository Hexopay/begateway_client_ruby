require 'spec_helper'
require 'net/http'

describe 'BeGateway::Connection' do
  class TestConnection
    include BeGateway::Connection
  end

  let(:headers) { nil }
  let(:params) do
    {
      shop_id: 1,
      secret_key: 'secret_key',
      url: 'https://gateway.ecomcharge.com',
      headers: headers
    }
  end
  let(:client) { TestConnection.new(params) }

  context '.connection' do
    subject { client.send(:connection) }

    context 'when passed headers' do
      let(:headers) { {'RequestID' => 'some-request-id'} }

      it 'contains passed headers' do
        expect(subject.headers).to include(headers)
      end
    end
  end

  context '.send_request' do
    let(:method) { 'post' }
    let(:path)   { '/payment' }
    let(:data)   { {amount: 100} }
    let(:connection) { double('connection') }

    subject { client.send(:send_request, method, path, data) }

    it 'calls passed method for the connection' do
      expect(Faraday::Connection).to receive(:new).and_return(connection)

      expect(connection).to receive(:public_send)
        .with(method, path, data)
        .and_return(OpenStruct.new)

      subject
    end

    context 'when connection is timed out' do
      it 'catches the error' do
        expect(Faraday::Connection).to receive(:new).and_raise(Net::OpenTimeout)

        expect(subject.response['message']).to eq('Timeout')
        expect(subject.response['errors']['connection']).to eq('is timed out')
      end
    end
  end

end
