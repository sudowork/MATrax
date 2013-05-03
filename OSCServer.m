classdef OSCServer < handle
  properties (Access=private)
    server  % server handle
    ip      % IP of server
    port    % port to run OSC server on
    running % whether or not server is running
    pollQ   % Timer-based callback to check message queue
  end

  events
    NewMessage  % triggered when new message arrives
  end

  methods (Access=private)
    function ip = getLocalIP(~)
      address = java.net.InetAddress.getLocalHost;
      ip = char(address.getHostAddress);
    end

    function checkMessages(this)
      if this.running
        % notify on all messages in queue
        m = osc_recv(this.server, 5);
        if ~isempty(m)
          for i=1:length(m)
            notify(this, 'NewMessage',...
                   OSCMessage(m{i}.path, m{i}.data));
          end
        end
      end
    end
  end

  methods
    function this = OSCServer(port)
      this.port = port;
      this.running = false;
      this.pollQ = timer(...
                         'ExecutionMode', 'fixedRate',...
                         'Period', .1,...
                         'TimerFcn', @(~,~) this.checkMessages());
    end

    function start(this)
      % set IP and running status
      this.ip = this.getLocalIP()
      this.running = true;
      % start OSC server on port
      this.server = osc_new_server(this.port);
      % start polling message queue
      start(this.pollQ);
      % log server start
      Console.log(sprintf('OSC server started on %s:%d',...
                          this.ip, this.port));
    end

    function stop(this)
      if ischar(this.server)
        % stop running
        this.running = false;
        % stop polling queue
        stop(this.pollQ);
        % release server port
        osc_free_server(this.server);
        this.server = false;
        Console.log('OSC server stopped');
      else
        Console.log('Could not stop OSC Server - was not running');
      end
    end

    function delete(this)
      this.stop();
      delete(this.pollQ);
    end
  end
end
