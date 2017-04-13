# This is very useful if you have two spreadsheets you want to compare and merge.

class SheetMerger
  def initialize(sheet, comparing_sheet)
    session = GoogleDrive.saved_session("auth.json")
    @sheet = session.spreadsheet_by_key(sheet).worksheets[0]
    @comparing_sheet = session.spreadsheet_by_key(comparing_sheet).worksheets[0]
    @initial_num_rows = @sheet.num_rows
  end

  def add_non_existing_row
    insertion_row = @initial_num_rows + 1
    (1..@comparing_sheet.num_rows).each do |row|
      next if @sheet.cells.values.include? @comparing_sheet[row,1]
      (1..@comparing_sheet.num_cols).each do |col|
        @sheet[insertion_row, col] = @comparing_sheet[row, col]
      end
      insertion_row += 1
    end
    if @sheet.save
      puts "#{insertion_row - (1 + @initial_num_rows)} rows were added from the 'comparing sheet'."
    else
      puts "No row was added from the 'comparing sheet'."
    end
  end
end

sheet1 = ""
sheet2 = ""
SheetMerger.new(sheet1, sheet2).add_non_existing_row
