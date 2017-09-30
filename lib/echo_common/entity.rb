require 'echo_common'
require 'echo_common/error'
require 'hanami-model'

module EchoCommon

  class CreateOnlyAttributeError < EchoCommon::Error; end


  class Entity
    include ::Hanami::Entity

    def self.create_only_attributes(*attrs)
      attrs.each do |attr|
        self.attributes attr
        define_method "#{attr}=".to_sym do |val|
          if instance_variable_defined?("@#{attr}")
            raise CreateOnlyAttributeError.new "Illegal to set #{attr} more than once"
          end

          instance_variable_set "@#{attr}", val
        end
      end
    end

    def hash
      return super if id.nil?

      self.class.hash ^ id.hash
    end
  end
end
