require 'echo_common/services/elasticsearch'

describe EchoCommon::Services::Elasticsearch do

  let(:client) { double }

  let(:index) { 'cars' }
  let(:type) { 'car' }

  let(:subject) do
    described_class.new client: client, index: index, type: type
  end

  describe '#index' do
    it 'passes on data to the client' do
      expect(client).to receive(:index).with(
        index: index, type: type,
        id: nil,
        body: { some: :data }
      )

      subject.index some: :data
    end

    it 'can assign id' do
      expect(client).to receive(:index).with(hash_including(id: 'my-id'))
      subject.index id: 'my-id', some: :data
    end

    it 'does not pass id within body / document data to be indexed' do
      expect(client).to receive(:index).with(hash_including(body: { some: :data }))
      subject.index id: 'my-id', some: :data
    end

    it 'does not mutate given doc' do
      allow(client).to receive(:index)
      doc = { id: 'my-id', some: :data }
      expect { subject.index doc }.to_not change { doc[:id] }
    end
  end

  describe '#update' do
    it 'passes on data to the client' do
      expect(client).to receive(:update).with(
        index: index, type: type,
        id: 'my-id',
        body: { doc: { some: :data } }
      )

      subject.update id: 'my-id', some: :data
    end

    it 'does not mutate given doc' do
      allow(client).to receive(:update)
      doc = { id: 'my-id', some: :data }
      expect { subject.update doc }.to_not change { doc[:id] }
    end
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

    it "returns response from client when no errors" do
      expect(client).to receive(:bulk).and_return(items: [])

      expect { subject.bulk double }.to_not raise_error
    end
  end

end
