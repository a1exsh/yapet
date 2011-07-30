module CustomValidations
  def self.included(target)
    target.extend(ClassMethods)
  end

  private

  module ClassMethods
    def validates_email_address(field)
      validates_format_of field, :with => /[^@]+@[^.@]+\.[^@]+/
    end
  end
end
