require_relative "../../../spec_helper"
require "kontena/cli/services/services_helper"

module Kontena::Cli::Services
  describe ServicesHelper do
    subject{klass.new}

    let(:klass) { Class.new { include ServicesHelper } }

    let(:client) do
      double
    end

    let(:token) do
      'token'
    end

    before(:each) do
      allow(subject).to receive(:client).with(token).and_return(client)
    end

    describe '#create_service' do
      it 'creates POST grids/:id/services request to Kontena Server' do
        expect(client).to receive(:post).with('grids/1/services', {'name' => 'test-service'})
        subject.create_service(token, '1', {'name' => 'test-service'})
      end
    end

    describe '#update_service' do
      it 'creates PUT services/:id request to Kontena Server' do
        expect(client).to receive(:put).with('services/1', {'name' => 'test-service'})
        subject.update_service(token, '1', {'name' => 'test-service'})
      end
    end

    describe '#get_service' do
      it 'creates GET services/:id request to Kontena Server' do
        expect(client).to receive(:get).with('services/test-service')
        subject.get_service(token, 'test-service')
      end
    end

    describe '#deploy_service' do
      it 'creates POST services/:id/deploy request to Kontena Server' do
        allow(client).to receive(:get).with('services/1').and_return({'state' => 'running'})
        expect(client).to receive(:post).with('services/1/deploy', {'strategy' => 'ha'})
        subject.deploy_service(token, '1', {'strategy' => 'ha'})
      end

      it 'polls Kontena Server until service is running' do
        allow(client).to receive(:post).with('services/1/deploy', anything)
        expect(client).to receive(:get).with('services/1').twice.and_return({'state' => 'deploying'}, {'state' => 'running'})

        subject.deploy_service(token, '1', {'strategy' => 'ha'})
      end
    end

    describe '#parse_ports' do
      it 'raises error if node_port is missing' do
        expect{
          subject.parse_ports(["80"])
        }.to raise_error(ArgumentError)
      end

      it 'raises error if container_port is missing' do
        expect{
          subject.parse_ports(["80:"])
        }.to raise_error(ArgumentError)
      end

      it 'returns hash of port options' do
        valid_result = [{
            container_port: '80',
            node_port: '80',
            protocol: 'tcp'
        }]
        port_options = subject.parse_ports(['80:80'])

        expect(port_options).to eq(valid_result)

      end
    end

    describe '#parse_links' do
      it 'raises error if service name is missing' do
        expect{
          subject.parse_links([""])
        }.to raise_error(ArgumentError)
      end

      it 'returns hash of link options' do
        valid_result = [{
                            name: 'db',
                            alias: 'mysql',
                        }]
        link_options = subject.parse_links(['db:mysql'])

        expect(link_options).to eq(valid_result)

      end
    end
  end
end