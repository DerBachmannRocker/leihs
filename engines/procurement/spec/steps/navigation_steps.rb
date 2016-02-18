module NavigationSteps
  step 'I navigate to the requests page' do
    visit procurement.overview_requests_path
  end
  step 'I navigate to the requests overview page' do
    visit procurement.overview_requests_path
  end

  # step 'I navigate to the users list' do
  #   visit procurement.users_path
  # end
  step 'I navigate to the users page' do
    within '.navbar' do
      click_on _('Admin')
      click_on _('Users')
    end
    expect(page).to have_selector('h1', text: _('Users'))
  end

  step 'I navigate to the organisation tree page' do
    within '.navbar' do
      click_on _('Admin')
      click_on _('Organisations')
    end
    expect(page).to have_selector('h1', text: _('Organisations of the requesters'))
  end

  step 'page has been loaded' do
    expect(has_no_selector?(".spinner")).to be true
  end

  step 'I enter the section :section' do |section|
    case section
      when 'My requests'
        step 'I navigate to the requests page'
      else
        raise
    end
  end

  def visit_request(request)
    visit procurement.group_budget_period_user_requests_path(request.group,
                                                             request.budget_period,
                                                             request.user)
  end

  ############################################
  # TODO refactor to a CommonSteps module?

  step 'I click on save' do
    click_on _('Save'), match: :first
  end

  step 'I see a success message' do
    expect(page).to have_content _('Saved')
  end

end

RSpec.configure { |c| c.include NavigationSteps }
