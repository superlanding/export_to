module ExportTo
  class Base < Struct.new(:records)
    class_attribute :head_titles
    class_attribute :body_keys
    class_attribute :presenter_klass
    class_attribute :join_relation

    # 預設 presenter
    self.presenter_klass = Presenter

    attr_accessor :object

    def to_csv
      CSV.generate do |csv|
        each do |columns, order, i|
          csv << columns
        end
      end
    end

    # 新版 Excel
    def to_xlsx
      io = StringIO.new
      book = WriteXLSX.new(io)
      sheet = book.add_worksheet

      # 表格頭 (粗體紅字)
      format_head = book.add_format.tap { |f| f.set_bold }.tap { |f| f.set_color('red') }

      each do |columns, order, x|
        columns.each_with_index do |column, y|
          sheet.write(x, y, column, format_head)
        end
      end

      book.close
      io.string
    end

    # 舊版 Excel
    def to_xls
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet

      each do |columns, order, x|
        sheet.row(x).concat(columns)
      end
      spreadsheet = StringIO.new
      book.write(spreadsheet)
      spreadsheet.string
    end

    protected

    def each
      i = 0
      yield(self.class.head_titles, nil, i)

      join_relation = self.class.join_relation

      self.records.each do |record|
        run_records = if join_relation.present? && record.send(join_relation).present?
          record.send(join_relation)
        else
          [ record ]
        end

        # 指定目前 order 讓 subclass 可以 override
        run_records.each do |run_record|
          i = i + 1
          self.object = if run_record != record
            self.class.presenter_klass.new(record, run_record)
          else
            self.class.presenter_klass.new(run_record)
          end
          yield(columns!, run_record, i)
        end
      end
    end

    class << self
      protected

      def set(title, key)
        self.head_titles ||= []
        self.body_keys ||= []
        self.head_titles.push(title)
        self.body_keys.push(key)
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
    end

    private

    def columns!
      self.class.body_keys.map do |key|
        data = object.send(key)
        data = data.gsub("\n", " ").gsub("\r", " ") if data.is_a?(String) 
        data
      end
    end
  end
end
