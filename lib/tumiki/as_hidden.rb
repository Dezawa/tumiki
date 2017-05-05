# coding: utf-8
module Tumiki
  module AsHidden
    # disableがないので、表示はtext
    def edit_(model,with_id=nil)
      hidden_field_tag name(model,with_id),
                     model.send(symbol),
                     {class: klass}
    end
    
    def disp(model,with_id=nil)
      hidden_field_tag  name(model,with_id),model.send(symbol)
    end
  end
end
