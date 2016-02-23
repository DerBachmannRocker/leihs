module PersonasSteps
  # procurement admin
  step 'I am Hans Ueli' do
    persona = create_persona('Hans Ueli')
    FactoryGirl.create(:procurement_access, :admin, user: persona)
    login_as persona
    #old# visit '/procurement'
  end

  # requester
  step 'I am Roger' do
    persona = create_persona('Roger')
    FactoryGirl.create(:procurement_access, :requester, user: persona)

    #old#
    # 3.times do
    #   FactoryGirl.create :procurement_request, user: persona
    # end
    step 'a procurement admin exists'

    login_as persona
    #old# visit '/procurement'
  end

  # inspector and requester
  step 'I am Barbara' do
    persona = create_persona('Barbara')
    FactoryGirl.create(:procurement_group_inspector, user: persona)
    FactoryGirl.create(:procurement_access, :requester, user: persona)

    step 'a procurement admin exists'

    login_as persona
    #old# visit '/procurement'
  end

  # leihs admin
  step 'I am Gino' do
    persona = create_persona('Gino')
    FactoryGirl.create(:access_right, role: :admin)
    login_as persona
    #old# visit '/procurement'
  end

  step 'a procurement admin exists' do
    Procurement::Access.admins.exists? \
      || FactoryGirl.create(:procurement_access, :admin)
  end

  step 'admins exist' do
    Procurement::Access.admins.count >= 3 \
      || 3.times { FactoryGirl.create(:procurement_access, :admin) }
  end

  step 'there exist :count requesters' do |count|
    count.to_i.times do
      FactoryGirl.create(:procurement_access, :requester)
    end
  end

  step 'I am responsible for one group' do
    @group = Procurement::Group.all.detect {|g| g.inspectable_by?(@current_user) }
    expect(@group).not_to be_nil
    # OPTIMIZE just refreshing the header menu
    visit '/procurement'
  end

  def create_user(firstname)
    user = FactoryGirl.create(:user, firstname: firstname)
    FactoryGirl.create(:access_right,
                       user: user,
                       inventory_pool: FactoryGirl.create(:inventory_pool))
    user
  end

  private

  def set_locale(user)
    FastGettext.locale = user.language.locale_name.tr('-', '_')
  end

  def create_persona(firstname)
    user = create_user(firstname)
    set_locale(user)
    user
  end

  def login_as(user)
    @current_user = user
    visit '/authenticator/db/login'
    fill_in _('Username'), with: user.login
    fill_in _('Password'), with: 'password'
    click_on 'Login'
    expect(page).to have_content user.short_name
  end
end

RSpec.configure { |c| c.include PersonasSteps }
