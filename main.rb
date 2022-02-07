# frozen_string_literal: true

require_relative 'lib/page'
require 'json'

project_data = JSON.parse(File.read(ARGF.argv[0]))

html = project_data['pages'].map do |page|
  page = Page.new(page['lines'], project_data['name'])
  page.to_html
end.inject(&:+)

File.write("#{project_data['displayName']}.html", html)
