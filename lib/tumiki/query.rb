# coding: utf-8
module Tumiki
  module Query
    def find_query filter_list
      arels = filter_list.map{|filt| filt.to_arel}.compact
      return nil if arels.empty?
      arel = arels.shift
      arels.inject(arel){|sum,arg| sum.and arg }
    end
  end

end
