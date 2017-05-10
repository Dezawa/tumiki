# coding: utf-8
require 'pp'
module Tumiki
  module AsSelect
    def edit_(model,with_id=nil)
      disable = !(editable?(model) && edit_on_table == :editting)
      edit_or_disp(model, disable,with_id)
    end
    def disp(model,with_id=nil)
      edit_or_disp(model,true,with_id)
    end

    # text: true でも String にならないのは、
    # editable かつ edit_on_table: :editting の場合。
    def edit_or_disp(model,disable,with_id)
      if text &&  ![:on_cell,:editting].include?(edit_on_table)
        return correction_to_value(model)
      end
      opt = {disabled: disable , id: id(model,with_id) }
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
