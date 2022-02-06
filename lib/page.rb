# frozen_string_literal: true

require_relative 'literal'
require_relative 'kind'

class Page
  def initialize(row_lines)
    @row_lines = row_lines
  end

  def analyse
    @row_lines.map do |row_line|
      Literal.new(row_line, Kind::PLAIN)
    end
  end
end
