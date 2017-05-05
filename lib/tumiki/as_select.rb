# coding: utf-8
require 'pp'
module Tumiki
  module AsSelect
    # disableがないので、表示はtext
    
    # def edit_(model,with_id=nil)
    #   opt =
    #     {disabled: ( !editable?(model) || edit_on_table == :on_cell),
    #      id: id(model,with_id)
    #     }
    #   opt.merge!(style: "width:#{text_size}0px;") if text_size
    #   opt.merge!(class: klass ) if klass
    #   select(domain, with_id ? "#{model.id}][#{symbol}]":"#{symbol}",
    #          options_for_select(correction, model.send(symbol)),
    #          {include_blank: include_blank},
    #          opt #disabled: ( !editable?(model)),
    #          #id: id(model,with_id),
    #          #style: "width:#{text_size}0px;", class: "input-sm"
    #         )
    # end

    def edit_(model,with_id=nil)
      edit_or_disp(model,edit_on_table == :on_cell,with_id)
    end
    def disp(model,with_id=nil)
      edit_or_disp(model,true,with_id)
    end
      #editable ? edit_(model,with_id) : disp_(model)
    #end
    
    def edit_or_disp(model,bool,with_id)
      return correction_to_value(model) if text
      opt =
        {disabled: bool , #!( editable?(model) && edit_on_table == :editting),
         id: id(model,with_id)
        }
      #pp [ editable?(model) , edit_on_table, edit_on_table == :editting,!( editable?(model) && edit_on_table == :editting),opt]
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
