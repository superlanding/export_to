module ExportTo
  class Presenter
    attr_accessor :model, :relation, :x, :y
    NoAttributeError = Class.new(NoMethodError)

    def initialize(model, relation=nil, x, y)
      self.model, self.relation = model, relation
      self.x, self.y = x, y
    end

    def relation?
      relation.present?
    end

    def method_missing(m, *args, &block)
      obj = relation.respond_to?(m) ? relation : model
      if block_given?
        obj.public_send(m, *args, &block)
      else
        obj.public_send(m, *args)
      end
    end
  end
end
