
placeholder :string_with_spaces do
  match /.*/ do |s|
    s
  end
end

placeholder :boolean do
  match /(is not|do not see|a non existing|have not|can not)/ do
    false
  end

  match /(is|see|an existing|have|can)/ do
    true
  end
end

placeholder :confirm do
  match ', confirming to leave the page' do
    true
  end

  match '' do
    false
  end
end
