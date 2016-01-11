class SessionsController < ApplicationController

  AUTHENTICATION_URL = 'http://localhost:3000/manage/temporary/login'

  def new
    if Rails.env.test? and params[:login]
      self.current_user = User.find_by_login(params[:login])
      if logged_in?
        if current_user.access_rights.active.size == 0
          render text: _("You don't have any rights to access this application.")
          return
        end
        redirect_back_or_default('/')
        flash[:notice] = _('Logged in successfully')
      else
        render action: 'new'
      end
    elsif Rails.env.development? \
      and params['bypass'] \
      and self.current_user = User.find_by_login(params['bypass'])
      redirect_back_or_default('/')
      flash[:notice] = _('Logged in successfully')
    else
      redirect_to action: 'authenticate'
    end
  end

  def authenticate(id = params[:id])
    @selected_system = AuthenticationSystem.active_systems.find(id) if id
    @selected_system ||= AuthenticationSystem.default_system.first
    # TODO: try to get around without eval
    # rubocop:disable Lint/Eval
    sys = eval('Authenticator::' + @selected_system.class_name + 'Controller').new
    # rubocop:enable Lint/Eval
    redirect_to sys.login_form_path
  rescue
    logger.error($!)
    unless AuthenticationSystem.default_system.first
      raise 'No default authentication system selected.'
    end
    raise 'No system selected.' unless @selected_system
    raise 'Class not found or missing login_form_path method: ' \
      + @selected_system.class_name
  end

  def destroy
    # store last inventory pool to the settings column
    if current_user
      current_user.latest_inventory_pool_id_before_logout = \
        session[:current_inventory_pool_id]
      current_user.save
    end
    # delete cookie and reset session
    cookies.delete :auth_token
    reset_session
    # redirect and flash
    flash[:notice] = _('You have been logged out.')
    session[:locale] = current_user.language.locale_name if current_user
    redirect_back_or_default('/')
  end
end
