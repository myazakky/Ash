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
    elsif (left_bracket? tokens[0]) && (latex? tokens[1]) && (many? :white?, tokens[2])
      read_at = tokens[3..].index(']') + 3
      literal = Literal.new(tokens[3..(read_at - 1)].inject(&:+), Kind::LATEX)
      analyse_helper(tokens[(read_at + 1)..], result + [literal], read_at + 1, false)
    elsif (left_bracket? tokens[0]) && !tokens[1].nil?
      content = analyse_helper(tokens[1..], [], 0, true)
      literal = Literal.new(content[0], Kind::LINK)
      read_at = content[1] + n
      analyse_helper(tokens[(read_at + 2)..], result + [literal], read_at + 1, false)
    elsif (right_bracket? tokens[0]) && by_bracket
      [result, n + 1]
    elsif (tokens[0].start_with? 'code:') && result.empty? && !by_bracket
      literal = Literal.new(tokens.inject(&:+), Kind::CODE, { code: '' })
      [[literal], 0]
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
    @row_lines.inject([]) do |result, row_line|
      tokens = tokenize row_line
      depth = if many? :white?, tokens[0]
        tokens[0].count(' ') + tokens[0].count('　')
      else
        0
      end
      if !result.empty? && result[-1][-1].kind == Kind::CODE && depth > 0
        result[-1][-1].data[:code] += "#{tokens.inject(&:+)[1..]}\n"
        result
      elsif !result.empty? &&
              result[-1][-1].kind == Kind::INDENT &&
              result[-1][-1].text[0].kind == Kind::CODE &&
              result[-1][-1].data[:depth] < depth
        result[-1][-1].text[0].data[:code] += "#{tokens.inject(&:+)[(result[-1][-1].data[:depth] + 1)..]}\n"
        result
      elsif depth.zero?
        new_item = (analyse_helper tokens, [], 0, false)[0]
        result + [new_item]
      else
        new_item = (analyse_helper tokens[1..], [], 0, false)[0]
        new_item = Literal.new(new_item, Kind::INDENT, { depth: depth })
        result + [[new_item]]
      end
    end
  end
end
