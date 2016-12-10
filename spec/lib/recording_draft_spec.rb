require 'spec_helper'

require 'echo_common/recording_draft'

module EchoCommon
  describe RecordingDraft do
    describe 'to_h' do
      subject do
        described_class.new(
          title: 'Thriller',
          isrc: 'ISRC123',
          duration_in_seconds: 125,
          recording_date: Date.new(2015, 10, 1),
          composers: [{ name: 'Jackson', alternative_names: [{ name: 'J' }] }],
          alternative_titles: [{ title: 'Thriller!' }]
        )
      end

      it 'returns the expected hash' do
        hash = subject.to_h

        expect(hash).to eq(
          title: 'Thriller',
          isrc: 'ISRC123',
          duration_in_seconds: 125,
          recording_date: Date.new(2015, 10, 1),
          composers: [{ name: 'Jackson', alternative_names: [{ name: 'J' }] }],
          local_ids: [],
          alternative_isrcs: [],
          alternative_titles: [{ title: 'Thriller!' }],
          tracks: []
        )
      end
    end
  end
end
