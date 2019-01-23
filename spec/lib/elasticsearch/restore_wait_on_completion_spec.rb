require 'echo_common/elasticsearch/restore_wait_on_completion'

module EchoCommon
  describe Elasticsearch::RestoreWaitOnCompletion do
    class ElasticsearchCatApiMock
      attr_accessor :responses, :call_counter, :call_args

      def initialize
        @call_counter = 0
        @responses = []
      end

      def recovery(**args)
        self.call_args = args

        self.responses[(@call_counter += 1) - 1].tap do |response|
          raise 'No responses left' if response.nil?
        end
      end
    end

    let(:api_mock) { ElasticsearchCatApiMock.new }
    let(:client) { double cat: api_mock }

    subject { described_class.new client, wait_sec: 0 }

    describe '#wait_for_completion' do
      it 'calls recovery with correct args' do
        client.cat.responses = [
          [{'st' => 'done'}]
        ]

        subject.wait_for_completion

        expect(client.cat.call_args).to eq format: 'json', h: ['st']
      end

      it 'only calls recovery status once if all done' do
        client.cat.responses = [
          [{'st' => 'done'}]
        ]

        subject.wait_for_completion

        expect(client.cat.call_counter).to eq 1
      end

      it 'calls recovery status twice we have to wait' do
        client.cat.responses = [
          [{'st' => 'index'}],
          [{'st' => 'done'}],
        ]

        subject.wait_for_completion

        expect(client.cat.call_counter).to eq 2
      end

      it 'raises exception if it has no retries left' do
        subject = described_class.new client, wait_sec: 0, retries: 1

        client.cat.responses = [
          [{'st' => 'index'}],
          [{'st' => 'index'}],
        ]

        expect { subject.wait_for_completion }.to raise_error 'No retries left'
      end
    end
  end
end