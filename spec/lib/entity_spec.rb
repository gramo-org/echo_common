# rubocop:disable Metrics/BlockLength

require 'echo_common/entity'
require 'echo_common/entity/hashify_nested_objects'
require 'echo_common/mutable_entity'

module EchoCommon
  describe "Entity and MutableEntity" do
    class TestRelease < MutableEntity
      attributes do
        attribute :year, Types::Strict::Int
      end
    end

    class TestBook < MutableEntity
      include Entity::HashifyNestedObjects

      attributes do
        attribute :name,          Types::Strict::String
        attribute :author,        Types::Strict::String
        attribute :main_release,  Types::Schema::CoercibleType.new(TestRelease)
        attribute :releases,      Types::Collection(TestRelease).default([])
      end
    end

    class TestPerson < Entity
      include Entity::HashifyNestedObjects

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

    it 'has a attribute which maintains type' do
      release = TestRelease.new year: 2000
      book = TestBook.new main_release: release

      expect(book.main_release).to be_a TestRelease

      book = TestBook.new main_release: { year: 2000 }
      expect(book.main_release).to be_a TestRelease
    end

    describe 'to_h' do
      subject(:peter) do
        TestPerson.new(
          name: 'Peter',
          books: [
            {
              name: 'Ruby 1.0', author: 'Kjell-Magne', releases: [{ year: 2000 }]
            }
          ]
        )
      end

      it 'returns nested data' do
        expect(peter.to_h).to eq({
          name: 'Peter',
          books: [
            {
              name: 'Ruby 1.0',
              author: 'Kjell-Magne',
              releases: [{ year: 2000 }]
            }
          ]
        })
      end
    end
  end
end
