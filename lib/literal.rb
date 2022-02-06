# frozen_string_literal: true

require_relative 'kind'

class Literal
  attr_reader :text, :kind, :data

  def initialize(text, kind, data = {})
    @text = text
    @kind = kind
    @data = data
  end

  def ==(other)
    @text == other.text &&
      @kind == other.kind &&
      @data == other.data
  end
end
