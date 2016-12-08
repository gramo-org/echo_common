require 'echo_common'
require 'echo_common/error'
require 'hanami-model'

module EchoCommon
  class Entity < ::Hanami::Entity
    def self.create_only_attributes(*)
      raise <<-TXT


        No longer supported. Schema on entity is frozen after definition.

        If we where to suppport this, Thorbjørn think it needs to make it's
        way in to hanami's attributes DSL.

        See:
          - https://github.com/hanami/model/blob/8775b815edfaef38a1d98cdd83704bbcf2c553f9/lib/hanami/entity.rb#L84-L87
          - https://github.com/hanami/model/blob/8775b815edfaef38a1d98cdd83704bbcf2c553f9/lib/hanami/entity/schema.rb#L139-L144

      TXT
    end
  end
end
