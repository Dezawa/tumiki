module Tumiki
  module AsRadio
    def edit_(model,with_id=nil)
      edit_or_disp(model,edit_on_table == :on_cell,with_id)
    end
    def disp(model,with_id=nil)
      edit_or_disp(model,true,with_id)
    end

    def edit_or_disp(model,bool,with_id)
      return correction_to_value(model) if text
      content_tag(
        :nobr,
        safe_join(
          correction.map{|lbl,value|
            key = value || lbl
            #pp id(model,key,with_id)
            safe_join([radio_button_tag( name(model,with_id), key,
                                         model.send(symbol) == key,
                                         disabled: bool,
                                         class: klass),
                       content_tag(:label,lbl,for: id(model,key,with_id))]
                     )
          }
        )
      )
    end
      
    def id model,key,with_id
      #pp [ model,key,with_id]
      if with_id
        "#{domain}_#{model.id}_#{symbol}_#{key}"
      else
        "#{domain}_#{symbol}_#{key}"
      end
      #pp [model,key,with_id,ret]
      #ret
    end
    
    # def disp_text(model)
    #   pp domain
    #   safe_join(
    #     option[:correction].map{|value,key|
    #       safe_join([radio_button_tag( "#{domain}[#{model.id}][#{symbol}]", key,
    #                                 model.send(symbol) == key,
    #                                 disabled: !(edit_on_table==:edit && editable?(model))),
    #                  value]
    #                )
    #     }
    #   )
    # end
  end
end
