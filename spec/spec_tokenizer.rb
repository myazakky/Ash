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
  end
end
