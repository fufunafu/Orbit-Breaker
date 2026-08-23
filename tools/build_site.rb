#!/usr/bin/env ruby
# frozen_string_literal: true

# Renders the public GitHub Pages documents from their Markdown sources so the
# published policy and support text can never drift from the repository copies.
#
#   ruby tools/build_site.rb            # writes docs/privacy.html and docs/support.html
#   ruby tools/build_site.rb --check    # exits 1 if the committed HTML is stale
#
# The converter supports the subset of Markdown used by the docs: ATX headings,
# paragraphs, bullet and numbered lists, **bold**, `code`, [text](url) links,
# <https://autolinks>, <email@autolinks>, and literal <br> tags.

require "cgi"

PAGES = {
  "docs/PRIVACY_POLICY.md" => { output: "docs/privacy.html", title: "Orbit Breaker Privacy Policy", description: "How the Orbit Breaker iPhone game handles local game data, Game Center, and TestFlight information." },
  "docs/SUPPORT.md" => { output: "docs/support.html", title: "Orbit Breaker Support", description: "Gameplay help, troubleshooting, and how to report a problem with the Orbit Breaker iPhone game." },
}.freeze

MIRRORS = {
  "docs/PRIVACY_POLICY.md" => "PRIVACY.md",
  "docs/SUPPORT.md" => "SUPPORT.md",
}.freeze

STYLE = <<~CSS.strip
  body{margin:0;background:#030615;color:#eaffff;font:17px system-ui,-apple-system,sans-serif;line-height:1.65}
  main{max-width:760px;margin:auto;padding:48px 24px}
  h1{font-size:38px;line-height:1.15;color:#75f8ff}
  h2{margin-top:2em;font-size:24px;color:#75f8ff}
  h3{margin-top:1.5em;font-size:19px}
  a{color:#ff78e8}
  code{font-family:ui-monospace,SFMono-Regular,Menlo,monospace;font-size:0.92em;background:#0d1b33;padding:0 4px;border-radius:4px}
  nav{max-width:760px;margin:auto;padding:0 24px 48px;font-size:15px}
  nav a{margin-right:20px}
CSS

def inline(text)
  escaped = CGI.escapeHTML(text).gsub("&lt;br&gt;", "<br>")
  escaped = escaped.gsub(/&lt;(https?:\/\/[^&]+)&gt;/) { %(<a href="#{Regexp.last_match(1)}">#{Regexp.last_match(1)}</a>) }
  escaped = escaped.gsub(/&lt;([^\s&@]+@[^\s&]+)&gt;/) { %(<a href="mailto:#{Regexp.last_match(1)}">#{Regexp.last_match(1)}</a>) }
  escaped = escaped.gsub(/\[([^\]]+)\]\(([^)]+)\)/) { %(<a href="#{Regexp.last_match(2)}">#{Regexp.last_match(1)}</a>) }
  escaped = escaped.gsub(/\*\*([^*]+)\*\*/) { "<strong>#{Regexp.last_match(1)}</strong>" }
  escaped.gsub(/`([^`]+)`/) { "<code>#{Regexp.last_match(1)}</code>" }
end

def render_body(markdown)
  html = []
  paragraph = []
  list_tag = nil

  flush_paragraph = lambda do
    next if paragraph.empty?

    html << "<p>#{inline(paragraph.join(' '))}</p>"
    paragraph.clear
  end
  close_list = lambda do
    next unless list_tag

    html << "</#{list_tag}>"
    list_tag = nil
  end

  markdown.each_line do |raw|
    line = raw.chomp
    if line.strip.empty?
      flush_paragraph.call
      close_list.call
    elsif (heading = line.match(/\A(#{'#'}{1,3})\s+(.+)\z/))
      flush_paragraph.call
      close_list.call
      level = heading[1].length
      html << "<h#{level}>#{inline(heading[2])}</h#{level}>"
    elsif (item = line.match(/\A\s*[-*]\s+(.+)\z/))
      flush_paragraph.call
      if list_tag != "ul"
        close_list.call
        list_tag = "ul"
        html << "<ul>"
      end
      html << "<li>#{inline(item[1])}</li>"
    elsif (item = line.match(/\A\s*\d+\.\s+(.+)\z/))
      flush_paragraph.call
      if list_tag != "ol"
        close_list.call
        list_tag = "ol"
        html << "<ol>"
      end
      html << "<li>#{inline(item[1])}</li>"
    elsif list_tag && line.start_with?("  ")
      html[-1] = html[-1].sub(%r{</li>\z}, " #{inline(line.strip)}</li>")
    else
      close_list.call
      paragraph << line.strip
    end
  end
  flush_paragraph.call
  close_list.call
  html.join("\n")
end

def render_page(markdown, title:, description:)
  <<~HTML
    <!doctype html>
    <html lang="en">
    <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="description" content="#{CGI.escapeHTML(description)}">
    <title>#{CGI.escapeHTML(title)}</title>
    <style>#{STYLE}</style>
    </head>
    <body>
    <main>
    #{render_body(markdown)}
    </main>
    <nav><a href="index.html">Orbit Breaker</a><a href="support.html">Support</a><a href="privacy.html">Privacy policy</a></nav>
    </body>
    </html>
  HTML
end

check = ARGV.include?("--check")
stale = []

PAGES.each do |source, page|
  rendered = render_page(File.read(source), title: page[:title], description: page[:description])
  if check
    stale << page[:output] unless File.exist?(page[:output]) && File.read(page[:output]) == rendered
  else
    File.write(page[:output], rendered)
  end
end

MIRRORS.each do |source, mirror|
  content = File.read(source)
  if check
    stale << mirror unless File.exist?(mirror) && File.read(mirror) == content
  else
    File.write(mirror, content)
  end
end

if check
  abort "stale generated files: #{stale.join(', ')} (run ruby tools/build_site.rb)" unless stale.empty?
  puts "ORBIT_BREAKER_SITE_OK"
else
  puts "ORBIT_BREAKER_SITE_BUILT"
end
