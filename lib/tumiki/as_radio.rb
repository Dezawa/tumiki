module Tumiki
  module AsRadio
    def edit(model,with_id=nil)
      edit_or_disp(model,false)
    end
    def disp(model,with_id=nil)
      edit_or_disp(model,true)
    end

    def edit_or_disp(model,bool)
      content_tag(
        :nobr,
        safe_join(
          option[:correction].map{|value,key|
            safe_join([radio_button_tag( name(model,true), key,
                                         model.send(symbol) == key,
                                         disabled: bool),
                       value]
                     )
          }
        )
      )
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
