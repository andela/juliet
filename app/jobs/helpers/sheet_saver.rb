class SheetSaver
  class << self
    def save(new_sheet, sheet = nil)
      if new_sheet.save
        sheet.delete if sheet
      end
    end
  end
end
