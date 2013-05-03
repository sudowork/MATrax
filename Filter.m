classdef Filter < handle

  methods (Static)
    function filt = makeFIR(b)
      filt = dsp.FIRFilter('Numerator', b);
    end

    function filt = makeIIR(b, a)
      filt = dsp.IIRFilter('Numerator', b, 'Denominator', a);
    end
  end

end
