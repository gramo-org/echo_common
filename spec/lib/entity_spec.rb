require 'echo_common/entity'

module EchoCommon
  describe Entity do
    class TestBook < Entity
      attributes do
        attribute :name,    Types::Strict::String
        attribute :author,  Types::Strict::String
      end
    end

    class TestPerson < Entity
      attributes do
        attribute :name,  Types::Strict::String
        attribute :books, Types::Collection(TestBook).default([])
      end
    end

    describe 'to_h' do
      subject(:peter) do
        TestPerson.new(
          name: 'Peter',
          books: [{ name: 'Ruby 1.0', author: 'Kjell-Magne' }]
        )
      end

      it 'returns nested data' do
        expect(peter.to_h).to eq({
          name: 'Peter',
          books: [{ name: 'Ruby 1.0', author: 'Kjell-Magne' }]
        })
      end
    end
  end
end
