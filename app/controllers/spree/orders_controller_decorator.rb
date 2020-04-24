Spree::OrdersController.class_eval do

  after_action :track_added_to_cart, :only => [:populate], :if => proc {Rails.env.production?}

  def track_added_to_cart
    order    = current_order
    variant  = Spree::Variant.find_by(id: params[:variant_id])
    KlaviyoTracker::track(order,:added_to_cart,variant) if order.try(:user).present? && variant.present?
  end

end
