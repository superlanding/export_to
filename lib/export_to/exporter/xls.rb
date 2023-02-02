module ExportTo
  module Exporter
    class Xls < Struct.new(:rows)

      def to_xls
        book = Spreadsheet::Workbook.new
        sheet = book.create_worksheet

        rows.each! do |columns, model, x|
          sheet.row(x).concat(columns)
        end

        spreadsheet = StringIO.new
        book.write(spreadsheet)

        spreadsheet.string
      end

    end
  end
end
