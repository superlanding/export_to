module ExportTo
  module Exporter
    class Csv < Struct.new(:rows)

      def export
        CSV.generate(force_quotes: true) do |csv|
          rows.each! do |columns, model, x|
            csv << columns
          end
        end
      end

    end
  end
end
