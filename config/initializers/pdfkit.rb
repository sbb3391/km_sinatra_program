PDFKit.configure do |config|
  # config.wkhtmltopdf = '/path/to/wkhtmltopdf'
  config.wkhtmltopdf = '/home/sbb3391/.rvm/gems/ruby-2.6.1/bin/wkhtmltopdf'
  config.default_options = {
    :page_size => 'Legal',
    :print_media_type => true
  }
  # # Use only if your external hostname is unavailable on the server.
  # config.root_url = "http://localhost"
  # config.verbose = false
end