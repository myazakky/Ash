# frozen_string_literal: true

require_relative 'literal'
require_relative 'kind'
require_relative 'tokenizer'

class Page
  include Tokenizer

  def initialize(row_lines)
    @row_lines = row_lines
  end

  def analyse_helper(tokens, result, n, by_bracket)
    return [result, n] if tokens.nil? || tokens.empty?

    if (left_bracket? tokens[0]) && (many? :bold?, tokens[1]) && ((many? :white?, tokens[2]) || (many? :decoration?, tokens[2]))
      if many? :white?, tokens[2]
        content = analyse_helper(tokens[3..], [], 0, true)
        read_at = content[1] + n + 1
      else
        content = analyse_helper(['['] + tokens[2..], [], 0, true)
        read_at = content[1] + n
      end

      literal = Literal.new(content[0], Kind::BOLD)
      analyse_helper(tokens[(read_at + 2)..], result + [literal], read_at + 1, false)
    elsif (left_bracket? tokens[0]) && (many? :strike?, tokens[1]) && ((many? :white?, tokens[2]) || (many? :decoration?, tokens[2]))
      if many? :white?, tokens[2]
        content = analyse_helper(tokens[3..], [], 0, true)
        read_at = content[1] + n + 1
      else
        content = analyse_helper(['['] + tokens[2..], [], 0, true)
        read_at = content[1] + n
      end

      literal = Literal.new(content[0], Kind::STRIKE)
      analyse_helper(tokens[(read_at + 2)..], result + [literal], read_at + 1, false)
    elsif (left_bracket? tokens[0]) && !tokens[1].nil?
      p tokens
      content = analyse_helper(tokens[1..], [], 0, true)
      literal = Literal.new(content[0], Kind::LINK)
      read_at = content[1] + n
      analyse_helper(tokens[(read_at + 2)..], result + [literal], read_at + 1, false)
    elsif (right_bracket? tokens[0]) && by_bracket
      [result, n + 1]
    elsif result.size.zero?
      literal = Literal.new(tokens[0], Kind::PLAIN)
      analyse_helper(tokens[1..], [literal], n + 1, by_bracket)
    else
      pre_literal = result[-1]
      literal = Literal.new(pre_literal.text + tokens[0], Kind::PLAIN)
      result[-1] = literal
      analyse_helper(tokens[1..], result, n + 1, by_bracket)
    end
  end

  def analyse
    @row_lines.map do |row_line|
      tokens = tokenize(row_line)
      analyse_helper(tokens, [], 0, false)[0]
    end
  end
end
