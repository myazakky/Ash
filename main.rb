# frozen_string_literal: true

require_relative 'lib/page'
require 'json'

project_data = JSON.parse(File.read(ARGF.argv[0]))

body = project_data['pages'].map do |page|
  page = Page.new(page['lines'], project_data['name'])
  page.to_html
end.inject(&:+)

html = ''"
<!DOCTYPE HTML>
<html>
<head>
<meta charset='UTF-8'>
<link type='text/css' rel='stylesheet' href='./statics/style.css'>
</head>
<body>
#{body}
</body>
<html>
"''

File.write("#{project_data['displayName']}.html", html)
