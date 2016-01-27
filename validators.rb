require './sheets'

module Validator


  def self.included(base)
    base.class_eval do
      @@company_url_map = nil

      def self.exclusion_list
        sheet = GSheet.new '18qGCs7WC09In3yD-HH3F1h-ysLuMDKyPRpCadS0A77g'
        exclusion_sheet = sheet.worksheets[2]
        excludes = exclusion_sheet.rows
        @@company_url_map = {}
        excludes.each{ |row|
          row.each_with_index{ |col, index|
            # mapping the company to the url using the spreadsheet format
            next_col = row[index + 1]
            @@company_url_map[col] = next_col unless col.blank? || next_col.blank?
          }
        }
        @@company_url_map
      end

      def self.companies_to_exclude
        data = @@company_url_map || exclusion_list
        vals = data.values.join('|')
        keys = data.keys.join('|')
        @@regx ||= Regexp.new "(?=#{vals}|#{keys})$", 'i'
        @@regx
      end
    end
  end

  def additional_exclude
    /\s+(?:llc|co)$/
  end

  def language_exclude
    /(?:\.net|c\#|\bsr\b|\bsenior\b|\bsnr\b)/i
    # (?:\bsr\b)
  end


  def experience_exclude
    /(?=5).*(?=year[s]?)/
  end
end
