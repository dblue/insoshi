Factory.define :preference do |p|
  p.domain 'example.com'
  p.server_name 'server.example.net'
  p.app_name 'Example'
  p.smtp_server 'smtp.example.com'
  p.email_notifications true
  p.email_verifications false
  p.analytics '<script>Google analytics</script>'
end