module ExportTo
  class Base < Struct.new(:records)
    class_attribute :options
    class_attribute :head_titles
    class_attribute :body_keys
    class_attribute :column_formats
    class_attribute :body_column_proc

    class_attribute :presenter_klass
    class_attribute :join_relation
    class_attribute :each_proc, :each_method

    # 預設 presenter
    self.presenter_klass = Presenter
    self.each_method = :each

    attr_accessor :object

    def to_csv
      ExportTo::Exporter::Csv.new(self).export
    end

    # 新版 Excel
    def to_xlsx
      ExportTo::Exporter::Xlsx.new(self).export
    end

    # 舊版 Excel
    def to_xls
      ExportTo::Exporter::Xlsx.new(self).export
    end

    def each
      data = []
      rows! do |columns, model, x|
        data.push(columns)
      end
      data
    end

    def each!
      i = 0

      yield(self.class.head_titles, nil, i)

      join_relation = self.class.join_relation

      each_models do |record, x|
        run_records = if join_relation.present? && record.send(join_relation).present?
          record.send(join_relation)
        else
          [ record ]
        end

        # 指定目前 order 讓 subclass 可以 override
        run_records.each_with_index do |run_record, y|
          i = i + 1
          object = if run_record != record
            self.class.presenter_klass.new(record, run_record, x, y)
          else
            self.class.presenter_klass.new(run_record, nil, x, y)
          end

          each_proc.call(object) if self.class.each_proc.present?

          columns = fetch_columns!(object)

          yield(columns, run_record, i)
        end
      end
    end

    private

    def each_models(&block)
      case self.class.each_method
      when :each
        records.each.with_index(&block)
      when :find_in_batches
        find_in_batches(&block)
      end
    end

    def find_in_batches
      i = 0
      records.find_in_batches do |group|
        group.each do |model|
          yield(model, i)
          i = i + 1
        end
      end
    end

    class << self

      protected

      def excel(options)
        self.options = options
      end

      def set(title, key, format: {}, &block)
        self.head_titles ||= []
        self.body_keys ||= []
        self.column_formats ||= []
        self.body_column_proc ||= []

        self.head_titles.push(title)
        self.body_keys.push(key)
        self.column_formats.push(format)
        self.body_column_proc.push(block)
      end

      def presenter(&block)
        # 依序尋找繼承關係的 presenter
        parent_klass = ancestors.find { |klass|
          klass.respond_to?(:presenter_klass) && !klass.presenter_klass.nil?
        }
        # 建立當下的 presenter 內容
        klass = Class.new(parent_klass.presenter_klass, &block)

        # 註冊成為 presenter class
        const_set(:Presenter, klass)
        self.presenter_klass = const_get(:Presenter)
      end

      def joins(relation)
        self.join_relation = relation
      end

      def each_with(&block)
        self.each_proc = block
      end
    end

    private

    def fetch_columns!(object)
      self.class.body_keys.map.with_index do |key, i|
        data = case key
        when String
          key
        when Symbol
          (object.send(key) || "")
        end

        column_proc = self.class.body_column_proc[i]
        data = self.class.body_column_proc[i].call(data) if column_proc.present?
        data
      end
    end
  end
end
