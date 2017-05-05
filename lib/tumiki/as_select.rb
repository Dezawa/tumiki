# coding: utf-8
require 'pp'
module Tumiki
  module AsSelect
    def edit_(model,with_id=nil)
      edit_or_disp(model,edit_on_table == :on_cell,with_id)
    end
    def disp(model,with_id=nil)
      edit_or_disp(model,true,with_id)
    end
    
    def edit_or_disp(model,bool,with_id)
      return correction_to_value(model) if text
      opt =
        {disabled: bool , id: id(model,with_id) }
      opt.merge!(style: "width:#{text_size}0px;") if text_size
      opt.merge!(class: klass ) if klass
      select(domain, with_id ? "#{model.id}][#{symbol}":"#{symbol}",
             options_for_select(correction, model.send(symbol)),
             {include_blank: include_blank},
             opt
            )
    end
    def disp_(model)
      correction_to_value( model )
    end
  end
end
