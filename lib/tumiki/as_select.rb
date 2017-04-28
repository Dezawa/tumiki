# coding: utf-8
require 'pp'
module Tumiki
  module AsSelect
    # disableがないので、表示はtext
    
    def edit(model,with_id=nil)
        select(domain, with_id ? "#{model.id}][#{symbol}]":"#{symbol}",
               options_for_select(option[:correction], model.send(symbol)),
               {include_blank: option[:include_blank]},
               disabled: ( !editable?(model)),
               id: "#{domain}_#{model.id}_#{symbol}",
               style: "width:#{text_size}0px;", class: "input-sm"
              )
    end
    
    def disp(model)
      case option[:correction].first
      when Array
        ary = option[:correction].rassoc( model.send(symbol))
        ary ? ary.first : ""
        #when String,Integer ;
      else
        option[:format] ? to_s_by_format(model) : model.send(symbol).to_s
      end
    end
  end
end
