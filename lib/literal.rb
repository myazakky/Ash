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
    when Kind::PLAIN then "<span class='plain'>#{@text}</span>"
    when Kind::BOLD then "<b class='bold'>#{@text.map(&:to_html).inject(&:+)}</b>"
    when Kind::STRIKE then "<strike class='strike'>#{@text.map(&:to_html).inject(&:+)}</strike>"
    when Kind::LINK then "<a href='#{data[:link]}/#{@text}' class='link'>#{@text}</a>"
    when Kind::LATEX then Katex.render @text
    when Kind::CODE
      "<code class='code'>#{@data[:code]}</code>"
    when Kind::INDENT
      "<span class='indent' style='margin-left: #{@data[:depth]}em'>#{@text.map(&:to_html).inject(&:+)}</span>"
    when Kind::CODEBLOCK then "<span class='codeblock'>#{@text}</span>"
    end
  end
end
