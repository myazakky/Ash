# frozen_string_literal: true

module Tokenizer
  def left_bracket?(c)
    c == '['
  end

  def right_bracket?(c)
    c == ']'
  end

  def bold?(c)
    c == '*'
  end

  def white?(c)
    [' ', '　'].include?(c)
  end

  def many?(condition, text)
    return false if text.nil?

    return true if text.empty?

    method(condition).call(text[0]) && many?(condition, text[1..])
  end

  def tokenize_helper(s, result, want_next)
    return result if s.empty?

    if left_bracket? s[0]
      tokenize_helper(s[1..], result + ['['], :any)
    elsif right_bracket? s[0]
      tokenize_helper(s[1..], result + [']'], :any)
    elsif (white? s[0]) && want_next == :white
      result[-1] += s[0]
      tokenize_helper(s[1..], result, :white)
    elsif white? s[0]
      tokenize_helper(s[1..], result + [s[0]], :white)
    elsif (bold? s[0]) && want_next == :bold
      result[-1] += s[0]
      tokenize_helper(s[1..], result, :bold)
    elsif bold? s[0]
      tokenize_helper(s[1..], result + [s[0]], :bold)
    elsif want_next != :any
      tokenize_helper(s[1..], result + [s[0]], :any)
    else
      result[-1] += s[0]
      tokenize_helper(s[1..], result, :any)
    end
  end

  def tokenize(s)
    tokenize_helper(s, [], [])
  end
end
