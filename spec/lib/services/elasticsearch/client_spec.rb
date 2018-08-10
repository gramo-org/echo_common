require 'echo_common/services/elasticsearch/client'

describe EchoCommon::Services::Elasticsearch::Client do

  let(:config) do
    {
      indices_mapping_glob: "foo/bar/*.json",
      index_prefix: "testing_",
      hosts: [{
        host: "127.0.0.1",
        port: 9200,
        user: "",
        password: "",
        scheme: "http",
      }]
    }
  end

  let(:client_class) { double }
  let(:elasticsearch_client) { double indices: double, tasks: tasks_client }
  let(:tasks_client) { double }
  let(:client) do
    described_class.new **config, client_class: client_class
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

  describe "#mget" do
    it "multi gets docs using prefixed index" do
      expect(elasticsearch_client).to receive(:mget).with(
        index: "testing_foo",
        type: "bar",
        body: "baz"
      )

      client.mget(index: "foo", type: "bar", body: "baz")
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

  describe "#delete" do
    it "deletes doc using prefixed index" do
      expect(elasticsearch_client).to receive(:delete).with(
        index: "testing_foo",
        type: "bar",
        id: "baz"
      )

      client.delete(index: "foo", type: "bar", id: "baz")
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

    it 'supports index with ,' do
      expect(elasticsearch_client).to receive(:search).with(
        index: "testing_foo,testing_bar",
        type: nil,
        body: "fizz"
      )

      client.search(index: "foo,bar", type: nil, body: "fizz")
    end

    it 'supports index with @' do
      expect(elasticsearch_client).to receive(:search).with(
        index: "testing_@foo",
        type: nil,
        body: "fizz"
      )

      client.search(index: "@foo", type: nil, body: "fizz")
    end

    it 'supports index with numbers' do
      expect(elasticsearch_client).to receive(:search).with(
        index: "testing_foo2",
        type: nil,
        body: "fizz"
      )

      client.search(index: "foo2", type: nil, body: "fizz")
    end

    it 'supports index with "*" "," and "-"' do
      pending

      expect(elasticsearch_client).to receive(:search).with(
        index: "testing_foo*,-testing_foo5",
        type: nil,
        body: "fizz"
      )

      client.search(index: "foo*,-foo5", type: nil, body: "fizz")
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

    it "fails indices_mapping_globs results in multiple files for the same index" do
      allow(Dir).to receive(:glob) { |pass_through| pass_through }
      allow(File).to receive(:read).and_return("fizz")
      expect(client).to receive(:indices_mapping_globs).and_return(['/a/recordings.json', '/b/recordings.json'])

      expect {
        client.create_index("recordings")
      }.to raise_error EchoCommon::Error, /Your indices mapping glob yielded multiple files with equal filenames/
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
    it "asks client to refresh all indices" do
      expect(elasticsearch_client.indices).to receive(:refresh).with(index: "testing_*")

      client.refresh_indices
    end

    it "asks client to refresh an index" do
      expect(elasticsearch_client.indices).to receive(:refresh).with(index: "testing_foo")

      client.refresh_indices "foo"
    end
  end

  describe "#put_alias" do
    it "creates or updates single index alias" do
      expect(elasticsearch_client.indices).to receive(:put_alias).with(
        index: "testing_foo",
        name: "testing_bar",
        body: { baz: "biz" }
      )

      client.put_alias(index: "foo", name: "bar", body: { baz: "biz" })
    end
  end

  describe "#put_mapping" do
    it "creates or updates mapping of index" do
      expect(elasticsearch_client.indices).to receive(:put_mapping).with(
        index: "testing_recordings",
        type: "recording",
        body: { baz: "biz" }
      )

      client.put_mapping(index: "recordings", type: "recording", body: { baz: "biz"})
    end

    it "creates or updates mapping of multiple indices" do
      expect(elasticsearch_client.indices).to receive(:put_mapping).with(
        index: ["testing_recordings", "testing_recording_drafts"],
        type: "recording",
        body: { baz: "biz" }
      )

      client.put_mapping(
        index: ["recordings", "recording_drafts"],
        type: "recording",
        body: { baz: "biz"}
      )
    end
  end

  describe "#update_by_query" do
    it "process every document matching a query, potentially updating it" do
      expect(elasticsearch_client).to receive(:update_by_query).with(
        index: "testing_recordings",
        wait_for_completion: true
      )
      client.update_by_query(index: "recordings")

      expect(elasticsearch_client).to receive(:update_by_query).with(
        index: ["testing_recordings", "testing_recording_drafts"],
        wait_for_completion: true
      )
      client.update_by_query(index: ["recordings", "recording_drafts"])
    end
  end

  describe "#list_tasks" do
    it "lists tasks" do
      expect(tasks_client).to receive(:list).with(
        task_id: 'foo'
      )

      client.list_tasks(task_id: 'foo')
    end
  end

end
