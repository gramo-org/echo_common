# coding: utf-8
module EchoCommon
  class RecordingDraft < EchoCommon::Entity
    attributes :title, :isrc, :duration_in_seconds
    attributes :recording_date, :release_date, :release_year
    attributes :performer_note, :label_name, :recorded_in

    attributes :local_ids, :main_artist
    attributes :composers
    attributes :alternative_isrcs, :alternative_titles
    attributes :tracks
    attributes :contributors

    def initialize(attributes = {})
      super
      self.local_ids ||= []
      self.alternative_isrcs ||= []
      self.alternative_titles ||= []
      self.tracks ||= []
      self.composers ||= []
      self.contributors ||= []
    end
  end
end
