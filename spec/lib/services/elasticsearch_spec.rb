require 'echo_common/services/elasticsearch'

describe EchoCommon::Services::Elasticsearch do

  let(:client) { double }

  let(:subject) do
    described_class.new client: client
  end

  describe "#bulk" do
    let(:response_with_errors) do
      { :took=>1,
        :errors=>true,
        :items=>[
          {
            :index=>{
              :_index=>"recording_drafts",
              :_type=>"recording_draft",
              :_id=>"12745",
              :status=>400,
              :error=>{
                :type=>"mapper_parsing_exception",
                :reason=>"object mapping for [composers] tried to parse field [null] as object, but found a concrete value"
              }
            }
          },
          {
            :index=>{
              :_index=>"recording_drafts",
              :_type=>"recording_draft",
              :_id=>"12746",
              :status=>400,
              :error=>{
                :type=>"mapper_parsing_exception",
                :reason=>"object mapping for [composers] tried to parse field [null] as object, but found a concrete value"
              }
            }
          }
        ]
      }
    end

    it "raises error when response from client contains errors" do
      expect(client).to receive(:bulk).and_return(response_with_errors)

      expect { subject.bulk double }.to raise_error { |error|
        expect(error).to be_a EchoCommon::Services::Elasticsearch::BulkError
        expect(error.response).to eq response_with_errors
      }

    end
  end

end
