require_dependency "procurement/application_controller"

module Procurement
  class RequestsController < ApplicationController

    before_action do
      unless BudgetPeriod.current
        if is_procurement_admin?
          redirect_to budget_periods_path
        else
          redirect_to root_path
        end
      end

      @user = User.not_as_delegations.find(params[:user_id]) if params[:user_id]
      @group = Procurement::Group.find(params[:group_id]) if params[:group_id]
      @budget_period = BudgetPeriod.find(params[:budget_period_id]) if params[:budget_period_id]
    end

    before_action except: :overview do
      unless @user.nil? or @user == current_user or @group.nil? or @group.inspectable_or_readable_by?(current_user)
        redirect_to root_path
      end
    end

    before_action only: :overview do
      if (@group and not @group.inspectable_or_readable_by?(current_user)) or (@user and not @user == current_user)
        redirect_to root_path
      end
    end

    before_action only: :filter_overview do
      unless Procurement::Group.inspector_of_any_group?(current_user)
        redirect_to root_path
      end
    end

    before_action only: [:index, :overview] do
      @requests = Request.all
      @requests = @requests.where(user_id: @user) if @user
      @requests = @requests.where(group_id: @group) if @group
    end

    before_action only: [:move, :destroy] do
      @request = Request.where(user_id: @user, group_id: @group, budget_period_id: @budget_period).find(params[:id])
    end

    def index
      @requests = @requests.where(budget_period_id: @budget_period)

      respond_to do |format|
        format.html
        format.csv {
          send_data Request.csv_export(@requests, current_user),
                    type: 'text/csv; charset=utf-8; header=present',
                    disposition: "attachment; filename=requests.csv"
        }
      end
    end

    def overview
      @budget_periods = BudgetPeriod.order(end_date: :desc)
    end

    def filter_overview
      params[:filter] ||= {}
      params[:filter][:budget_period_ids] ||= [Procurement::BudgetPeriod.current.id]
      params[:filter][:group_ids] ||= Procurement::Group.pluck(:id)
      params[:filter][:department_ids] ||= Procurement::Organization.departments.pluck(:id)
      params[:filter][:priorities] ||=['high', 'normal']
      params[:filter][:states] ||= Procurement::Request::STATES

      @h = {}
      Procurement::BudgetPeriod.order(end_date: :desc).find(params[:filter][:budget_period_ids]).each do |budget_period|
        # @h[budget_period] = {}
        # Procurement::Group.find(params[:filter][:group_ids]).each do |group|
        #   @h[budget_period][group] = {}
        #   @h[budget_period][group][:budget_limit_amount] = group.budget_limits.find_by(budget_period_id: budget_period).try(:amount)
        #
        #   @h[budget_period][group][:departments] = {}
        #   Procurement::Organization.departments.find(params[:filter][:department_ids]).each do |parent_organization|
        #     @h[budget_period][group][:departments][parent_organization] = {}
        #     parent_organization.children.each do |organization_unit|
        #       requests = organization_unit.requests.where(budget_period_id: budget_period, group_id: group, priority: params[:filter][:priorities]).
        #                   select {|r| params[:filter][:states].map(&:to_sym).include? r.state(current_user)}
        #       @h[budget_period][group][:departments][parent_organization][organization_unit] = {
        #           requests: requests,
        #           total_price: requests.map{|r| r.total_price(current_user)}.sum
        #       }
        #     end
        #   end
        # end

        requests = budget_period.requests.where(group_id: params[:filter][:group_ids], priority: params[:filter][:priorities]).
                      select {|r| params[:filter][:states].map(&:to_sym).include? r.state(current_user)}
        @h[budget_period] = requests
      end

      respond_to do |format|
        format.html { render :filter_overview_3 }
        format.csv {
          # requests = @h.values.flat_map(&:values).flat_map{|x| x[:departments].values.flat_map(&:values)}.flat_map{|x| x[:requests]}
          requests = @h.values.flatten
          send_data Request.csv_export(requests, current_user),
                    type: 'text/csv; charset=utf-8; header=present',
                    disposition: "attachment; filename=requests.csv"
        }
      end
    end

    def create
      keys = [:model_description, :price, :supplier, :motivation, :receiver, :location, attachments_attributes: [:file]]
      keys += [:approved_quantity, :order_quantity, :inspection_comment] if @group.inspectable_by?(current_user)

      errors = params.require(:requests).values.map do |param|
        to_permit_keys = if param[:id].blank? or @user == current_user
                           keys + [:requested_quantity, :priority]
                         else
                           keys
                         end
        permitted = param.permit(to_permit_keys)

        if param[:id]
          r = Request.find(param[:id])
          if permitted.values.all?(&:blank?) or (param[:requested_quantity] and param[:requested_quantity].to_i.zero?)
            r.destroy
          else
            r.update_attributes(permitted)
          end
        else
          next if permitted.values.all?(&:blank?) or (param[:requested_quantity] and param[:requested_quantity].to_i.zero?)
          r = @group.requests.create(permitted) do |x|
            x.user = @user
            x.budget_period = @budget_period
          end
        end
        r.errors.full_messages
      end.flatten.compact

      if errors.empty?
        flash[:success] = _('Saved')
        head status: :ok
      else
        render json: errors, status: :internal_server_error
      end
    end

    def move
      if params[:to_group_id]
        @request.update_attributes group: Procurement::Group.find(params[:to_group_id])
      elsif params[:to_budget_period_id]
        @request.update_attributes budget_period: BudgetPeriod.find(params[:to_budget_period_id])
      end

      flash[:success] = _('Moved')
      redirect_to group_user_budget_period_requests_path(@group, @user, @budget_period)
    end

    def destroy
      @request.destroy

      flash[:success] = _('Deleted')
      redirect_to group_user_budget_period_requests_path(@group, @user, @budget_period)
    end

  end
end
