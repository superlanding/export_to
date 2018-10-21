module ExportTo
  class Presenter
    attr_accessor :model, :relation
    NoAttributeError = Class.new(NoMethodError)

    def initialize(model, relation=nil)
      self.model = model
      self.relation = relation
    end

    def relation?
      relation != nil
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
