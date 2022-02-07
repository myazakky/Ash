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

    it 'judge kind of [**--** _] is bold strike bold' do
      lines = ['[**--** StrikeBold]']
      page = Page.new(lines)

      result = page.analyse
      exception = [[
        Literal.new([
          Literal.new([
            Literal.new([
              Literal.new('StrikeBold', Kind::PLAIN)], Kind::BOLD)], Kind::STRIKE)], Kind::BOLD)]]

      expect(result).to eq exception
    end

    it 'judge kind of [__] is link' do
      lines = ['[link yeah]']
      page = Page.new(lines)

      expect(page.analyse).to eq [[Literal.new('link yeah', Kind::LINK)]]
    end

    it 'judge kind of [$ \Latex] is latex' do
      lines = ['[$ \LaTex]']

      page = Page.new(lines)
      expect(page.analyse).to eq [[Literal.new('\LaTex', Kind::LATEX)]]
    end

    it 'analyse code' do
      lines = [
        ' code:example.rb',
        '  list = [',
        '    1, 2, 3',
        '  ]',
        '  EOF',
        'end'
      ]
      page = Page.new(lines)
      expection = [
        [Literal.new([Literal.new('code:example.rb', Kind::CODE, {
          code: """list = [
  1, 2, 3
]
EOF
"""
        })], Kind::INDENT, { depth: 1 })],
        [Literal.new('end', Kind::PLAIN)]
      ]

      expect(page.analyse).to eq expection
    end

    it 'judge kind of `[aa]` is codeblock'do
      lines = ['`[aa]`']
      page = Page.new(lines)

      expection = [[Literal.new(Literal.new('[aa]', Kind::PLAIN), Kind::CODEBLOCK)]]
      expect(page.analyse).to eq expection
    end

    it ' judge others is PLAIN' do
      lines = ['Hello', 'Test']
      page = Page.new(lines)

      page.analyse.each_with_index do |line, index|
        expect(line).to eq [Literal.new(lines[index], Kind::PLAIN)]
      end
    end
  end
end
