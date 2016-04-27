class Pruner
  include RepositoryManager
  attr_reader :sheet
  attr_accessor :new_sheet

  def get_remote_file
    unprocessed_files.each do |media|
      remote_file = gdrive_session.files.
                    detect { |file| file.title == media.file_name }
      set_sheets(remote_file.id)
      if delete_empty_rows
        add_coy_url
        Media.update(media.id, processed: true,
                               file_url: new_sheet.human_url)
      end
    end
  end

  def unprocessed_files
    Media.where(processed: false)
  end

  def set_sheets(sheet_id)
    @sheet = gdrive_session.spreadsheet_by_key(sheet_id).worksheets[0]
    @new_sheet = gdrive_session.spreadsheet_by_key(sheet_id).
                 add_worksheet("URL Sheet", 100, 5)
  end

  def delete_empty_rows
    (1..sheet.num_rows).each do |row|
      new_col = 1
      (1..sheet.num_cols).each do |col|
        next if sheet[2, col].nil? || sheet[2, col].empty? ||
                (sheet[2, col] == "")
        new_sheet[row, new_col] = sheet[row, col]
        new_col += 1
      end
      next if sheet.rows[row - 1].empty?
    end
    SheetSaver.save(new_sheet, sheet)
  end

  def add_coy_url
    insertion_col = new_sheet.num_cols + 1
    new_sheet[1, insertion_col] = "Company URL"
    (0..(new_sheet.num_rows - 2)).each do |row|
      next if new_sheet.rows[row].empty?
      insertion_row = row + 2
      company_name = new_sheet.list[row]["Company"]
      next if company_name.nil? || (company_name == "")
      new_sheet[insertion_row, insertion_col] = get_company_url(company_name)
    end
    SheetSaver.save(new_sheet)
  end

  def get_company_url(company_name)
    Searcher.new(company_name).search_coy_type
  end
end
