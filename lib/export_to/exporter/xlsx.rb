module ExportTo
  module Exporter
    class Xlsx < Struct.new(:rows)

      def export
        rows.each! do |columns, model, x|
          worksheet.write_row(x, columns)
        end

        workbook.read_string
      end

      protected

      def workbook
        @workbook ||= FastExcel.open(constant_memory: true)
      end

      def worksheet
        @worksheet ||= begin
          ws = workbook.add_worksheet(options.fetch(:worksheet) { "Default" })
          ws.auto_width = true if auto_width?
          ws.set_row(0, height, bold)
          ws
        end
      end

      def bold
        workbook.bold_cell_format
      end

      def options
        @options ||= (rows.options || {})
      end

      def worksheet_name
        options.fetch(:worksheet) { "Default" }
      end

      def auto_width?
        options.fetch(:auto_width) { true }
      end

      def height
        options.fetch(:height) { 10 }
      end

    end
  end
end
