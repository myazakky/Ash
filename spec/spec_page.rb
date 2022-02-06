# frozen_string_literal: true

require 'rspec'
require_relative '../lib/page'
require_relative '../lib/kind'
require_relative '../lib/literal'

RSpec.describe Page do
  describe '#analyse' do
    it 'judge kind of [*** _] is BOLD' do
      lines = ['Hello', 'This is [*** Bold]']
      page = Page.new(lines)

      result = page.analyse
      expection = [[Literal.new('Hello', Kind::PLAIN)], [Literal.new('This is ', Kind::PLAIN), Literal.new([Literal.new('Bold', Kind::PLAIN)], Kind::BOLD)]]

      expect(result).to eq expection
    end

    it 'judge kind of [--- _] is strike' do
      lines = ['This is [-- Strike]']
      page = Page.new(lines)

      result = page.analyse
      expection = [[Literal.new('This is ', Kind::PLAIN), Literal.new([Literal.new('Strike', Kind::PLAIN)], Kind::STRIKE)]]

      expect(result).to eq expection
    end

    it ' judge others is PLAIN' do
      lines = ['Hello', '[$ \LaTex]', '[link]']
      page = Page.new(lines)

      page.analyse.each_with_index do |line, index|
        expect(line).to eq [Literal.new(lines[index], Kind::PLAIN)]
      end
    end
  end
end
