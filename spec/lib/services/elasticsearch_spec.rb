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

    it 'does pass id within body / document data to be indexed' do
      expect(client).to receive(:index).with(hash_including(body: { id: 'my-id', some: :data }))
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

  describe '#get' do
    it 'returns nil when not found' do
      expect(client).to receive(:get).with(id: 'my-id', index: index, type: type).and_return(
        found: false
      )

      expect(subject.get 'my-id').to be_nil
    end

    it 'returns doc when found' do
      expect(client).to receive(:get).with(id: 'my-id', index: index, type: type).and_return(
        found: true,
        _id: 'my-id',
        _source: {
          some: 'data'
        }
      )

      expect(subject.get 'my-id').to eq(
        id: 'my-id',
        some: 'data'
      )
    end
  end

  describe '#mget' do
    it 'returns array of found ids' do
      expect(client).to receive(:mget).with(body: { ids: ['my-id'] }, index: index, type: type).and_return(
        docs: [
          {
            found: true,
            _id: 'my-id',
            _source: {
              some: 'data'
            }
          }
        ]

      )

      expect(subject.mget(['my-id'])).to eq [
        { id: 'my-id', some: 'data' }
      ]
    end
  end

  describe '#search' do
    it 'merges id in to hits' do
      expect(client).to receive(:search).with(body: 'query', index: index).and_return(
        hits: [
          _id: 'my-id',
          _source: {
            some: 'data'
          }
        ]
      )

      expect(subject.search 'query').to eq(
        hits: [
          _id: 'my-id',
          _source: {
            id: 'my-id',
            some: 'data'
          }
        ]
      )
    end

    it 'forwards args to client' do
      expect(client)
        .to receive(:search)
        .with(hash_including(suppress_shards_failures: true))
        .and_return(hits: [])

      subject.search 'query', suppress_shards_failures: true
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
