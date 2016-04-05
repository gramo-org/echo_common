require 'echo_common/services/elasticsearch/client'

describe EchoCommon::Services::Elasticsearch::Client do

  let(:config) do
    {
      host: "127.0.0.1",
      port: 9200,
      user: "",
      password: "",
      scheme: "http",
      index_prefix: "testing_",
      indices_mapping_glob: "foo/bar/*.json"
    }
  end

  let(:client_class) { double }
  let(:elasticsearch_client) { double indices: double }
  let(:client) do
    described_class.new logger: double, config: config, client_class: client_class
  end

  before do
    allow(client_class).to receive(:new).and_return(elasticsearch_client)
  end

  describe "#get" do
    it "gets doc using prefixed index" do
      expect(elasticsearch_client).to receive(:get).with(
        index: "testing_foo",
        type: "bar",
        id: "baz"
      )

      client.get(index: "foo", type: "bar", id: "baz")
    end
  end

  describe "#index" do
    it "indexes doc using prefixed index" do
      expect(elasticsearch_client).to receive(:index).with(
        index: "testing_foo",
        type: "bar",
        id: "baz",
        body: "fizz"
      )

      client.index(index: "foo", type: "bar", id: "baz", body: "fizz")
    end
  end

  describe "#update" do
    it "updates doc using prefixed index" do
      expect(elasticsearch_client).to receive(:update).with(
        index: "testing_foo",
        type: "bar",
        id: "baz",
        body: "fizz"
      )

      client.update(index: "foo", type: "bar", id: "baz", body: "fizz")
    end
  end

  describe "#bulk" do
    it "calls bulk using prefixed index" do
      expect(elasticsearch_client).to receive(:bulk).with(
        index: "testing_foo",
        type: "bar",
        body: "fizz"
      )

      client.bulk(index: "foo", type: "bar", body: "fizz")
    end
  end

  describe "#search" do
    it "calls search using prefixed index" do
      expect(elasticsearch_client).to receive(:search).with(
        index: "testing_foo",
        type: "bar",
        body: "fizz"
      )

      client.search(index: "foo", type: "bar", body: "fizz")
    end
  end

  describe "#create_index" do
    it "creates index based on mapping files" do
      expect(File).to receive(:read).and_return("fizz")
      expect(client).to receive(:mapping_files).and_return(["foo/bar/recordings.json"])
      expect(elasticsearch_client.indices).to receive(:create).with(
        index: "testing_recordings",
        body: "fizz"
      )

      client.create_index("recordings")
    end
  end

  describe "#create_all_indices" do
    it "creates all indices" do
      expect(File).to receive(:read).and_return("fizz")
      expect(client).to receive(:mapping_files).and_return(["foo/bar/recordings.json"])
      expect(client).to receive(:create_index_from_file).with("foo/bar/recordings.json").and_call_original

      expect(elasticsearch_client.indices).to receive(:create).with(
        index: "testing_recordings",
        body: "fizz"
      )

      client.create_all_indices
    end
  end

  describe "#delete_index" do
    it "deletes index using prefix" do
      expect(elasticsearch_client.indices).to receive(:delete).with(
        index: "testing_foo",
        ignore: [404]
      )

      client.delete_index("foo")
    end
  end

  describe "#delete_all_indices" do
    it "deletes all indices using prefix" do
      expect(elasticsearch_client.indices).to receive(:delete).with(
        index: "testing_*"
      )

      client.delete_all_indices
    end
  end

  describe "#refresh_indices" do
    it "refresh_indices" do
      expect(elasticsearch_client.indices).to receive(:refresh)

      client.refresh_indices
    end
  end

  describe "#put_alias" do
    it "refresh_indices" do
      expect(elasticsearch_client.indices).to receive(:put_alias).with(
        index: "testing_foo",
        name: "testing_bar",
        body: {baz: "biz"}
      )

      client.put_alias(index: "foo", name: "bar", body: {baz: "biz"})
    end
  end

end
