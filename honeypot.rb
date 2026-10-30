require 'socket'

PORT = 8080
server = TCPServer.new('0.0.0.0', PORT)
puts "=========================================================="
puts "🤖 HONEYPOT ATIVO - Escutando na porta #{PORT}..."
puts "=========================================================="

loop do
  Thread.start(server.accept) do |client|
    sockaddr = client.peeraddr
    ip_invasor = sockaddr[3]
    porta_origem = sockaddr[1]
    
    time = Time.now.strftime("%d/%m/%Y às %H:%M:%S")
    navegador = "Desconhecido/Bot Automatizado"
    idioma = "Não informado (Provável Bot)"
    
    puts "\n[🟢 CONEXÃO ATIVA] Dispositivo #{ip_invasor} conectou!"

    while line = client.gets
      break if line == "\r\n" || line.strip.empty?
      
      if line.match(/^User-Agent:/i)
        navegador = line.split(':', 2)[1].strip
      elsif line.match(/^Accept-Language:/i)
        idioma = line.split(':', 2)[1].split(',')[0].strip
      end
    end
    
    puts "═"*60
    puts "⚠️  [ALERTA DE VARREDURA DETECTADA]"
    puts "═"*60
    puts "📅 DATA/HORA : #{time}"
    puts "🌐 ORIGEM    : #{ip_invasor} (Porta: #{porta_origem})"
    puts "🗣️  IDIOMA    : #{idioma}"
    puts "💻 NAVEGADOR : #{navegador}"
    puts "═"*60

    body = "<h1>Apache Server</h1>"
    client.print "HTTP/1.1 200 OK\r\n"
    client.print "Content-Type: text/html\r\n"
    client.print "Content-Length: #{body.bytesize}\r\n"
    client.print "Connection: keep-alive\r\n\r\n"
    client.print body
    
    begin
      client.read(1)
    rescue
      # Conexão encerrada pelo cliente
    end

    puts "[🔴 CONEXÃO FINALIZADA] O invasor #{ip_invasor} fechou a página ou saiu."
  end
end
