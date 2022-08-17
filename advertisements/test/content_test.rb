require_relative 'test_helper'

module Advertisements
  class ContentTest  < ActiveSupport::TestCase

    test "cant's change internals" do
      content = Content.new("Old content")
      assert_raises do
        content.text["Old"] = "New"
      end
    end

    test "can't create content without text" do
      assert_raises(Content::MissingContent) do
        Content.new("")
      end

      assert_raises(Content::MissingContent) do
        Content.new("     ")
      end

      assert_raises(Content::MissingContent) do
        Content.new(nil)
      end
    end

    test "content's string representation should return text" do
      text_content = "Random content: #{SecureRandom.hex}"
      assert_equal text_content, Content.new(text_content).to_s
    end

    test "content objects with the same text should be equal" do
      text_content = "Random content: #{SecureRandom.hex}"

      assert Content.new(text_content).eql? Content.new(text_content)
      assert Content.new(text_content) == Content.new(text_content)
    end

    test "content objects with different text should not be equal" do
      text_content_1 = "Random content: #{SecureRandom.hex}"
      text_content_2 = "Random content: #{SecureRandom.hex}"

      assert_not Content.new(text_content_1).eql? Content.new(text_content_2)
      assert_not Content.new(text_content_1) == Content.new(text_content_2)
    end
  end
end
