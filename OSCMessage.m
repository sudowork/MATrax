classdef OSCMessage < event.EventData
  properties
    path
    data
  end

  methods
    function event = OSCMessage(path, data)
      event.path = path;
      event.data = data;
    end
  end
end
