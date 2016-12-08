# coding: utf-8

require 'echo_common/entity'

module EchoCommon
  class RecordingDraft < EchoCommon::Entity
    class AlternativeIsrc < EchoCommon::Entity
      attributes do
        attribute :isrc,        Types::String
        attribute :description, Types::String
      end
    end

    class AlternativeTitle < EchoCommon::Entity
      attributes do
        attribute :title,       Types::Strict::String
        attribute :description, Types::Strict::String
      end
    end

    class AlternativeName < EchoCommon::Entity
      attributes do
        attribute :name,        Types::Strict::String
        attribute :description, Types::Strict::String
      end
    end

    class Composer < EchoCommon::Entity
      attributes do
        attribute :name,              Types::Strict::String
        attribute :alternative_names, Types::Coercible::Array.member(AlternativeName).default([])
      end
    end

    class Track < EchoCommon::Entity
      attributes do
        attribute :title,           Types::Strict::String
        attribute :side,            Types::Strict::Int
        attribute :number,          Types::Strict::Int
        attribute :label_name,      Types::Strict::String
        attribute :isrc,            Types::Strict::String
        attribute :release_id,      Types::Strict::String
        attribute :release_title,   Types::Strict::String
        attribute :catalog_number,  Types::Strict::String
        attribute :p_line,          Types::Strict::String
      end
    end

    attributes do
      attribute :title,               Types::Strict::String
      attribute :isrc,                Types::Strict::String
      attribute :duration_in_seconds, Types::Strict::Int
      attribute :recording_date,      Types::Strict::Date
      attribute :release_date,        Types::Strict::Date
      attribute :performer_note,      Types::Strict::String
      attribute :label_name,          Types::Strict::String

      attribute :main_artist,         Types::Strict::String
      attribute :local_ids,           Types::Collection(Types::String).default([])
      attribute :composers,           Types::Collection(Composer).default([])
      attribute :alternative_isrcs,   Types::Collection(AlternativeIsrc).default([])
      attribute :alternative_titles,  Types::Collection(AlternativeTitle).default([])
      attribute :tracks,              Types::Collection(Track).default([])
    end
  end
end
