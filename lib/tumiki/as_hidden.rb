# coding: utf-8
module Tumiki
  module AsHidden
    # disableがないので、表示はtext
    def edit(model,with_id=nil)
      hidden_field_tag name(model,with_id),
                     model.send(symbol),
                     {style: "width:#{text_size}0px;", class: klass}
    end
    
    def disp(model,with_id=nil)
      hidden_field_tag  name(model,with_id),model.send(symbol)
    end
  end
end
