module Tumiki
  module KlassDateTime
    def to_s_by_format(model)
      model.send(symbol) ? model.send(symbol).strftime(option[:format]) : ""
    end
  end
end
