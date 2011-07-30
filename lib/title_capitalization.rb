module TitleCapitalization
  def self.included(model)
    model.extend(ClassMethods)
    model.before_validation_on_create(:capitalize_title)
  end

  module ClassMethods
    # use of this method prevents weird capitalization like 'Dvd-rw'
    # use of mb_chars makes it possible to process international text
    def canonical_title(title)
      chars = title.mb_chars
      chars = chars.capitalize unless chars.first.upcase == chars.first
      chars.to_s
    end

    def with_title(title)
      find_or_create_by_title(canonical_title(title))
    end
  end

  def capitalize_title
    self.title = self.class.canonical_title(self.title)
  end
end
