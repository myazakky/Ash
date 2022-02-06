# frozen_string_literal: true

require 'rspec'
require_relative '../lib/page'
require_relative '../lib/kind'
require_relative '../lib/literal'

RSpec.describe Page do
  describe '#analyse' do
    it ' judge all text is PLAIN' do
      lines = ['Hello', '[** Bold]', '[$ \LaTex]', '[link]']
      page = Page.new(lines)

      page.analyse.each_with_index do |line, index|
        expect(line).to eq Literal.new(lines[index], Kind::PLAIN)
      end
    end
  end
end
