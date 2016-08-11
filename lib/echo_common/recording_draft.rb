# coding: utf-8
module EchoCommon
  class RecordingDraft < EchoCommon::Entity
    attributes :title, :isrc, :duration_in_seconds
    attributes :recording_date, :release_date, :performer_note, :label_name

    attributes :local_ids, :main_artists, :main_artist
    attributes :composers
    attributes :alternative_isrcs, :alternative_titles
    attributes :tracks

    def initialize(attributes = {})
      super
      self.local_ids ||= []
      self.main_artists ||= []
      self.alternative_isrcs ||= []
      self.alternative_titles ||= []
      self.tracks ||= []
      self.composers ||= []
    end

    def main_artist
      check_main_artist!
      @main_artist || main_artists.join(' | ')
    end

    def main_artists
      check_main_artist!
      @main_artists
    end


    private

    def check_main_artist!
      if @main_artists && @main_artists.any? && !@main_artist.nil?
        fail ArgumentError, "Cannot both have main_artists and main_artist set"
      end
    end
  end
end
