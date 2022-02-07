# frozen_string_literal: true

require_relative 'literal'
require_relative 'kind'
require_relative 'tokenizer'

class Page
  include Tokenizer

  def initialize(row_lines, project)
    @row_lines = row_lines
    @project = project
  end

  def analyse_helper(tokens, result, n, by_bracket)
    return [result, n] if tokens.nil? || tokens.empty?

    if (left_bracket? tokens[0]) && (many? :decoration?, tokens[1]) && ((many? :white?, tokens[2]) || (many? :decoration?, tokens[2]))
      # Case of decorated notations like [**-- Hi]
      if many? :white?, tokens[2]
        content = analyse_helper(tokens[3..], [], 0, true)
        read_at = content[1] + n + 2
      else
        content = analyse_helper(['['] + tokens[2..], [], 0, true)
        read_at = content[1] + n + 1
      end
      literal = many?(:bold?, tokens[1]) ? Literal.new(content[0], Kind::BOLD) : Literal.new(content[0], Kind::STRIKE)

      analyse_helper(tokens[(read_at + 1)..], result + [literal], read_at + 1, false)
    elsif backquote? tokens[0]
      # Case of command line like `hello`
      next_backquote = tokens[1..].index('`') + 1
      literal = Literal.new(Literal.new(tokens[1..(next_backquote - 1)].inject(&:+), Kind::PLAIN), Kind::CODEBLOCK)
      analyse_helper(tokens[(next_backquote + 1)..], result + [literal], next_backquote + 1, false)
    elsif (left_bracket? tokens[0]) && (latex? tokens[1]) && (many? :white?, tokens[2])
      # Case of latex like [$ \LaTex]
      read_at = tokens[3..].index(']') + 3
      literal = Literal.new(tokens[3..(read_at - 1)].inject(&:+), Kind::LATEX)
      analyse_helper(tokens[(read_at + 1)..], result + [literal], read_at + 1, false)
    elsif (left_bracket? tokens[0]) && !tokens[1].nil?
      # Case of link like [Scrapbox is a God tool]
      next_bracket = tokens[1..].index(']') + 1
      literal = Literal.new(tokens[1..(next_bracket - 1)].inject(&:+), Kind::LINK, { link: "https://scrapbox.io/#{@project}" })
      analyse_helper(tokens[(next_bracket + 1)..], result + [literal], next_bracket + 1, false)
    elsif (right_bracket? tokens[0]) && by_bracket
      [result, n + 1]
    elsif (tokens[0].start_with? 'code:') && result.empty? && !by_bracket
      # Case of code block like code:example.rb
      literal = Literal.new(tokens.inject(&:+), Kind::CODE, { code: '' })
      [[literal], 0]
    elsif !result.empty? && result[-1].kind == Kind::PLAIN
        literal = Literal.new(result[-1].text + tokens[0], Kind::PLAIN)
        result[-1] = literal
        analyse_helper(tokens[1..], result, n + 1, by_bracket)
    else
      literal = Literal.new(tokens[0], Kind::PLAIN)
      analyse_helper(tokens[1..], result + [literal], n + 1, by_bracket)
    end
  end

  def analyse
    @row_lines.inject([]) do |result, row_line|
      tokens = tokenize row_line
      depth = many?(:white?, tokens[0]) ? tokens[0].count(' ') + tokens[0].count('　') + tokens[0].count("\t") : 0

      if !result.empty? && !result[-1].empty? && result[-1][-1].kind == Kind::CODE && depth > 0
        result[-1][-1].data[:code] += "#{tokens.inject(&:+)[1..]}\n"
        result
      elsif !result.empty? && !result[-1].empty? && result[-1][-1].kind == Kind::INDENT && result[-1][-1].text[0].kind == Kind::CODE && result[-1][-1].data[:depth] < depth
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
