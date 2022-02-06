# frozen_string_literal: true

require_relative 'kind'

class Literal
  attr_reader :text, :kind

  def initialize(text, kind)
    @text = text
    @kind = kind
  end

  def ==(other)
    @text == other.text &&
      @kind == other.kind
  end
end
