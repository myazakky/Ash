# frozen_string_literal: true

require_relative 'kind'
require 'katex'

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

  def to_html
    case @kind
    when Kind::PLAIN then "<span>#{@text}</span>"
    when Kind::BOLD then "<b>#{@text.map(&:to_html).inject(&:+)}</b>"
    when Kind::STRIKE then "<strike>#{@text.map(&:to_html).inject(&:+)}</strike>"
    when Kind::LINK then "<a href='#{data[:link]}#{@text}'>#{@text}</a>"
    when Kind::LATEX then Katex.render @text
    when Kind::CODE
      "<code style='background-color: gray; display: block;'>#{@data[:code]}</code>"
    when Kind::INDENT
      "<span style='margin-left: #{@data[:depth]}em'>#{@text.map(&:to_html).inject(&:+)}</span>"
    when Kind::CODEBLOCK then "<span style='background-color: gray'>#{@text}</span>"
    end
  end
end
