module ExportTo
  module Exporter
    class Xlsx < Struct.new(:rows)

      def export
        rows.each! do |columns, model, x|
          worksheet.set_row(x, height, nil) if x > 0
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

          # 表身樣式
          column_options.each_with_index do |column_options, i|
            next if column_options.blank?

            width = column_options.fetch(:width) { FastExcel::DEF_COL_WIDTH }
            format = column_options.fetch(:format) { {} }

            ws.set_column(i, i, width, workbook.add_format(format))
          end

          # 設定表頭樣式
          ws.set_row(0, height, head_format)

          ws
        end
      end

      def head_format
        workbook.add_format(bold: true, bg_color: "#e5dbad", align: { h: :center })
      end

      def options
        @options ||= (rows.class.options || {})
      end

      def worksheet_name
        options.fetch(:worksheet) { "Default" }
      end

      def height
        options.fetch(:height) { 20 }
      end

      def column_options
        @column_options ||= rows.class.column_options
      end
    end
  end
end
