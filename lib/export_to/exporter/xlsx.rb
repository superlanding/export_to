module ExportTo
  module Exporter
    class Xlsx < Struct.new(:rows)

      def export
        rows.each! do |columns, model, x|
          worksheet.set_row(x, height, nil)
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
          # 設定表頭樣式
          ws.set_row(0, height, head_format)

          # 表身樣式
          column_formats.each_with_index do |format, i|
            next if format.blank?

            width = format.delete(:width) { FastExcel::DEF_COL_WIDTH }

            puts "#{i} -> #{width} -> #{format}"

            ws.set_column(i, i, width, workbook.add_format(format))
          end

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

      def column_formats
        @column_formats ||= rows.class.column_formats.dup || []
      end
    end
  end
end
