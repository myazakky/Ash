# frozen_string_literal: true

require 'rspec'
require_relative '../lib/tokenizer'

RSpec.describe Tokenizer do
  let(:tokenizer) { Class.new { extend Tokenizer } }

  describe '#tokenize' do
    it 'tokenize string' do
      result = tokenizer.tokenize(' [*** THIS IS TEST ] ok')
      expect(result).to eq [' ', '[', '***', ' ', 'THIS', ' ', 'IS', ' ', 'TEST', ' ', ']', ' ', 'ok']
    end

    it 'tokenize string that include strike' do
      result = tokenizer.tokenize '[--- Strike]'
      expect(result).to eq ['[', '---', ' ', 'Strike', ']']
    end

    it 'tokenize!!' do
      result = tokenizer.tokenize '[--**-- BoldStrike]'
      expect(result).to eq ['[', '--', '**', '--', ' ', 'BoldStrike', ']']
    end
  end
end
