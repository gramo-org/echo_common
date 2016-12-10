# rubocop:disable Metrics/BlockLength

require 'echo_common/entity'
require 'echo_common/mutable_entity'

module EchoCommon
  describe "Entity and MutableEntity" do
    class TestBook < MutableEntity
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

    describe Entity do
      it 'has frozen state' do
        expect(TestPerson.new(name: 'Peter')).to be_frozen
      end

      it 'cannot mutate frozen state' do
        person = TestPerson.new name: 'Peter'
        expect { person.name = 'TH' }.to raise_error NoMethodError
      end
    end

    describe MutableEntity do
      it 'is not frozen' do
        expect(TestBook.new(name: 'Ruby')).to_not be_frozen
      end

      it 'has setters which mutates the entity' do
        book = TestBook.new name: 'Ruby'

        expect { book.name = 'JavaScript' }
          .to change(book, :name).to 'JavaScript'
      end

      it 'cannot mutate attributes it does not have' do
        book = TestBook.new name: 'Ruby'
        expect { book.year = 2027 }.to raise_error NoMethodError
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
