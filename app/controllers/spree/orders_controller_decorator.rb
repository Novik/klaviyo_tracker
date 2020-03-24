Spree::OrdersController.class_eval do

  layout :resolve_layout

  def edit
    @order = current_order || Spree::Order.incomplete.find_or_initialize_by(guest_token: cookies.signed[:guest_token])
    associate_user
    if @order.nil?
      redirect_to spree.root_path(cart: true)
    else
      @order.run_flow!
      redirect_to checkout_state_path(@order.state)
    end
  end

  def populate
    order    = current_order(create_order_if_necessary: true)
    options  = params[:options] || {}
    errors = nil

    begin
      variant  = Spree::Variant.find(params[:variant_id])
      order.contents.add(variant, 1, options)
    rescue ActiveRecord::RecordInvalid => e
      errors = e.record.errors.full_messages.join(", ")
      order.contents.remove(variant, 1, options)
    rescue ActiveRecord::RecordNotFound => e
    end

    respond_to do |format|
      format.js { render partial: 'spree/orders/edit', locals: { order: order, errors: errors }, replace: ".cart-contents" }
    end
  end

  def update
    errors = nil
    if params.has_key?(:checkout)
      @order.contents.update_cart(order_params)
      @order.run_flow!
      redirect_to checkout_state_path(@order.state), turbolinks: false
      return
    else
      begin
        @order.contents.update_cart(order_params)
      rescue ActiveRecord::RecordInvalid => e
        errors = e.record.errors.full_messages.join(", ")
      end
      respond_to do |format|
        format.js { render partial: 'spree/orders/edit', locals: { order: @order, errors: errors }, replace: ".cart-contents" }
      end
    end
  end

  def empty
    if @order = current_order
      @order.empty!
    end

    redirect_to spree.root_path(cart: true)
  end

  include Spree::OrdersHelper

  def show
    @order = Spree::Order.find_by_number!(params[:id])
    if @order.nil? || !order_just_completed?(@order)
    	redirect_to root_path
    else
      flash.discard(:order_completed)
    end
  end

  private

  def resolve_layout
    case action_name
      when "show"
        "checkout"
      else
        "application"
    end
  end

end
