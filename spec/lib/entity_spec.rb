# rubocop:disable Metrics/BlockLength

require 'echo_common/entity'

module EchoCommon
  describe Entity do
    class TestBook < Entity
      self.immutable = false

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

    describe 'frozen state' do
      it 'is frozen as a default' do
        expect(TestPerson.new(name: 'Peter')).to be_frozen
      end

      it 'cannot mutate frozen state' do
        person = TestPerson.new name: 'Peter'
        expect { person.name = 'TH' }.to raise_error NoMethodError
      end

      it 'can be configured on class level to skip frozen on init' do
        expect(TestBook.new(name: 'Ruby')).to_not be_frozen
      end

      it 'has setters when entity is mutable' do
        book = TestBook.new name: 'Ruby'

        expect { book.name = 'JavaScript' }
          .to change(book, :name).to 'JavaScript'
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
