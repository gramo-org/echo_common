# coding: utf-8
module EchoCommon
  class RecordingDraft < EchoCommon::Entity
    attributes :title, :isrc, :duration_in_seconds
    attributes :recording_date, :release_date, :performer_note, :label_name

    attributes :local_ids, :main_artist
    attributes :composers
    attributes :alternative_isrcs, :alternative_titles
    attributes :tracks

    def initialize(attributes = {})
      super
      self.local_ids ||= []
      self.alternative_isrcs ||= []
      self.alternative_titles ||= []
      self.tracks ||= []
      self.composers ||= []
    end
  end
end
