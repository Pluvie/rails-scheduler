require 'rspec/expectations'

RSpec::Matchers.define :have_fields do |*fields|
  match do |actual|
    fields.all? do |field|
      actual.respond_to?(field)
      actual.respond_to?("#{field}=")
    end
  end
end

RSpec::Matchers.define :be_able_to_save_fields do |fields|
  match do |actual|
    fields.each do |field_name, field_value|
      actual.send("#{field_name}=", field_value)
    end
    actual.save
  end
end
