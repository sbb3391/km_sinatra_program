require 'wicked_pdf'
require 'wkhtmltopdf-binary'

Mime::Type.register "application/pdf", :pdf

WickedPdf.config = {
  exe_path: '/home/sbb3391/.rvm/gems/ruby-2.6.1/bin/wkhtmltopdf',
  enable_local_file_access: true
}