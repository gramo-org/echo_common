module EchoCommon
  # Default base error class used within Echo applications
  class Error < StandardError
  end


  # Validation error class
  #
  # Contains properties for which attribute has the error and what validation is has failed.
  #
  # Attributes
  #   attribute     -     which attribute is in an invalid state
  #   validation    -     which validation has failed? Can either be a
  #                       translation key or a translated error message
  #   translated    -     boolean flag to signal if the validation is already translated
  class ValidationError < Error
    attr_reader :attribute, :validation

    def initialize(attribute:, validation:, translated: false)
      @attribute, @validation = attribute.to_sym, validation
      @translated = translated
    end

    def translated?
      !!@translated
    end
  end
end
