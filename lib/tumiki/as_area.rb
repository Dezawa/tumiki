# coding: utf-8
module Tumiki
  module AsArea
    # disableがないので、表示はtext
    
    def edit(model,with_id=nil)
      text_area_tag name(model,with_id),
                     model.send(symbol),
                     { class: klass}.merge(option[:area_option]||{})
    end
    
    def disp(model)
      text_area_tag name(model),
                     model.send(symbol),
                     {class: klass,disabled: true}.merge(option[:area_option]||{})
    end
  end
end
