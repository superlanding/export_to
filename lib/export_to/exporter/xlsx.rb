module ExportTo
  module Exporter
    class Xlsx < Struct.new(:rows)

      def export
        workbook = FastExcel.open(constant_memory: true)
        worksheet = workbook.add_worksheet("Default")

        bold = workbook.bold_cell_format
        worksheet.set_row(0, FastExcel::DEF_COL_WIDTH, bold)

        rows.each! do |columns, model, x|
          worksheet.write_row(x, columns)
        end

        workbook.read_string
      end

    end
  end
end
