module Advertisements
  class Content

    attr_reader :text

    MissingContent = Class.new(StandardError)

    def initialize(text)
      raise MissingContent if text.nil? || text.strip.empty?
      @text = text.freeze
    end

    def to_s
      text
    end

    def eql?(other)
      other.instance_of?(Content) && text.eql?(other.text)
    end

    alias == eql?

    def hash
      text.hash
    end
  end
end
