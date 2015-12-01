require 'echo_common/paginatable_array'

module EchoCommon
  describe PaginatableArray do
    let(:array) { [1, 2, 3, 4, 5] }
    let(:limit) { 5 }
    let(:offset) { 1 }
    let(:total) { 100 }

    subject { described_class.new array, limit: limit, offset: offset, total: total }

    it "carries information about it's content and pagination" do
      expect(subject).to eq array
      expect(subject.limit).to eq limit
      expect(subject.offset).to eq offset
      expect(subject.total).to eq total
    end
  end
end
