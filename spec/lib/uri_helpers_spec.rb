require 'spec_helper'

require 'echo_common/uri_helpers'

module EchoCommon
  describe UriHelpers do

    describe '::add_query_variables' do

      context 'string URIs, happy path' do
        @data = [
          # String URIs
          ['http://example.com',       nil,       'http://example.com'],
          ['http://example.com',       {},        'http://example.com'],
          ['http://example.com?foo=1', nil,       'http://example.com?foo=1'],
          ['http://example.com?foo=1', {},        'http://example.com?foo=1'],
          ['http://example.com?foo=1', {bar: 2},  'http://example.com?foo=1&bar=2'],
          ['http://example.com',       {bar: 2},  'http://example.com?bar=2'],

          # URI objects also works
          [URI('http://example.com'),  {bar: 2},  'http://example.com?bar=2'],
        ]

        @data.each do |d|
          it do
            expect(described_class.add_query_variables(d[0], d[1]).to_s).to eq d[2]
          end
        end
      end

      context 'sad path' do
        context 'garbage in, garbage out' do
          @data = [
            ['gurba',       nil,       'gurba'],
            ['gurba',       {foo: 1},  'gurba?foo=1'],
          ]

          @data.each do |d|
            it do
              expect(described_class.add_query_variables(d[0], d[1]).to_s).to eq d[2]
            end
          end
        end

        context 'failures' do
          @data = [
            [1,                     nil],
            ['http://example.com',  1],
          ]

          @data.each do |d|
            it do
              expect { described_class.add_query_variables(d[0], d[1]) }.to raise_error(ArgumentError)
            end
          end
        end
      end
    end
  end
end
