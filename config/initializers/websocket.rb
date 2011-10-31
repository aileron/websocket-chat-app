fork do
  EM::run do
    p "running websocket server ... [8081]"
    @channel = EM::Channel.new
    EM::WebSocket.start(:host => "0.0.0.0", :port => 8081) do |ws|
      ws.onopen {
        uid = @channel.subscribe{|mes|
          ws.send(mes)
        }
        p"<#{uid}> connected"
        @channel.push( "{type:'notify', body:'open #{uid}'}" )
        ws.onmessage {|mes|
          p"<#{uid}> #{mes}"
          data = JSON.parse( mes )
          data[ :type] = 'message'
          data[ :uid ] = uid
          @channel.push( data.to_json )
        }
        ws.onclose {
          p"<#{uid}> disconnected"
          @channel.unsubscribe(uid)
          @channel.push( "{type:'notify', body:'close #{uid}'}" )
        }
      }
    end
  end
end
