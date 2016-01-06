require 'echo_common'
require 'echo_common/error'
require 'lotus-model'

module EchoCommon

  class CreateOnlyAttributeError < EchoCommon::Error; end


  class Entity
    def self.inherited(subclass)
      subclass.include ::Lotus::Entity
    end

    def self.create_only_attributes(*attrs)
      attrs.each do |attr|
        attr_reader attr
        self.attributes << attr
        define_method "#{attr}=".to_sym do |val|
          raise CreateOnlyAttributeError.new "Illegal to set #{attr} more than once" if instance_variable_defined?("@#{attr}")
          instance_variable_set "@#{attr}", val
        end
      end
    end


  end
end
